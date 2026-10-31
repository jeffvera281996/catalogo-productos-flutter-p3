import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/producto.dart';
import '../data/repositories/producto_repository.dart';
import '../services/connectivity_service.dart';

enum EstadoCatalogo { inicial, cargando, listo }

/// Estado del catalogo (patron Provider + ChangeNotifier).
class CatalogoProvider extends ChangeNotifier {
  CatalogoProvider({
    required ProductoRepository repositorio,
    required ConnectivityService conectividad,
  }) : _repositorio = repositorio,
       _conectividad = conectividad {
    // Al recuperar internet, si se esta mostrando cache, se refresca solo.
    _suscripcion = _conectividad.cambios.listen((conectado) {
      if (conectado && _origen != OrigenDatos.remoto) cargar();
    });
  }

  final ProductoRepository _repositorio;
  final ConnectivityService _conectividad;
  late final StreamSubscription<bool> _suscripcion;

  EstadoCatalogo _estado = EstadoCatalogo.inicial;
  List<Producto> _productos = const [];
  OrigenDatos? _origen;
  DateTime? _actualizado;

  EstadoCatalogo get estado => _estado;
  List<Producto> get productos => _productos;
  OrigenDatos? get origen => _origen;
  DateTime? get actualizado => _actualizado;
  bool get cargando => _estado == EstadoCatalogo.cargando;

  /// Carga el catalogo. Si ya hay una carga en curso no lanza otra
  /// (evita peticiones duplicadas por toques repetidos o eventos de red).
  Future<void> cargar() async {
    if (cargando) return;
    _estado = EstadoCatalogo.cargando;
    notifyListeners();

    // Sin internet ni se intenta la red: se va directo a la cache.
    final resultado = await _repositorio.obtenerProductos(
      hayConexion: _conectividad.hayConexion,
    );
    _productos = resultado.productos;
    _origen = resultado.origen;
    _actualizado = resultado.fecha;
    _estado = EstadoCatalogo.listo;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
