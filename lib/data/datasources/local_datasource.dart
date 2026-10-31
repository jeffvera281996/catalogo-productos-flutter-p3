import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pedido.dart';
import '../models/producto.dart';

/// Productos guardados en cache junto con la fecha en que se descargaron.
class CacheProductos {
  const CacheProductos(this.productos, this.fecha);
  final List<Producto> productos;
  final DateTime fecha;
}

/// Persistencia local (cache del catalogo + cola de pedidos) sobre
/// shared_preferences. Es la base de la estrategia offline-first.
class LocalDataSource {
  LocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _kProductos = 'cache_productos_v1';
  static const _kProductosFecha = 'cache_productos_fecha_v1';
  static const _kPedidos = 'pedidos_v1';

  Future<void> guardarProductos(List<Producto> productos) async {
    final json = jsonEncode(productos.map((p) => p.toJson()).toList());
    await _prefs.setString(_kProductos, json);
    await _prefs.setString(
      _kProductosFecha,
      DateTime.now().toIso8601String(),
    );
  }

  /// Devuelve `null` si nunca se guardo cache o si esta corrupta.
  CacheProductos? leerProductos() {
    final json = _prefs.getString(_kProductos);
    final fecha = _prefs.getString(_kProductosFecha);
    if (json == null || fecha == null) return null;
    try {
      final lista = (jsonDecode(json) as List)
          .cast<Map<String, dynamic>>()
          .map(Producto.fromJson)
          .toList(growable: false);
      return CacheProductos(lista, DateTime.parse(fecha));
    } on Object {
      // Cache danada (p. ej. cambio de formato entre versiones): se descarta.
      _prefs.remove(_kProductos);
      return null;
    }
  }

  List<Pedido> leerPedidos() {
    final json = _prefs.getString(_kPedidos);
    if (json == null) return [];
    try {
      return (jsonDecode(json) as List)
          .cast<Map<String, dynamic>>()
          .map(Pedido.fromJson)
          .toList();
    } on Object {
      return [];
    }
  }

  Future<void> guardarPedidos(List<Pedido> pedidos) async {
    await _prefs.setString(
      _kPedidos,
      jsonEncode(pedidos.map((p) => p.toJson()).toList()),
    );
  }
}
