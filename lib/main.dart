import 'package:flutter/material.dart';

import './tray.dart';
import './clock.dart';
import 'event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Wallop());
}

class Wallop extends StatefulWidget {
  const Wallop({Key? key}) : super(key: key);

  @override
  _Wallop createState() => _Wallop();
}

class _Wallop extends State<Wallop> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MaterialApp app = MaterialApp(
      title: 'Wallop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainView(),
    );

    return app;
  }
}

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final Tray _tray = Tray();

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

  List<Event> events = [
//    Event(DateTime.now().add(const Duration(minutes: 15)), DateTime.now().add(const Duration(hours: 1)))
  ];

  @override
  Widget build(BuildContext context) {
    return
      SizedBox.expand(
        child: Container(
          alignment: Alignment.center,
          color: const Color(0xFF2D2F41),
          child: const ClockView(),
        ),
      );
  }
}