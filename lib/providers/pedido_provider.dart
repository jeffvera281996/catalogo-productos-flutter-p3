import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';
import '../data/models/pedido.dart';
import '../data/models/producto.dart';
import '../data/repositories/pedido_repository.dart';
import '../services/connectivity_service.dart';

/// Resultado de crear un pedido, para que la UI muestre el mensaje correcto.
enum ResultadoPedido { enviado, enCola }

class PedidoProvider extends ChangeNotifier {
  PedidoProvider({
    required PedidoRepository repositorio,
    required ConnectivityService conectividad,
  }) : _repositorio = repositorio,
       _conectividad = conectividad {
    _pedidos = _repositorio.obtenerTodos();
    // Cola offline: al volver internet se envian los pedidos pendientes.
    _suscripcion = _conectividad.cambios.listen((conectado) {
      if (conectado) sincronizarPendientes();
    });
  }

  final PedidoRepository _repositorio;
  final ConnectivityService _conectividad;
  late final StreamSubscription<bool> _suscripcion;

  List<Pedido> _pedidos = [];
  bool _enviando = false;
  Future<int>? _sincronizacionEnCurso;

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  int get pendientes => _pedidos.where((p) => p.estaPendiente).length;
  bool get enviando => _enviando;
  bool get sincronizando => _sincronizacionEnCurso != null;

  Future<ResultadoPedido> crearPedido({
    required Producto producto,
    required String cliente,
    required int cantidad,
    String? fotoPath,
  }) async {
    final pedido = Pedido(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      productoId: producto.id,
      productoNombre: producto.nombre,
      precioUnitario: producto.precio,
      cliente: cliente,
      cantidad: cantidad,
      fecha: DateTime.now(),
      fotoPath: fotoPath,
    );

    _enviando = true;
    notifyListeners();
    try {
      // 1) Se persiste primero: aunque la app se cierre, el pedido no se pierde.
      await _repositorio.guardar(pedido);

      // 2) Sin conexion no se intenta la red (evita esperar el timeout).
      if (!_conectividad.hayConexion) return ResultadoPedido.enCola;

      try {
        await _repositorio.enviar(pedido);
        return ResultadoPedido.enviado;
      } on AppException {
        return ResultadoPedido.enCola;
      }
    } finally {
      _enviando = false;
      _recargar();
    }
  }

  /// Envia todos los pedidos pendientes y devuelve cuantos se sincronizaron.
  ///
  /// Control de concurrencia: si ya hay una sincronizacion en curso (la red
  /// puede "parpadear" y emitir varios eventos seguidos), se devuelve ese
  /// mismo Future en lugar de iniciar otra. Asi un pedido nunca se envia dos
  /// veces en paralelo.
  Future<int> sincronizarPendientes() {
    if (!_conectividad.hayConexion) return Future.value(0);
    return _sincronizacionEnCurso ??= _sincronizar().whenComplete(() {
      _sincronizacionEnCurso = null;
      notifyListeners();
    });
  }

  Future<int> _sincronizar() async {
    var enviados = 0;
    for (final pedido in _repositorio.obtenerPendientes()) {
      try {
        await _repositorio.enviar(pedido);
        enviados++;
      } on SinConexionException {
        break; // Se perdio la red otra vez: se reintentara en el proximo evento.
      } on AppException {
        continue; // Error puntual de este pedido: se sigue con los demas.
      }
    }
    _recargar();
    return enviados;
  }

  void _recargar() {
    _pedidos = _repositorio.obtenerTodos();
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
