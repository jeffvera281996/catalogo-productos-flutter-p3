/// Entidad Producto del catalogo.
///
/// Respecto a la Actividad 1 se agregan `id`, `categoria` y la serializacion
/// JSON, necesaria para leer la API remota y para guardar la cache local.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    this.categoria = 'general',
  });

  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;
  final String categoria;

  /// Construye un producto desde la API remota (formato de dummyjson.com).
  factory Producto.fromApi(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as num).toInt(),
      nombre: json['title'] as String,
      descripcion: (json['description'] as String?) ?? '',
      precio: (json['price'] as num).toDouble(),
      imagen: (json['thumbnail'] as String?) ?? '',
      categoria: (json['category'] as String?) ?? 'general',
    );
  }

  /// Formato propio usado en la cache local (shared_preferences).
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      imagen: json['imagen'] as String,
      categoria: (json['categoria'] as String?) ?? 'general',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'imagen': imagen,
    'categoria': categoria,
  };
}

/// Catalogo semilla (los productos originales de la Actividad 1).
/// Se usa solo si la app se abre por primera vez sin internet y sin cache.
const List<Producto> productosSemilla = [
  Producto(
    id: 1,
    nombre: 'Audifonos',
    descripcion: 'Audifonos inalambricos con bluetooth y buena bateria.',
    precio: 25.00,
    imagen: 'https://picsum.photos/id/1/300/200',
  ),
  Producto(
    id: 2,
    nombre: 'Reloj',
    descripcion: 'Reloj digital resistente al agua.',
    precio: 40.00,
    imagen: 'https://picsum.photos/id/175/300/200',
  ),
  Producto(
    id: 3,
    nombre: 'Camara',
    descripcion: 'Camara para tomar fotos y grabar videos.',
    precio: 80.00,
    imagen: 'https://picsum.photos/id/250/300/200',
  ),
  Producto(
    id: 4,
    nombre: 'Laptop',
    descripcion: 'Laptop para estudiar y trabajar.',
    precio: 450.00,
    imagen: 'https://picsum.photos/id/0/300/200',
  ),
];
