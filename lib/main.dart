import 'package:flutter/material.dart';

import 'utils/menu.dart';
import 'widgets/clock.dart';
import 'models/event.dart';

void main() => runApp(const Wallop());

class Wallop extends StatefulWidget {
  const Wallop({Key? key}) : super(key: key);

  @override
  _Wallop createState() => _Wallop();
}

class _Wallop extends State<Wallop> {
  final Menu _menu = Menu();

  List<Event> events = [
//    Event(DateTime.now().add(const Duration(minutes: 15)), DateTime.now().add(const Duration(hours: 1)))
  ];

  @override
  void initState() {
    _menu.init();
    super.initState();
  }

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MaterialApp app = const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ClockView(),
    );

    return app;
  }
}