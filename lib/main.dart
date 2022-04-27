import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const Wallop());
}

class Wallop extends StatelessWidget {
  const Wallop({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

class ClockView extends StatefulWidget {
  const ClockView({Key? key}) : super(key: key);

  @override
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Transform.rotate(
        angle: -pi / 2,
        child: CustomPaint(
          painter: ClockPainter(),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  var dateTime = DateTime.now();

  void drawFace(Canvas canvas, Offset center, double radius) {
    // Concentric circles
    // - where tick marks end   - radius = 1.0
    // - where tick marks start - radius = 0.9
    // - face circle            - radius = 0.8
    // - center dot             - radius = 0.08
    var dashCircleInnerRadius = radius * 0.9;
    var faceOutlineRadius = radius * 0.8;
    var centerDotRadius = radius * 0.08;

    // Draw the face background
    var fillBrush = Paint()..color = const Color(0xFF444974);
    canvas.drawCircle(center, faceOutlineRadius, fillBrush);

    // draw the outline circle to the center area
    var outlineBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = centerDotRadius;
    canvas.drawCircle(center, faceOutlineRadius, outlineBrush);

    // Draw the center dot
    var centerDotBrush = Paint()..color = const Color(0xFFEAECFF);
    canvas.drawCircle(center, centerDotRadius, centerDotBrush);

    // Draw all the marks around the outside
    var dashWidth = radius * 0.005;
    var dashBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dashWidth;

    for (double i = 0; i < 360; i += 30) {
      // They end touching the outermost circle of radius `outerCircleRadius`
      var x1 = center.dx + radius * cos(i * pi / 180);
      var y1 = center.dy + radius * sin(i * pi / 180);

      // They start at the `dashCircleInnerRadius`
      var x2 = center.dx + dashCircleInnerRadius * cos(i * pi / 180);
      var y2 = center.dy + dashCircleInnerRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
  }

  void drawHands(Canvas canvas, Offset center, double radius) {
    // Concentric circles
    var secondHandLength = radius * 0.9;
    var minuteHandLength = radius * 0.77;
    var hourHandLength = radius * 0.55;

    var hourHandWidth = radius * 0.07;
    var minuteHandWidth = radius * 0.05;
    var secondHandWidth = radius * 0.04;

    var secHandBrush = Paint()
      ..color = const Color(0xFFFFA500)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = secondHandWidth;

    var minHandBrush = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFF748EF6), Color(0xFF77DDFF)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = minuteHandWidth;

    var hourHandBrush = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFFEA74AB), Color(0xFFC279FB)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = hourHandWidth;

    // Draw the Hour hand
    var hourHandX = center.dx +
        hourHandLength * cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    var hourHandY = center.dy +
        hourHandLength * sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    // Draw the minute hand
    var minHandX = center.dx + minuteHandLength * cos(dateTime.minute * 6 * pi / 180);
    var minHandY = center.dy + minuteHandLength * sin(dateTime.minute * 6 * pi / 180);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    // Draw the second hand
    var secHandX = center.dx + secondHandLength * cos(dateTime.second * 6 * pi / 180);
    var secHandY = center.dy + secondHandLength * sin(dateTime.second * 6 * pi / 180);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = min(centerX, centerY);

    drawFace(canvas, center, radius);
    drawHands(canvas, center, radius * 0.8);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}