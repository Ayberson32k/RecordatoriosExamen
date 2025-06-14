import 'package:flutter/material.dart';
import 'package:recordatorioo/presentation/screens/reminder_screen.dart';
import 'package:recordatorioo/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los bindings de Flutter estén inicializados
  await NotificationService().initNotifications(); // Inicializa el servicio de notificaciones
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorio App',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ReminderScreen(), // Tu pantalla principal
    );
  }
}
