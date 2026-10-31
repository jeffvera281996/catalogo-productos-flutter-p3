/// Excepciones de dominio de NexoShop.
///
/// Las capas de datos y servicios traducen los errores tecnicos
/// (SocketException, TimeoutException, PlatformException...) a estas clases,
/// asi la interfaz solo maneja mensajes comprensibles para el usuario.
sealed class AppException implements Exception {
  const AppException(this.mensaje);
  final String mensaje;

  @override
  String toString() => '$runtimeType: $mensaje';
}

/// No hay internet o el servidor no respondio a tiempo.
class SinConexionException extends AppException {
  const SinConexionException([
    super.mensaje = 'Sin conexion a internet. Intenta de nuevo.',
  ]);
}

/// El servidor respondio con un codigo de error HTTP.
class ServidorException extends AppException {
  const ServidorException(this.codigo)
    : super('El servidor respondio con el codigo $codigo.');
  final int codigo;
}

/// La respuesta llego pero no tiene el formato esperado.
class DatosInvalidosException extends AppException {
  const DatosInvalidosException([
    super.mensaje = 'Los datos recibidos no son validos.',
  ]);
}
