import '../../core/errors/app_exceptions.dart';
import '../models/tasa_cambio.dart';
import 'api_client.dart';

/// Fuente remota de tasas de cambio: API publica Frankfurter.
///
/// - Documentacion: https://frankfurter.dev
/// - Endpoint:      GET https://api.frankfurter.dev/v1/latest?base=USD
/// - Gratuita, sin API key ni autenticacion; datos de referencia del
///   Banco Central Europeo actualizados cada dia habil.
///
/// Reutiliza el [ApiClient] del proyecto (paquete `http`), que ya traduce
/// SocketException / TimeoutException / codigos HTTP a excepciones de dominio.
class DivisasRemoteDataSource {
  DivisasRemoteDataSource(this._api);

  static const String baseUrl = 'https://api.frankfurter.dev/v1';

  final ApiClient _api;

  Future<TasasCambio> obtenerTasas({required String base}) async {
    final json = await _api.get('/latest?base=$base');
    try {
      return TasasCambio.fromJson(json);
    } on TypeError {
      // Falta un campo o vino con un tipo inesperado.
      throw const DatosInvalidosException();
    } on FormatException {
      // La fecha no tiene el formato AAAA-MM-DD.
      throw const DatosInvalidosException();
    }
  }
}
