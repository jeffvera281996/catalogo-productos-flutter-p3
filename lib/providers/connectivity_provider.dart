import 'dart:async';

import 'package:flutter/widgets.dart';

import '../services/connectivity_service.dart';

enum EstadoRed { enLinea, sinConexion, reconectado }

/// Adapta el Stream del servicio a estado observable por la UI y escucha el
/// ciclo de vida de la app para re-verificar la red al volver a primer plano.
class ConnectivityProvider extends ChangeNotifier with WidgetsBindingObserver {
  ConnectivityProvider(this._servicio) {
    _estado = _servicio.hayConexion ? EstadoRed.enLinea : EstadoRed.sinConexion;
    _suscripcion = _servicio.cambios.listen(_alCambiar);
    WidgetsBinding.instance.addObserver(this);
  }

  final ConnectivityService _servicio;
  late final StreamSubscription<bool> _suscripcion;
  Timer? _ocultarReconectado;
  late EstadoRed _estado;

  EstadoRed get estado => _estado;
  bool get hayConexion => _estado != EstadoRed.sinConexion;

  void _alCambiar(bool conectado) {
    _ocultarReconectado?.cancel();
    if (conectado) {
      // Muestra "Conexion restablecida" 3 s y luego oculta el banner.
      _estado = EstadoRed.reconectado;
      _ocultarReconectado = Timer(const Duration(seconds: 3), () {
        _estado = EstadoRed.enLinea;
        notifyListeners();
      });
    } else {
      _estado = EstadoRed.sinConexion;
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _servicio.verificar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ocultarReconectado?.cancel();
    _suscripcion.cancel();
    super.dispose();
  }
}
