import '../datasources/divisas_remote_datasource.dart';
import '../models/tasa_cambio.dart';

/// Repositorio de tasas de cambio.
///
/// A diferencia del catalogo, aqui NO hay cache: las tasas son datos en
/// tiempo real y mostrar una cifra vieja como si fuera actual seria enganoso.
/// Por eso los errores de red se propagan (como [AppException]) hasta el
/// Provider, que los convierte en el estado "Error" de la pantalla.
class DivisasRepository {
  DivisasRepository(this._remoto);

  final DivisasRemoteDataSource _remoto;

  Future<TasasCambio> obtenerTasas({String base = 'USD'}) =>
      _remoto.obtenerTasas(base: base);
}
