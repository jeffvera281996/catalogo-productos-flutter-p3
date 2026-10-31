import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/pedido.dart';

/// Repositorio de pedidos. Todo pedido se guarda primero en el dispositivo
/// (no se pierde nunca) y luego se intenta enviar al servidor.
class PedidoRepository {
  PedidoRepository({required this.remoto, required this.local});

  final RemoteDataSource remoto;
  final LocalDataSource local;

  List<Pedido> obtenerTodos() {
    final pedidos = local.leerPedidos()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return pedidos;
  }

  List<Pedido> obtenerPendientes() =>
      obtenerTodos().where((p) => p.estaPendiente).toList();

  Future<void> guardar(Pedido pedido) async {
    final pedidos = local.leerPedidos()
      ..removeWhere((p) => p.id == pedido.id)
      ..add(pedido);
    await local.guardarPedidos(pedidos);
  }

  /// Envia el pedido y, si el servidor lo acepta, lo marca como sincronizado.
  /// Propaga [AppException] si falla, dejando el pedido como pendiente.
  Future<Pedido> enviar(Pedido pedido) async {
    await remoto.enviarPedido(pedido);
    final sincronizado = pedido.copyWith(estado: EstadoPedido.sincronizado);
    await guardar(sincronizado);
    return sincronizado;
  }
}
