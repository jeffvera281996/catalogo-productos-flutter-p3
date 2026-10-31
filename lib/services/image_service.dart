import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../core/theme/app_colors.dart';

enum FuenteImagen { camara, galeria }

/// Imagen lista para usarse: recortada, comprimida y guardada en la app.
class ImagenProcesada {
  const ImagenProcesada({
    required this.archivo,
    required this.bytesOriginal,
    required this.bytesFinal,
  });

  final File archivo;
  final int bytesOriginal;
  final int bytesFinal;

  /// Porcentaje de reduccion de tamano logrado por la compresion.
  int get ahorroPorcentaje => bytesOriginal == 0
      ? 0
      : (100 - bytesFinal * 100 / bytesOriginal).round().clamp(0, 100);
}

/// Error controlado de captura/procesamiento de imagen.
class ImagenException implements Exception {
  const ImagenException(this.mensaje);
  final String mensaje;
}

/// Servicio de captura y procesamiento de imagenes.
///
/// Flujo: camara/galeria (image_picker) -> recorte con UI nativa
/// (image_cropper: uCrop en Android, TOCropViewController en iOS) ->
/// compresion JPEG 70 % y maximo 1080 px -> copia a documentos de la app.
///
/// No pide permisos: eso es responsabilidad de [PermissionService]; asi
/// cada servicio tiene una sola responsabilidad.
class ImageService {
  ImageService({ImagePicker? picker, ImageCropper? cropper})
    : _picker = picker ?? ImagePicker(),
      _cropper = cropper ?? ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;

  static const int calidadJpeg = 70;
  static const int ladoMaximo = 1080;

  /// Devuelve `null` si el usuario cancela en cualquier paso.
  Future<ImagenProcesada?> obtenerImagen(FuenteImagen fuente) async {
    final XFile? original;
    try {
      original = await _picker.pickImage(
        source: fuente == FuenteImagen.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
        // Primera reduccion: evita trabajar con fotos de 12+ MP en memoria.
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );
    } on PlatformException catch (e) {
      throw ImagenException(_mensajeDe(e));
    }
    if (original == null) return null; // Cancelado por el usuario.
    return procesar(original);
  }

  /// Recorta, comprime y persiste una imagen ya seleccionada.
  Future<ImagenProcesada?> procesar(XFile original) async {
    final bytesOriginal = await original.length();

    final CroppedFile? recorte;
    try {
      recorte = await _cropper.cropImage(
        sourcePath: original.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: calidadJpeg,
        maxWidth: ladoMaximo,
        maxHeight: ladoMaximo,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar foto',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.accent,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Recortar foto',
            doneButtonTitle: 'Listo',
            cancelButtonTitle: 'Cancelar',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );
    } on PlatformException catch (e) {
      throw ImagenException(_mensajeDe(e));
    }
    if (recorte == null) return null;

    // El recorte queda en la cache temporal, que el sistema puede borrar:
    // se copia a la carpeta de documentos de la app.
    final destino = await _guardarEnDocumentos(File(recorte.path));
    return ImagenProcesada(
      archivo: destino,
      bytesOriginal: bytesOriginal,
      bytesFinal: await destino.length(),
    );
  }

  /// Android puede destruir la Activity de la app mientras la camara esta
  /// abierta (poca memoria). Al volver, la foto se recupera con este metodo.
  Future<XFile?> recuperarImagenPerdida() async {
    if (!Platform.isAndroid) return null;
    final respuesta = await _picker.retrieveLostData();
    if (respuesta.isEmpty) return null;
    return respuesta.file;
  }

  Future<void> eliminar(File archivo) async {
    if (await archivo.exists()) await archivo.delete();
  }

  Future<File> _guardarEnDocumentos(File origen) async {
    final docs = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${docs.path}/fotos_pedidos');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);
    final nombre = 'pedido_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return origen.copy('${carpeta.path}/$nombre');
  }

  String _mensajeDe(PlatformException e) => switch (e.code) {
    'camera_access_denied' => 'Acceso a la camara denegado.',
    'photo_access_denied' => 'Acceso a la galeria denegado.',
    'no_available_camera' => 'Este dispositivo no tiene camara disponible.',
    _ => 'No se pudo obtener la imagen (${e.code}).',
  };
}
