import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/pedidos_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/widgets/offline_banner.dart';

/// Rutas con nombre de la aplicacion.
abstract final class Rutas {
  static const splash = '/';
  static const home = '/home';
  static const pedidos = '/pedidos';
}

/// Llave global del Navigator: permite navegar desde fuera del arbol de
/// widgets (por ejemplo, al tocar una notificacion).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NexoShopApp extends StatefulWidget {
  const NexoShopApp({super.key});

  @override
  State<NexoShopApp> createState() => _NexoShopAppState();
}

class _NexoShopAppState extends State<NexoShopApp> {
  StreamSubscription<String?>? _toques;

  @override
  void initState() {
    super.initState();
    // Tocar una notificacion con la app abierta o en segundo plano lleva a
    // "Mis pedidos". El servicio no conoce la UI: solo emite el payload.
    _toques = context.read<NotificationService>().toques.listen((payload) {
      if (payload == NotificationService.payloadPedidos) {
        navigatorKey.currentState?.pushNamed(Rutas.pedidos);
      }
    });
  }

  @override
  void dispose() {
    _toques?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: navigatorKey,
      // Banner de conectividad global, por encima de todas las rutas.
      builder: (context, child) => OfflineBanner(child: child!),
      initialRoute: Rutas.splash,
      routes: {
        Rutas.splash: (_) => const SplashScreen(),
        Rutas.home: (_) => const HomeScreen(),
        Rutas.pedidos: (_) => const PedidosScreen(),
      },
    );
  }
}
