import 'package:permission_handler/permission_handler.dart';

/// Resultado simplificado de una solicitud de permiso.
enum EstadoPermiso {
  /// El usuario concedio el permiso (o acceso limitado en iOS).
  concedido,

  /// El usuario lo nego, pero se puede volver a preguntar.
  denegado,

  /// El usuario marco "No volver a preguntar" (Android) o lo nego en iOS:
  /// el sistema ya no muestra el dialogo, solo se puede cambiar en Ajustes.
  denegadoPermanente,

  /// Bloqueado por el sistema (control parental, MDM). No depende del usuario.
  restringido,
}

/// Servicio de permisos en tiempo de ejecucion (runtime permissions).
///
/// Encapsula `permission_handler` para que la UI trabaje con un enum propio
/// y no dependa del plugin.
class PermissionService {
  Future<EstadoPermiso> estadoCamara() async =>
      _mapear(await Permission.camera.status);

  /// Solicita la camara. Si ya esta concedido no muestra ningun dialogo.
  ///
  /// Importante: en Android el `status` previo no distingue "denegado" de
  /// "denegado permanentemente"; solo el resultado de `request()` lo hace.
  /// Por eso siempre se llama a `request()` cuando no hay permiso: si esta
  /// bloqueado, el sistema responde al instante con `permanentlyDenied`.
  Future<EstadoPermiso> solicitarCamara() async {
    final actual = await Permission.camera.status;
    if (actual.isGranted) return EstadoPermiso.concedido;
    if (actual.isRestricted) return EstadoPermiso.restringido;
    return _mapear(await Permission.camera.request());
  }

  /// Abre la pantalla de ajustes de la app para que el usuario habilite
  /// manualmente un permiso denegado permanentemente.
  Future<bool> abrirAjustes() => openAppSettings();

  EstadoPermiso _mapear(PermissionStatus s) {
    if (s.isGranted || s.isLimited) return EstadoPermiso.concedido;
    if (s.isPermanentlyDenied) return EstadoPermiso.denegadoPermanente;
    if (s.isRestricted) return EstadoPermiso.restringido;
    return EstadoPermiso.denegado;
  }
}
