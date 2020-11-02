import 'package:flutter/material.dart';

final List<EventColor> eventColors = [
  EventColor(id: 'white', name: 'white', color: Colors.white),
  EventColor(id: 'yellow', name: 'yellow', color: Colors.yellow),
  EventColor(id: 'red', name: 'red', color: Colors.red),
  EventColor(id: 'blue', name: 'blue', color: Colors.blue)
];

class EventColors {}

class EventColor {
  final id;
  final name;
  final color;

  EventColor({this.id, this.name, this.color});
}

final List<SelectedColor> selectedColors =
    eventColors.map((EventColor eventColor) {
  return SelectedColor(
    id: eventColor.id,
    color: eventColor.color,
  );
}).toList();

class SelectedColor {
  final id;
  Color color;

  SelectedColor({this.id, this.color});
}
