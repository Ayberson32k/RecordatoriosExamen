import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:recordatorioo/data/models/reminder.dart'; // Importa tu modelo

class ReminderDatabase {
  static final ReminderDatabase instance = ReminderDatabase._init();
  static Database? _database;

  ReminderDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('reminders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE reminders (
        id $idType,
        name $textType,
        dateTime $textType
      )
    ''');
  }

  // --- Operaciones CRUD ---

  // Crear/Insertar un recordatorio
  Future<Reminder> create(Reminder reminder) async {
    final db = await instance.database;
    final id = await db.insert('reminders', reminder.toMap());
    return reminder.copyWith(id: id); // El modelo no tiene copyWith, lo haremos de forma simple
  }

  // Helper para asignar ID, ya que el modelo no tiene copyWith
  Future<Reminder> insertReminder(Reminder reminder) async {
    final db = await instance.database;
    final id = await db.insert('reminders', reminder.toMap());
    return Reminder(id: id, name: reminder.name, dateTime: reminder.dateTime);
  }

  // Leer un recordatorio por ID
  Future<Reminder?> readReminder(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'reminders',
      columns: ['id', 'name', 'dateTime'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Reminder.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Leer todos los recordatorios
  Future<List<Reminder>> readAllReminders() async {
    final db = await instance.database;
    final result = await db.query('reminders', orderBy: 'dateTime ASC'); // Ordenar por fecha y hora
    return result.map((json) => Reminder.fromMap(json)).toList();
  }

  // Actualizar un recordatorio
  Future<int> update(Reminder reminder) async {
    final db = await instance.database;
    return db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // Eliminar un recordatorio
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cerrar la base de datos
  Future close() async {
    final db = await instance.database;
    _database = null; // Reiniciar para que se vuelva a inicializar si es necesario
    await db.close();
  }
}

// Extensión para que Reminder tenga un copyWith (opcional, pero útil)
extension on Reminder {
  Reminder copyWith({
    int? id,
    String? name,
    DateTime? dateTime,
  }) {
    return Reminder(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}