/// Estado de un pedido respecto al servidor.
enum EstadoPedido {
  /// Guardado en el dispositivo, aun no confirmado por el servidor.
  pendiente,

  /// Confirmado por el servidor.
  sincronizado,
}

/// Pedido realizado desde la pantalla de detalle.
class Pedido {
  const Pedido({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.precioUnitario,
    required this.cliente,
    required this.cantidad,
    required this.fecha,
    this.estado = EstadoPedido.pendiente,
    this.fotoPath,
  });

  final String id;
  final int productoId;
  final String productoNombre;
  final double precioUnitario;
  final String cliente;
  final int cantidad;
  final DateTime fecha;
  final EstadoPedido estado;

  /// Ruta local de la foto adjunta (ya recortada y comprimida), si existe.
  final String? fotoPath;

  double get total => precioUnitario * cantidad;
  bool get estaPendiente => estado == EstadoPedido.pendiente;

  Pedido copyWith({EstadoPedido? estado}) {
    return Pedido(
      id: id,
      productoId: productoId,
      productoNombre: productoNombre,
      precioUnitario: precioUnitario,
      cliente: cliente,
      cantidad: cantidad,
      fecha: fecha,
      estado: estado ?? this.estado,
      fotoPath: fotoPath,
    );
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as String,
      productoId: (json['productoId'] as num).toInt(),
      productoNombre: json['productoNombre'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cliente: json['cliente'] as String,
      cantidad: (json['cantidad'] as num).toInt(),
      fecha: DateTime.parse(json['fecha'] as String),
      estado: EstadoPedido.values.byName(json['estado'] as String),
      fotoPath: json['fotoPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productoId': productoId,
    'productoNombre': productoNombre,
    'precioUnitario': precioUnitario,
    'cliente': cliente,
    'cantidad': cantidad,
    'fecha': fecha.toIso8601String(),
    'estado': estado.name,
    'fotoPath': fotoPath,
  };
}
