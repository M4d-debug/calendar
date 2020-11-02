import 'dart:ui';

class CalendarItem {
  static String table = "events";

  int id;
  String name;
  String date;
  String color;

  CalendarItem({this.id, this.name, this.date, this.color});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {'name': name, 'date': date, 'color': color};

    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  static CalendarItem fromMap(Map<String, dynamic> map) {
    return CalendarItem(
        id: map['id'],
        name: map['name'],
        date: map['date'],
        color: map['color']);
  }
}
