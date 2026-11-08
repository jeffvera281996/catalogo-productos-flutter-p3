/// Utilidades de formato numerico sin dependencias externas.
abstract final class Formato {
  /// Formatea con separador de miles "," y punto decimal.
  /// Ajusta los decimales a la magnitud: 0.006543 -> "0.0065",
  /// 18.4321 -> "18.43", 15230.5 -> "15,230.50".
  static String numero(double valor) {
    final abs = valor.abs();
    final decimales = abs == 0
        ? 2
        : abs < 0.01
        ? 6
        : abs < 1
        ? 4
        : 2;
    final texto = abs.toStringAsFixed(decimales);
    final partes = texto.split('.');
    final entero = partes[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final signo = valor < 0 ? '-' : '';
    return partes.length > 1 ? '$signo$entero.${partes[1]}' : '$signo$entero';
  }

  /// "06/11/2026"
  static String fecha(DateTime f) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year}';
  }
}
