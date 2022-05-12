import 'package:flutter/material.dart';

import 'utils/menu.dart';
import 'widgets/clock.dart';
import 'models/event.dart';

import 'package:multi_window/multi_window.dart';
import 'package:multi_window/echo.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MultiWindow.init(args);
  runApp(const WallopApp());
}

class WallopApp extends StatelessWidget {
  const WallopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WallopMultiWindow(),
    );
  }
}

class WallopMultiWindow extends StatefulWidget {
  const WallopMultiWindow({Key? key}) : super(key: key);

  @override
  _WallopMultiWindowState createState() => _WallopMultiWindowState();
}

class _WallopMultiWindowState extends State<WallopMultiWindow> {
  final Menu _menu = Menu();
  MultiWindow? clock;
  MultiWindow? main;

  List<Event> events = [
//    Event(DateTime.now().add(const Duration(minutes: 15)), DateTime.now().add(const Duration(hours: 1)))
  ];

  @override
  void initState() {
    if (MultiWindow.current.key == 'main') {
      _menu.init(context);
    }

    MultiWindow.current.setTitle(MultiWindow.current.key);

    MultiWindow.current.events.listen((event) {
      echo('Received event: $event');
      setState(() {});
//      setState(() => events.add(event));
    });

    // Create the clock window or get a reference to it
    MultiWindow.create('clock').then((value) => setState(() => clock = value));
    // 'main' should be created - get a reference to it
    MultiWindow.create('main').then((value) => setState(() => main = value));

    super.initState();
  }

  @override
  void dispose() {
    if (MultiWindow.current.key == 'main') {
      _menu.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (MultiWindow.current.key) {
      case 'clock':
        return FutureBuilder<int>(
            future: MultiWindow.count(),
            builder: (context, snapshot) {
              return const Scaffold(
                  body: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Hello"),
                  ));
            });

      case 'main':
        return FutureBuilder<int>(
            future: MultiWindow.count(),
            builder: (context, snapshot) {
              return const Scaffold(
                  body: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Hello"),
                  ));
            });

      default:
        return const Text("Unknown App");
    }
  }
}