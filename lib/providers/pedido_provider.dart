import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';
import '../data/models/pedido.dart';
import '../data/models/producto.dart';
import '../data/repositories/pedido_repository.dart';

/// Resultado de crear un pedido, para que la UI muestre el mensaje correcto.
enum ResultadoPedido { enviado, enCola }

class PedidoProvider extends ChangeNotifier {
  PedidoProvider({required PedidoRepository repositorio})
    : _repositorio = repositorio {
    _pedidos = _repositorio.obtenerTodos();
  }

  final PedidoRepository _repositorio;

  List<Pedido> _pedidos = [];
  bool _enviando = false;

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  int get pendientes => _pedidos.where((p) => p.estaPendiente).length;
  bool get enviando => _enviando;

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
      // 2) Se intenta enviar.
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

  void _recargar() {
    _pedidos = _repositorio.obtenerTodos();
    notifyListeners();
  }
}
