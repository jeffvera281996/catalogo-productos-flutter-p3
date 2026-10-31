import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/pedidos_screen.dart';
import 'ui/screens/splash_screen.dart';

/// Rutas con nombre de la aplicacion.
abstract final class Rutas {
  static const splash = '/';
  static const home = '/home';
  static const pedidos = '/pedidos';
}

/// Llave global del Navigator: permite navegar desde fuera del arbol de
/// widgets (por ejemplo, al tocar una notificacion).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NexoShopApp extends StatelessWidget {
  const NexoShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: navigatorKey,
      initialRoute: Rutas.splash,
      routes: {
        Rutas.splash: (_) => const SplashScreen(),
        Rutas.home: (_) => const HomeScreen(),
        Rutas.pedidos: (_) => const PedidosScreen(),
      },
    );
  }
}
