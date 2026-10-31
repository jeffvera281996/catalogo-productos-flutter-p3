import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/datasources/api_client.dart';
import 'data/datasources/local_datasource.dart';
import 'data/datasources/remote_datasource.dart';
import 'data/repositories/pedido_repository.dart';
import 'data/repositories/producto_repository.dart';
import 'providers/catalogo_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/pedido_provider.dart';
import 'services/connectivity_service.dart';
import 'services/image_service.dart';
import 'services/permission_service.dart';

/// Punto de entrada: construye las dependencias (inyeccion manual) y las
/// expone a la UI mediante Provider. Ninguna pantalla crea sus propias
/// dependencias, lo que mantiene la UI desacoplada de datos y servicios.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capa de datos
  final prefs = await SharedPreferences.getInstance();
  final local = LocalDataSource(prefs);
  final remoto = RemoteDataSource(ApiClient());
  final productoRepo = ProductoRepository(remoto: remoto, local: local);
  final pedidoRepo = PedidoRepository(remoto: remoto, local: local);

  // Servicios nativos
  final conectividad = ConnectivityService();
  await conectividad.iniciar();

  runApp(
    MultiProvider(
      providers: [
        Provider<ConnectivityService>.value(value: conectividad),
        Provider<PermissionService>(create: (_) => PermissionService()),
        Provider<ImageService>(create: (_) => ImageService()),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(conectividad),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogoProvider(
            repositorio: productoRepo,
            conectividad: conectividad,
          ),
        ),
        ChangeNotifierProvider(
          // lazy: false -> se crea al arrancar para escuchar la red desde el
          // inicio y sincronizar pedidos pendientes de sesiones anteriores.
          lazy: false,
          create: (_) => PedidoProvider(
            repositorio: pedidoRepo,
            conectividad: conectividad,
          )..sincronizarPendientes(),
        ),
      ],
      child: const NexoShopApp(),
    ),
  );
}
