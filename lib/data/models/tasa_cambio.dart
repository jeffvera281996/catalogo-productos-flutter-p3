import '../../core/constants/monedas.dart';

/// Una tasa de cambio individual: cuantas unidades de [codigo] equivalen a
/// 1 unidad de la moneda base.
class TasaCambio {
  const TasaCambio({required this.codigo, required this.valor});

  final String codigo;
  final double valor;

  String get nombre => Monedas.nombre(codigo);
  String get bandera => Monedas.bandera(codigo);

  /// Convierte un [monto] expresado en la moneda base a esta moneda.
  double convertir(double monto) => monto * valor;

  factory TasaCambio.fromJson(Map<String, dynamic> json) => TasaCambio(
    codigo: json['codigo'] as String,
    valor: (json['valor'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'codigo': codigo, 'valor': valor};
}

/// Respuesta completa del endpoint `/latest` de la API Frankfurter.
///
/// Ejemplo del JSON recibido:
/// ```json
/// {
///   "amount": 1.0,
///   "base": "USD",
///   "date": "2026-11-06",
///   "rates": { "EUR": 0.8712, "MXN": 18.43, "JPY": 152.1 }
/// }
/// ```
/// El objeto `rates` es un mapa dinamico (clave = codigo ISO 4217), por eso
/// se transforma en una lista tipada de [TasaCambio].
class TasasCambio {
  const TasasCambio({
    required this.base,
    required this.fecha,
    required this.monto,
    required this.tasas,
  });

  final String base;
  final DateTime fecha;
  final double monto;
  final List<TasaCambio> tasas;

  factory TasasCambio.fromJson(Map<String, dynamic> json) {
    final rates = json['rates'] as Map<String, dynamic>;
    final tasas = rates.entries
        .map((e) => TasaCambio(codigo: e.key, valor: (e.value as num).toDouble()))
        .toList()
      ..sort((a, b) => Monedas.compararCodigos(a.codigo, b.codigo));
    return TasasCambio(
      base: json['base'] as String,
      fecha: DateTime.parse(json['date'] as String),
      monto: (json['amount'] as num).toDouble(),
      tasas: List.unmodifiable(tasas),
    );
  }

  /// Serializa de vuelta al mismo formato de la API (ida y vuelta simetrica).
  Map<String, dynamic> toJson() => {
    'amount': monto,
    'base': base,
    'date': _fechaIso(fecha),
    'rates': {for (final t in tasas) t.codigo: t.valor},
  };

  static String _fechaIso(DateTime f) =>
      '${f.year.toString().padLeft(4, '0')}-'
      '${f.month.toString().padLeft(2, '0')}-'
      '${f.day.toString().padLeft(2, '0')}';
}
