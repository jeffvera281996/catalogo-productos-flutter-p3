import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/theme/app_colors.dart';

/// Servicio de notificaciones locales (sin servidor push).
///
/// - Android: crea canales nativos (obligatorios desde Android 8). Cada canal
///   tiene su propia importancia y el usuario puede silenciarlos por separado
///   desde Ajustes > Apps > NexoShop > Notificaciones.
/// - Android 13+: solicita el permiso POST_NOTIFICATIONS en tiempo de ejecucion.
/// - iOS: solicita autorizacion (alerta, globo, sonido) y muestra las
///   notificaciones incluso con la app en primer plano.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _toques = StreamController<String?>.broadcast();
  int _siguienteId = 0;

  static const String payloadPedidos = 'pedidos';

  /// Canal de alta importancia: aparece como "heads-up" con sonido.
  static const AndroidNotificationChannel canalPedidos =
      AndroidNotificationChannel(
        'nexo_pedidos',
        'Pedidos',
        description: 'Confirmacion, cola offline y sincronizacion de pedidos.',
        importance: Importance.high,
      );

  /// Canal de baja importancia: solo icono en la barra, sin sonido.
  static const AndroidNotificationChannel canalConectividad =
      AndroidNotificationChannel(
        'nexo_conectividad',
        'Estado de conexion',
        description: 'Avisos cuando la app pierde o recupera internet.',
        importance: Importance.low,
      );

  /// Emite el `payload` cada vez que el usuario toca una notificacion.
  Stream<String?> get toques => _toques.stream;

  Future<void> inicializar() async {
    const ajustes = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_stat_nexoshop'),
      // Los permisos de iOS se piden despues, en un momento con contexto.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: ajustes,
      onDidReceiveNotificationResponse: (r) => _toques.add(r.payload),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(canalPedidos);
    await android?.createNotificationChannel(canalConectividad);
  }

  /// Si la app se abrio desde una notificacion (app cerrada), devuelve su
  /// payload para navegar a la pantalla correspondiente.
  Future<String?> payloadDeArranque() async {
    final detalles = await _plugin.getNotificationAppLaunchDetails();
    if (detalles?.didNotificationLaunchApp ?? false) {
      return detalles!.notificationResponse?.payload;
    }
    return null;
  }

  /// Solicita el permiso de notificaciones (Android 13+ / iOS).
  /// Devuelve `true` si las notificaciones estan permitidas.
  Future<bool> solicitarPermiso() async {
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.requestNotificationsPermission() ?? false;
      }
      if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } on Exception {
      // Si falla la solicitud la app sigue funcionando, solo sin avisos.
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // Eventos clave del sistema
  // ---------------------------------------------------------------------

  Future<void> pedidoConfirmado(String producto, int cantidad) => _mostrar(
    canal: canalPedidos,
    titulo: 'Pedido confirmado',
    cuerpo: 'Tu pedido de $cantidad x $producto fue recibido por la tienda.',
  );

  Future<void> pedidoEnCola(String producto) => _mostrar(
    canal: canalPedidos,
    titulo: 'Pedido guardado sin conexion',
    cuerpo:
        'Tu pedido de $producto se enviara automaticamente cuando vuelva '
        'internet.',
  );

  Future<void> pedidosSincronizados(int cantidad) => _mostrar(
    canal: canalPedidos,
    titulo: 'Pedidos sincronizados',
    cuerpo: cantidad == 1
        ? 'Se envio 1 pedido que estaba pendiente.'
        : 'Se enviaron $cantidad pedidos que estaban pendientes.',
  );

  Future<void> conexionPerdida() => _mostrar(
    canal: canalConectividad,
    titulo: 'Sin conexion',
    cuerpo: 'NexoShop sigue funcionando con los datos guardados.',
    id: 9000, // id fijo: reemplaza el aviso anterior en vez de acumularse.
  );

  Future<void> conexionRestablecida() => _mostrar(
    canal: canalConectividad,
    titulo: 'Conexion restablecida',
    cuerpo: 'Catalogo y pedidos se estan actualizando.',
    id: 9000,
  );

  Future<void> _mostrar({
    required AndroidNotificationChannel canal,
    required String titulo,
    required String cuerpo,
    int? id,
  }) async {
    final detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        canal.id,
        canal.name,
        channelDescription: canal.description,
        importance: canal.importance,
        priority: canal.importance == Importance.high
            ? Priority.high
            : Priority.low,
        icon: '@drawable/ic_stat_nexoshop',
        color: AppColors.primary,
        styleInformation: BigTextStyleInformation(cuerpo),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
      ),
    );
    try {
      await _plugin.show(
        id: id ?? _siguienteId++,
        title: titulo,
        body: cuerpo,
        notificationDetails: detalles,
        payload: payloadPedidos,
      );
    } on Exception catch (e) {
      // Una notificacion fallida nunca debe romper el flujo de la app.
      debugPrint('No se pudo mostrar la notificacion: $e');
    }
  }

  Future<void> dispose() => _toques.close();
}
