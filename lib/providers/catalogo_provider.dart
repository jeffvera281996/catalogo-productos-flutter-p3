import 'package:flutter/foundation.dart';

import '../data/models/producto.dart';
import '../data/repositories/producto_repository.dart';

enum EstadoCatalogo { inicial, cargando, listo }

/// Estado del catalogo (patron Provider + ChangeNotifier).
class CatalogoProvider extends ChangeNotifier {
  CatalogoProvider({required ProductoRepository repositorio})
    : _repositorio = repositorio;

  final ProductoRepository _repositorio;

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
  Future<void> cargar({bool hayConexion = true}) async {
    if (cargando) return;
    _estado = EstadoCatalogo.cargando;
    notifyListeners();

    final resultado = await _repositorio.obtenerProductos(
      hayConexion: hayConexion,
    );
    _productos = resultado.productos;
    _origen = resultado.origen;
    _actualizado = resultado.fecha;
    _estado = EstadoCatalogo.listo;
    notifyListeners();
  }
}
