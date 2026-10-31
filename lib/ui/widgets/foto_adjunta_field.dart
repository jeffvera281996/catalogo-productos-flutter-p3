import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../services/image_service.dart';
import '../../services/permission_service.dart';

/// Campo para adjuntar una foto de referencia al pedido.
///
/// Orquesta la UX de permisos (explicacion previa, denegado, bloqueado) y
/// delega la parte nativa en [PermissionService] e [ImageService].
class FotoAdjuntaField extends StatefulWidget {
  const FotoAdjuntaField({super.key, required this.alCambiar});

  /// Notifica el archivo final (o `null` si se quito la foto).
  final ValueChanged<File?> alCambiar;

  @override
  State<FotoAdjuntaField> createState() => _FotoAdjuntaFieldState();
}

class _FotoAdjuntaFieldState extends State<FotoAdjuntaField> {
  ImagenProcesada? _imagen;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _recuperarFotoPerdida();
  }

  /// Ciclo de vida Android: si el sistema cerro la app mientras la camara
  /// estaba abierta, se recupera la foto tomada en lugar de perderla.
  Future<void> _recuperarFotoPerdida() async {
    final imagenes = context.read<ImageService>();
    final perdida = await imagenes.recuperarImagenPerdida();
    if (perdida == null || !mounted) return;
    await _ejecutar(() => imagenes.procesar(perdida));
  }

  Future<void> _desdeCamara() async {
    final permisos = context.read<PermissionService>();

    // 1) Explicar ANTES de que aparezca el dialogo del sistema.
    if (await permisos.estadoCamara() != EstadoPermiso.concedido) {
      if (!mounted) return;
      final continuar = await _dialogoExplicacion();
      if (continuar != true) return;
    }

    // 2) Solicitud en tiempo de ejecucion y manejo de cada resultado.
    final estado = await permisos.solicitarCamara();
    if (!mounted) return;
    switch (estado) {
      case EstadoPermiso.concedido:
        await _obtener(FuenteImagen.camara);
      case EstadoPermiso.denegado:
        _snack(
          'Sin permiso de camara no podemos tomar la foto. '
          'Puedes elegir una de la galeria.',
          accion: SnackBarAction(
            label: 'Reintentar',
            textColor: AppColors.accent,
            onPressed: _desdeCamara,
          ),
        );
      case EstadoPermiso.denegadoPermanente:
        await _dialogoAjustes(permisos);
      case EstadoPermiso.restringido:
        _snack('El uso de la camara esta restringido en este dispositivo.');
    }
  }

  /// La galeria no requiere permiso: Android 13+ usa el Photo Picker del
  /// sistema y iOS 14+ usa PHPicker; ambos solo entregan la foto elegida.
  Future<void> _desdeGaleria() => _obtener(FuenteImagen.galeria);

  Future<void> _obtener(FuenteImagen fuente) {
    final imagenes = context.read<ImageService>();
    return _ejecutar(() => imagenes.obtenerImagen(fuente));
  }

  Future<void> _ejecutar(Future<ImagenProcesada?> Function() tarea) async {
    setState(() => _procesando = true);
    try {
      final nueva = await tarea();
      if (nueva == null || !mounted) return; // Cancelado.
      setState(() => _imagen = nueva);
      widget.alCambiar(nueva.archivo);
    } on ImagenException catch (e) {
      _snack(e.mensaje);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _quitar() {
    final actual = _imagen;
    setState(() => _imagen = null);
    widget.alCambiar(null);
    if (actual != null) context.read<ImageService>().eliminar(actual.archivo);
  }

  Future<bool?> _dialogoExplicacion() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.photo_camera_outlined,
          color: AppColors.primary,
          size: 36,
        ),
        title: const Text('Usar la camara'),
        content: const Text(
          'NexoShop usara la camara solo para que tomes una foto de '
          'referencia de tu pedido. No accedemos a nada mas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogoAjustes(PermissionService permisos) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.no_photography_outlined, color: AppColors.danger),
        title: const Text('Permiso bloqueado'),
        content: const Text(
          'Denegaste el acceso a la camara de forma permanente. Para tomar '
          'fotos, habilitalo en Ajustes > Permisos > Camara.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              permisos.abrirAjustes();
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
  }

  void _snack(String texto, {SnackBarAction? accion}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), action: accion));
  }

  @override
  Widget build(BuildContext context) {
    final imagen = _imagen;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto de referencia (opcional)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (_procesando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (imagen != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imagen.archivo,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.compress, size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_kb(imagen.bytesOriginal)} -> ${_kb(imagen.bytesFinal)} '
                    '(-${imagen.ahorroPorcentaje}%)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _quitar,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Quitar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _desdeCamara,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camara'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _desdeGaleria,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _kb(int bytes) => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).round()} KB';
}
