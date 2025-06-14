import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas y horas
import 'package:recordatorioo/data/database/reminder_db.dart';
import 'package:recordatorioo/data/models/reminder.dart';
import 'package:recordatorioo/services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDateTime; // Almacena la fecha y hora seleccionada
  List<Reminder> _reminders = []; // Lista para almacenar y mostrar los recordatorios

  @override
  void initState() {
    super.initState();
    _loadReminders(); // Carga los recordatorios al iniciar la pantalla
  }

  // Método para cargar los recordatorios desde la base de datos
  Future<void> _loadReminders() async {
    final reminders = await ReminderDatabase.instance.readAllReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  // Método para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime?.hour ?? DateTime.now().hour,
          _selectedDateTime?.minute ?? DateTime.now().minute,
        );
      });
    }
  }

  // Método para seleccionar la hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime?.year ?? DateTime.now().year,
          _selectedDateTime?.month ?? DateTime.now().month,
          _selectedDateTime?.day ?? DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // Método para agregar/guardar un recordatorio
  Future<void> _saveReminder() async {
    if (_nameController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre y selecciona fecha/hora.')),
      );
      return;
    }

    final newReminder = Reminder(
      name: _nameController.text,
      dateTime: _selectedDateTime!,
    );

    // Guardar en la base de datos
    final savedReminder = await ReminderDatabase.instance.insertReminder(newReminder);

    // Programar la notificación
    await NotificationService().scheduleReminderNotification(savedReminder);

    // Limpiar campos y recargar recordatorios
    _nameController.clear();
    setState(() {
      _selectedDateTime = null; // Reinicia la selección de fecha/hora
    });
    _loadReminders();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio guardado y notificación programada.')),
    );
  }

  // Método para eliminar un recordatorio
  Future<void> _deleteReminder(int id) async {
    await ReminderDatabase.instance.delete(id);
    await NotificationService().cancelNotification(id); // Cancela la notificación asociada
    _loadReminders(); // Recarga la lista
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio eliminado.')),
    );
  }

  // Puedes agregar un método para editar si lo deseas
  // Future<void> _editReminder(Reminder reminder) async {
  //   // Lógica para prellenar el formulario con los datos del recordatorio
  //   // y luego llamar a ReminderDatabase.instance.update()
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para el nombre del recordatorio
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Recordatorio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Selección de Fecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Selecciona una fecha'
                        : 'Fecha: ${DateFormat.yMd().format(_selectedDateTime!)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Selección de Hora
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Selecciona una hora'
                        : 'Hora: ${DateFormat.Hm().format(_selectedDateTime!)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Seleccionar Hora'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón para guardar el recordatorio
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Botón más grande
              ),
              child: const Text('Guardar Recordatorio', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),

            const Text('Próximos Recordatorios:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),

            // Lista de recordatorios
            Expanded(
              child: _reminders.isEmpty
                  ? const Center(child: Text('No hay recordatorios agendados.'))
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _reminders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(reminder.name),
                            subtitle: Text(
                              '${DateFormat('dd/MM/yyyy - HH:mm').format(reminder.dateTime)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteReminder(reminder.id!),
                            ),
                            // Puedes agregar un onTap para editar
                            // onTap: () => _editReminder(reminder),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}