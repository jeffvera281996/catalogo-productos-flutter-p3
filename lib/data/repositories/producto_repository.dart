import '../../core/errors/app_exceptions.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/producto.dart';

/// De donde salieron los datos que se estan mostrando.
enum OrigenDatos { remoto, cache, semilla }

class ResultadoCatalogo {
  const ResultadoCatalogo(this.productos, this.origen, this.fecha);
  final List<Producto> productos;
  final OrigenDatos origen;
  final DateTime? fecha;
}

/// Repositorio del catalogo con estrategia "network first, cache fallback":
///
/// 1. Intenta descargar de la API y, si lo logra, actualiza la cache.
/// 2. Si falla la red, devuelve la ultima cache guardada.
/// 3. Si no hay cache (primer uso sin internet), devuelve el catalogo semilla.
///
/// La interfaz nunca sabe de HTTP ni de shared_preferences.
class ProductoRepository {
  ProductoRepository({required this.remoto, required this.local});

  final RemoteDataSource remoto;
  final LocalDataSource local;

  Future<ResultadoCatalogo> obtenerProductos({bool hayConexion = true}) async {
    if (hayConexion) {
      try {
        final productos = await remoto.obtenerProductos();
        await local.guardarProductos(productos);
        return ResultadoCatalogo(productos, OrigenDatos.remoto, DateTime.now());
      } on AppException {
        // Continua con la cache.
      }
    }
    final cache = local.leerProductos();
    if (cache != null && cache.productos.isNotEmpty) {
      return ResultadoCatalogo(cache.productos, OrigenDatos.cache, cache.fecha);
    }
    return const ResultadoCatalogo(productosSemilla, OrigenDatos.semilla, null);
  }
}
