// Clase que guarda los datos de un producto
class Producto {
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;

  Producto({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
  });
}

// Lista de productos de ejemplo
List<Producto> listaProductos = [
  Producto(
    nombre: 'Audifonos',
    descripcion: 'Audifonos inalambricos con bluetooth y buena bateria.',
    precio: 25.00,
    imagen: 'https://picsum.photos/id/1/300/200',
  ),
  Producto(
    nombre: 'Reloj',
    descripcion: 'Reloj digital resistente al agua.',
    precio: 40.00,
    imagen: 'https://picsum.photos/id/175/300/200',
  ),
  Producto(
    nombre: 'Camara',
    descripcion: 'Camara para tomar fotos y grabar videos.',
    precio: 80.00,
    imagen: 'https://picsum.photos/id/250/300/200',
  ),
  Producto(
    nombre: 'Laptop',
    descripcion: 'Laptop para estudiar y trabajar.',
    precio: 450.00,
    imagen: 'https://picsum.photos/id/0/300/200',
  ),
];
