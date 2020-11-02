import 'dart:core';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_cal/calendar_model.dart';
import 'package:flutter_cal/db.dart';
import 'package:flutter_cal/event_colors.dart';
import 'package:flutter_cal/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import './event_colors.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDay = DateTime.now();

  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events = {};
  List<CalendarItem> _data = [];

  List<dynamic> _selectedEvents = [];
  List<Widget> get _eventWidgets =>
      _selectedEvents.map((e) => events(e)).toList();

  void initState() {
    super.initState();
    DB.init().then((value) => _fetchEvents());
    _calendarController = CalendarController();
  }

  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Widget events(var d) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          decoration: BoxDecoration(
              border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          )),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(d, style: Theme.of(context).primaryTextTheme.bodyText1),
            IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.trashAlt,
                  color: Colors.redAccent,
                  size: 15,
                ),
                onPressed: () => _deleteEvent(d))
          ])),
    );
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedDay = day;
      _selectedEvents = events;
    });
  }

  void _create(BuildContext context) {
    String _name = "";
    var content = TextField(
      style: GoogleFonts.montserrat(
          color: Color.fromRGBO(105, 105, 108, 1), fontSize: 16),
      autofocus: true,
      decoration: InputDecoration(
        labelStyle: GoogleFonts.montserrat(
            color: Color.fromRGBO(59, 57, 60, 1),
            fontSize: 18,
            fontWeight: FontWeight.normal),
        labelText: 'Event Name',
      ),
      onChanged: (value) {
        _name = value;
      },
    );
    var btn = FlatButton(
      child: Text('Save',
          style: GoogleFonts.montserrat(
              color: Color.fromRGBO(59, 57, 60, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      onPressed: () => _addEvent(_name),
    );
    var cancelButton = FlatButton(
        child: Text('Cancel',
            style: GoogleFonts.montserrat(
                color: Color.fromRGBO(59, 57, 60, 1),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.of(context).pop(false));

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text("Add Event",
                      style: GoogleFonts.montserrat(
                          color: Color.fromRGBO(59, 57, 60, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Container(padding: EdgeInsets.all(20), child: content),
                  ColorPicker(onColorSelect:
                      (Color colorSpectrum, SelectedColor selectedColor) {
                    setState(() {
                      eventDateColor = colorSpectrum;
                    });
                  }),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[btn, cancelButton]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchEvents() async {
    _events = {};
    List<Map<String, dynamic>> _results = await DB.query(CalendarItem.table);
    _data = _results.map((item) => CalendarItem.fromMap(item)).toList();
    _data.forEach((element) {
      DateTime formattedDate = DateTime.parse(DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(element.date.toString())));
      if (_events.containsKey(formattedDate)) {
        _events[formattedDate].add(
          element.name.toString() + element.date.toString(), 
        );
      } else {
        _events[formattedDate] = [element.name.toString() + element.date.toString()];
      }
    });
    setState(() {});
  }

  void _addEvent(String event) async {
    CalendarItem item = CalendarItem(
        date: _selectedDay.toString(),
        name: event,
        color: eventDateColor.toString(),);
    await DB.insert(CalendarItem.table, item);
    _selectedEvents.add(event);
    _fetchEvents();

    Navigator.pop(context);
  }

  void _deleteEvent(String s) {
    List<CalendarItem> d = _data.where((element) => element.name == s).toList();
    if (d.length == 1) {
      DB.delete(CalendarItem.table, d[0]);
      _selectedEvents.removeWhere((e) => e == s);
      _fetchEvents();
    }
  }

  var eventDateColor = Colors.white;

  Widget calendar() {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: eventDateColor,
            borderRadius: BorderRadius.circular(6),
            gradient:
                LinearGradient(colors: [Colors.red[600], Colors.red[400]]),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: new Offset(0.0, 5))
            ]),
        child: TableCalendar(
          calendarStyle: CalendarStyle(
            canEventMarkersOverflow: true,
            markersColor: eventDateColor,
            weekdayStyle: TextStyle(color: Colors.white),
            todayColor: Colors.white54,
            todayStyle: TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.bold),
            selectedColor: Colors.red[900],
            outsideWeekendStyle: TextStyle(color: Colors.white60),
            outsideStyle: TextStyle(color: Colors.white60),
            weekendStyle: TextStyle(color: Colors.white),
            renderDaysOfWeek: false,
          ),
          onDaySelected: _onDaySelected,
          calendarController: _calendarController,
          events: _events,
          headerStyle: HeaderStyle(
            leftChevronIcon:
                Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
            rightChevronIcon:
                Icon(Icons.arrow_forward_ios, size: 15, color: Colors.white),
            titleTextStyle:
                GoogleFonts.montserrat(color: Colors.white, fontSize: 16),
            formatButtonDecoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(20),
            ),
            formatButtonTextStyle: GoogleFonts.montserrat(
                color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ));
  }

  Widget eventTitle() {
    if (_selectedEvents.length == 0) {
      return Container(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
        child: Text("No events",
            style: Theme.of(context).primaryTextTheme.headline1),
      );
    }
    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
      child:
          Text("Events", style: Theme.of(context).primaryTextTheme.headline1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Calendar",
                    style: Theme.of(context).primaryTextTheme.headline1),
                Consumer<ThemeNotifier>(
                    builder: (context, notifier, child) => IconButton(
                        icon: notifier.isDarkTheme
                            ? FaIcon(
                                FontAwesomeIcons.moon,
                                size: 20,
                                color: Colors.white,
                              )
                            : Icon(Icons.wb_sunny),
                        onPressed: () => {notifier.toggleTheme()}))
              ],
            ),
          ),
          calendar(),
          eventTitle(),
          Column(children: _eventWidgets),
          SizedBox(height: 60)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _create(context),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ColorSpectrum extends StatefulWidget {
  const ColorSpectrum({
    Key key,
    @required this.colors,
  }) : super(key: key);

  final List<Color> colors;

  @override
  _ColorSpectrumState createState() => _ColorSpectrumState();
}

class _ColorSpectrumState extends State<ColorSpectrum> {
  @override
  Widget build(BuildContext context) {
    setState(() {});
    return GestureDetector(
      child: Container(
        width: 210,
        height: 14,
        decoration:
            BoxDecoration(gradient: LinearGradient(colors: widget.colors)),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  ColorPicker({this.onColorSelect});
  final Function(Color colorSpectrum, SelectedColor selectedColor)
      onColorSelect;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  void _selectColors(Offset touchPosition) {
    final RenderBox renderBox = context.findRenderObject();
    final int colorCount = selectedColors.length;
    final double blobDiamter = renderBox.size.height;
    final double blobRadius = blobDiamter / 2;
    final double separateSpace =
        (renderBox.size.width - (5 * blobDiamter)) / (colorCount - 1);

    final double touchX =
        touchPosition.dx.clamp(0, renderBox.size.width.toDouble());
    final double fractionTouchPosition =
        (max(touchX - blobRadius, 0.0) / (blobDiamter + separateSpace))
            .clamp(0.0, (colorCount - 1.0).toDouble());
    print(fractionTouchPosition);

    final int leftColorIndex = fractionTouchPosition.floor();
    final int rightColorIndex = fractionTouchPosition.ceil();
    final SelectedColor leftSelectedColor = selectedColors[leftColorIndex];

    final SelectedColor rightSelectedColor = selectedColors[rightColorIndex];

    print('Color: $leftColorIndex, $rightColorIndex');

    final SelectedColor selectedColor1 =
        (fractionTouchPosition - leftColorIndex) <= 0.5
            ? leftSelectedColor
            : rightSelectedColor;
    final Color spectrumColor = Color.lerp(leftSelectedColor.color,
        rightSelectedColor.color, fractionTouchPosition - leftColorIndex);

    if (widget.onColorSelect != null) {
      widget.onColorSelect(spectrumColor, selectedColor1);
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (DragDownDetails details) {
        _selectColors(details.localPosition);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _selectColors(details.localPosition);
      },
      child: ColorSpectrum(
          colors: selectedColors.map((SelectedColor selectedColor) {
        return selectedColor.color;
      }).toList()),
    );
  }
}
