import 'package:flutter/material.dart';

/// Paleta oficial de NexoShop.
///
/// Es la unica fuente de colores de la app: ninguna pantalla usa colores
/// "sueltos" (Colors.blue, Colors.green...) como en la version anterior.
/// Los mismos valores estan replicados en el lado nativo
/// (android/app/src/main/res/values/colors.xml) para el icono y el splash.
abstract final class AppColors {
  static const Color primary = Color(0xFF4A2FBD); // Violeta Nexo
  static const Color primaryDark = Color(0xFF2A1B6E); // Indigo noche
  static const Color primaryLight = Color(0xFF6A4CFF); // Violeta electrico
  static const Color accent = Color(0xFFFF6B4A); // Coral (nodo de conexion)
  static const Color background = Color(0xFFF6F4FF); // Lavanda muy claro
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1B1530); // Texto principal
  static const Color muted = Color(0xFF6B6588); // Texto secundario
  static const Color success = Color(0xFF1FAA7A);
  static const Color warning = Color(0xFFF5A524);
  static const Color danger = Color(0xFFE5484D);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );
}
