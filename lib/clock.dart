import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ClockView extends StatefulWidget {
  final bool secondHand;

  const ClockView({Key? key, this.secondHand=true}) : super(key: key);

  @override
  _ClockViewState createState() => _ClockViewState(secondHand);
}

class _ClockViewState extends State<ClockView> {
  late Timer _timer;
  final bool _secondHand;

  _ClockViewState(this._secondHand);

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ClockPainter clockPainter = ClockPainter();
    clockPainter.setSecondHand(_secondHand);

    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Transform.rotate(
          angle: -pi / 2,
          child: CustomPaint(
            painter: clockPainter,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class ClockPainter extends CustomPainter {
  final dateTime = DateTime.now();
  bool _secondHand = true;

  void setSecondHand(bool secondHand) {
    _secondHand = secondHand;
  }

  void _drawFace(Canvas canvas, Offset center, double radius) {
    // Concentric circles
    // - where tick marks end   - radius
    // - where tick marks start - dashCircleInnerRadius
    // - face circle            - faceOutlineRadius
    // - center dot             - centerDotRadius
    final double dashCircleInnerRadius = radius * 0.9;
    final double faceOutlineRadius = dashCircleInnerRadius * 0.9;
    final double centerDotRadius = faceOutlineRadius * 0.1;

    // Draw the face background
    final Paint fillBrush = Paint()..color = const Color(0xFF444974);
    canvas.drawCircle(center, faceOutlineRadius, fillBrush);

    // draw the outline circle to the center area
    final Paint outlineBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = centerDotRadius;
    canvas.drawCircle(center, faceOutlineRadius, outlineBrush);

    // Draw the center dot
    final Paint centerDotBrush = Paint()..color = const Color(0xFFEAECFF);
    canvas.drawCircle(center, centerDotRadius, centerDotBrush);

    // Draw all the marks around the outside
    final double dashWidth = radius * 0.005;
    final Paint dashBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dashWidth;

    for (double i = 0; i < 360; i += 30) {
      // They end touching the outermost circle of radius `outerCircleRadius`
      final double x1 = center.dx + radius * cos(i * pi / 180);
      final double y1 = center.dy + radius * sin(i * pi / 180);

      // They start at the `dashCircleInnerRadius`
      final double x2 = center.dx + dashCircleInnerRadius * cos(i * pi / 180);
      final double y2 = center.dy + dashCircleInnerRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
  }

  void _drawHands(Canvas canvas, Offset center, double radius, DateTime time) {
    // Concentric circles
    final double secondHandLength = radius * 0.9;
    final double minuteHandLength = radius * 0.77;
    final double hourHandLength = radius * 0.55;

    final double hourHandWidth = radius * 0.07;
    final double minuteHandWidth = radius * 0.05;
    final double secondHandWidth = radius * 0.04;

    final Paint secHandBrush = Paint()
      ..color = const Color(0xFFFFA500)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = secondHandWidth;

    final Paint minHandBrush = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFF748EF6), Color(0xFF77DDFF)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = minuteHandWidth;

    final Paint hourHandBrush = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFFEA74AB), Color(0xFFC279FB)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = hourHandWidth;

    // Draw the Hour hand
    final double hourHandX = center.dx +
        hourHandLength * cos((time.hour * 30 + time.minute * 0.5) * pi / 180);
    final double hourHandY = center.dy +
        hourHandLength * sin((time.hour * 30 + time.minute * 0.5) * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    // Draw the minute hand
    final double minHandX = center.dx + minuteHandLength * cos(time.minute * 6 * pi / 180);
    final double minHandY = center.dy + minuteHandLength * sin(time.minute * 6 * pi / 180);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    // Draw the second hand
    if (_secondHand) {
      final double secHandX = center.dx + secondHandLength * cos(time.second * 6 * pi / 180);
      final double secHandY = center.dy + secondHandLength * sin(time.second * 6 * pi / 180);
      canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = min(centerX, centerY);

    _drawFace(canvas, center, radius);
    _drawHands(canvas, center, radius * 0.8, dateTime);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}