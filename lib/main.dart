import 'package:flutter/material.dart';

import 'utils/tray.dart';
import 'widgets/clock.dart';
import 'models/event.dart';

void main() => runApp(const Wallop());

class Wallop extends StatefulWidget {
  const Wallop({Key? key}) : super(key: key);

  @override
  _Wallop createState() => _Wallop();
}

class _Wallop extends State<Wallop> {
  final Tray _tray = Tray();

  List<Event> events = [
//    Event(DateTime.now().add(const Duration(minutes: 15)), DateTime.now().add(const Duration(hours: 1)))
  ];

  @override
  void initState() {
    _tray.init();
    super.initState();
  }

  @override
  void dispose() {
    _tray.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MaterialApp app = MaterialApp(
      title: 'Wallop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ClockView(),
    );

    return app;
  }
}