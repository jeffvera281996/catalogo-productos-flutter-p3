import 'package:flutter_test/flutter_test.dart';
import 'package:nexoshop/data/models/pedido.dart';
import 'package:nexoshop/data/models/producto.dart';

void main() {
  group('Producto', () {
    test('se construye desde la API remota (dummyjson)', () {
      final p = Producto.fromApi({
        'id': 7,
        'title': 'Mouse',
        'description': 'Inalambrico',
        'price': 19.5,
        'thumbnail': 'https://x/y.png',
        'category': 'tech',
      });
      expect(p.id, 7);
      expect(p.nombre, 'Mouse');
      expect(p.precio, 19.5);
      expect(p.categoria, 'tech');
    });

    test('ida y vuelta por JSON de cache conserva los datos', () {
      final original = productosSemilla.first;
      final copia = Producto.fromJson(original.toJson());
      expect(copia.toJson(), original.toJson());
    });
  });

  group('Pedido', () {
    final pedido = Pedido(
      id: '1',
      productoId: 2,
      productoNombre: 'Reloj',
      precioUnitario: 40,
      cliente: 'Ana',
      cantidad: 3,
      fecha: DateTime(2026, 10, 31, 12),
      fotoPath: '/docs/foto.jpg',
    );

    test('calcula el total y nace pendiente', () {
      expect(pedido.total, 120);
      expect(pedido.estaPendiente, isTrue);
    });

    test('serializa estado y foto', () {
      final sincronizado = pedido.copyWith(estado: EstadoPedido.sincronizado);
      final copia = Pedido.fromJson(sincronizado.toJson());
      expect(copia.estado, EstadoPedido.sincronizado);
      expect(copia.fotoPath, '/docs/foto.jpg');
      expect(copia.fecha, pedido.fecha);
    });
  });
}
