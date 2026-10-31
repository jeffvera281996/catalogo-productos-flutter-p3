import '../../core/errors/app_exceptions.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import 'api_client.dart';

/// Acceso a la API remota (https://dummyjson.com, API publica de pruebas).
class RemoteDataSource {
  RemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Producto>> obtenerProductos() async {
    final json = await _api.get('/products?limit=20');
    final lista = json['products'];
    if (lista is! List) throw const DatosInvalidosException();
    try {
      return lista
          .cast<Map<String, dynamic>>()
          .map(Producto.fromApi)
          .toList(growable: false);
    } on TypeError {
      // Algun campo vino con un tipo inesperado.
      throw const DatosInvalidosException();
    }
  }

  /// Envia el pedido. dummyjson simula la creacion de un carrito y responde
  /// 2xx, lo que nos permite probar el flujo real de red sin backend propio.
  Future<void> enviarPedido(Pedido pedido) async {
    await _api.post('/carts/add', {
      'userId': 1,
      'products': [
        {'id': pedido.productoId, 'quantity': pedido.cantidad},
      ],
    });
  }
}
