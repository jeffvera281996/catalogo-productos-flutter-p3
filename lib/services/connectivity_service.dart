import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio nativo de conectividad, desacoplado de la interfaz.
///
/// Expone un `Stream<bool>` (true = hay internet) que cualquier capa puede
/// escuchar. Combina dos fuentes:
///
/// 1. `connectivity_plus`: eventos nativos del sistema (ConnectivityManager en
///    Android, NWPathMonitor en iOS) cuando cambia la interfaz de red.
/// 2. Una verificacion real (resolucion DNS) porque tener Wi-Fi no garantiza
///    tener internet (portales cautivos, router sin salida, etc.).
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    this.hostDePrueba = 'dummyjson.com',
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final String hostDePrueba;

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _suscripcion;
  Timer? _debounce;
  Timer? _reintento;
  bool? _ultimoEstado;

  /// Emite solo cuando el estado cambia (online <-> offline).
  Stream<bool> get cambios => _controller.stream;

  /// Ultimo estado conocido. Antes de la primera verificacion asume online
  /// para no mostrar el banner por error al abrir la app.
  bool get hayConexion => _ultimoEstado ?? true;

  Future<void> iniciar() async {
    _suscripcion = _connectivity.onConnectivityChanged.listen(
      _alCambiarInterfaz,
      onError: (_) => verificar(),
    );
    await verificar();
  }

  /// Los cambios de red llegan en rafagas (p. ej. Wi-Fi -> datos moviles);
  /// el debounce de 600 ms evita verificar y notificar varias veces.
  void _alCambiarInterfaz(List<ConnectivityResult> resultados) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 600),
      () => verificar(resultados),
    );
  }

  /// Verifica el estado actual. Tambien se llama al volver la app a primer
  /// plano, porque en segundo plano el sistema puede no entregar eventos.
  Future<bool> verificar([List<ConnectivityResult>? resultados]) async {
    final interfaces = resultados ?? await _connectivity.checkConnectivity();
    final hayInterfaz = interfaces.any((r) => r != ConnectivityResult.none);
    final conectado = hayInterfaz && await _hayInternetReal();
    _emitir(conectado);
    return conectado;
  }

  Future<bool> _hayInternetReal() async {
    try {
      final r = await InternetAddress.lookup(
        hostDePrueba,
      ).timeout(const Duration(seconds: 3));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  void _emitir(bool conectado) {
    // Mientras no haya internet se re-verifica cada 10 s: si la interfaz no
    // cambia (Wi-Fi sigue "conectado") no llegaria ningun evento nativo.
    _reintento?.cancel();
    if (!conectado) {
      _reintento = Timer(const Duration(seconds: 10), verificar);
    }
    if (conectado == _ultimoEstado) return;
    _ultimoEstado = conectado;
    if (!_controller.isClosed) _controller.add(conectado);
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    _reintento?.cancel();
    await _suscripcion?.cancel();
    await _controller.close();
  }
}
