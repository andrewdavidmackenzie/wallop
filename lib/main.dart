import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';

import './tray.dart';
import './clock.dart';

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
    var app = MaterialApp(
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

class _MainViewState extends State<MainView> with TrayListener {
  var tray = Tray();

  @override
  void initState() {
    tray.init(this);
    super.initState();
  }

  @override
  void dispose() {
    tray.dispose();
    super.dispose();
  }

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

  @override
  void onTrayIconMouseDown() {
    tray.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    tray.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    tray.onTrayMenuItemClick(menuItem);
  }
}