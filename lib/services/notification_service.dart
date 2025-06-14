import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:recordatorioo/data/models/reminder.dart';


@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {

  debugPrint('notificationTapBackground payload: ${notificationResponse.payload}');
  // Aquí puedes agregar lógica similar a onDidReceiveNotificationResponse
  // por ejemplo, navegar a una pantalla específica al tocar la notificación.
}


class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Guatemala'));

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // 2. onDidReceiveNotificationResponse: Esto es para cuando la app está en primer plano.
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      // 3. onDidReceiveBackgroundNotificationResponse: Usa la nueva función de nivel superior.
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // 4. Este método onDidReceiveNotificationResponse ahora solo se usa para el primer plano.
  // No necesita el pragma 'vm:entry-point' porque no se llama directamente desde nativo en segundo plano.
  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
      // Puedes manejar la navegación aquí cuando la app está en primer plano
    }
  }

  Future<void> scheduleReminderNotification(Reminder reminder) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Recordatorios',
      channelDescription: 'Canal para las notificaciones de recordatorios.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final scheduledDate = tz.TZDateTime.from(
      reminder.dateTime,
      tz.local,
    );

    final now = tz.TZDateTime.now(tz.local);
    final finalScheduledDate = scheduledDate.isBefore(now) ? now.add(const Duration(seconds: 1)) : scheduledDate;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id!,
      '¡Recordatorio: ${reminder.name}!',
      'Es hora de tu recordatorio: ${reminder.name}',
      finalScheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: reminder.id.toString(),
    );

    print('Notificación programada para ${reminder.name} el $finalScheduledDate');
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Notificación con ID $id cancelada.');
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('Todas las notificaciones canceladas.');
  }
}