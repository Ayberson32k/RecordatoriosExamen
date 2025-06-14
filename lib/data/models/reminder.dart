class Reminder {
  int? id; 
  String name;
  DateTime dateTime; 

  Reminder({this.id, required this.name, required this.dateTime});


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateTime': dateTime.toIso8601String()
    };
  }

  
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      name: map['name'],
      dateTime: DateTime.parse(map['dateTime']), 
    );
  }


  @override
  String toString() {
    return 'Reminder{id: $id, name: $name, dateTime: $dateTime}';
  }
}