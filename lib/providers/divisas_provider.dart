import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';
import '../data/models/tasa_cambio.dart';
import '../data/repositories/divisas_repository.dart';

/// Estados posibles de la peticion de tasas de cambio.
///
/// Es una jerarquia `sealed`: el compilador obliga a la UI a manejar los
/// tres casos (Cargando, Exito, Error) en cada `switch`, asi ninguna pantalla
/// puede "olvidarse" de mostrar el error.
sealed class DivisasEstado {
  const DivisasEstado();
}

/// La peticion esta en curso y aun no hay datos que mostrar.
final class DivisasCargando extends DivisasEstado {
  const DivisasCargando();
}

/// La API respondio correctamente y el JSON se mapeo a [TasasCambio].
final class DivisasExito extends DivisasEstado {
  const DivisasExito(this.datos);
  final TasasCambio datos;
}

/// La peticion fallo. [sinConexion] distingue un problema de red (el
/// usuario puede solucionarlo) de un error del servidor o de datos.
final class DivisasError extends DivisasEstado {
  const DivisasError(this.mensaje, {this.sinConexion = false});
  final String mensaje;
  final bool sinConexion;
}

/// Gestion de estado del modulo de divisas (Provider + ChangeNotifier).
///
/// La UI nunca toca HTTP ni JSON: solo llama a [cargar] / [cambiarBase] y
/// reconstruye segun [estado].
class DivisasProvider extends ChangeNotifier {
  DivisasProvider(this._repositorio);

  final DivisasRepository _repositorio;

  DivisasEstado _estado = const DivisasCargando();
  String _base = 'USD';
  double _monto = 1;
  int _peticionActual = 0;
  bool _cargando = false;

  DivisasEstado get estado => _estado;
  String get base => _base;
  double get monto => _monto;
  bool get cargando => _cargando;

  /// Descarga las tasas para la moneda [base] actual.
  ///
  /// Con [refrescar] = true (pull-to-refresh) y datos ya visibles, no se pasa
  /// a "Cargando": el propio RefreshIndicator muestra el progreso y la lista
  /// sigue en pantalla mientras llega la respuesta.
  Future<void> cargar({bool refrescar = false}) async {
    final idPeticion = ++_peticionActual;
    _cargando = true;
    if (!(refrescar && _estado is DivisasExito)) {
      _estado = const DivisasCargando();
    }
    notifyListeners();

    DivisasEstado nuevo;
    try {
      final datos = await _repositorio.obtenerTasas(base: _base);
      nuevo = DivisasExito(datos);
    } on SinConexionException catch (e) {
      nuevo = DivisasError(e.mensaje, sinConexion: true);
    } on AppException catch (e) {
      nuevo = DivisasError(e.mensaje);
    } catch (_) {
      nuevo = const DivisasError('Ocurrio un error inesperado.');
    }

    // Si mientras tanto el usuario cambio de moneda base, esta respuesta ya
    // es obsoleta y se descarta (evita mostrar tasas de otra base).
    if (idPeticion != _peticionActual) return;
    _estado = nuevo;
    _cargando = false;
    notifyListeners();
  }

  /// Cambia la moneda base y vuelve a consultar la API.
  Future<void> cambiarBase(String base) {
    if (base == _base && _estado is DivisasExito) return Future.value();
    _base = base;
    return cargar();
  }

  /// Monto a convertir (calculo local, no genera peticiones).
  void actualizarMonto(double monto) {
    if (monto < 0 || monto == _monto) return;
    _monto = monto;
    notifyListeners();
  }
}
