import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/event.dart';

class ClockView extends StatefulWidget {
  final bool secondHand;
  final List<Event> events;

  const ClockView({Key? key, this.secondHand = false, this.events = const []}) : super(key: key);

  @override
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {setState(() {});});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ClockPainter clockPainter = ClockPainter(widget.secondHand);
    clockPainter.setEvents(widget.events);
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomPaint(
            painter: clockPainter,
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
  static const hourColor = Color(0xFFC279FB);
  static const minuteColor = Color(0xFF77DDFF);
  static const tickColor = Color(0xFFEAECFF);

  final _dateTime = DateTime.now();
  final bool secondHand;
  List<Event> _events = [];
  ClockPainter(this.secondHand); // Drawing of second hand is optional

  void setEvents(List<Event> events) {
    _events = events;
  }

  void _drawTextAt(Canvas canvas, String text, Offset position,
      double size, Color color) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: size,
      letterSpacing: -0.02,
      leadingDistribution: TextLeadingDistribution.even
    );
    TextSpan textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
    );
    textPainter.layout();
    // We want text centered at position so we move text origin by half w/h
    textPainter.paint(canvas, Offset(position.dx - (textPainter.width/2.0), position.dy + 0.07));
  }

  double _hoursAndMinutesToAngle(int hour, int minutes) {
    return ((hour * 30 + minutes * 0.5) * pi / 180) - (pi / 2);
  }

  double _minutesToAngle(int minutes) {
    return (minutes * 6 * pi / 180) - (pi / 2);
  }

  double _secondsToAngle(int minutes) {
    return (minutes * 6 * pi / 180) - (pi / 2);
  }

  // Return the inner radius of the clock face where events can be drawn
  double _drawFace(Canvas canvas) {
    // Concentric circles
    const double dashCircleInnerRadius = 0.9;
    const double faceOutlineRadius = dashCircleInnerRadius * 0.9;
    const double centerDotRadius = faceOutlineRadius * 0.1;
    const double faceOutlineWidth = centerDotRadius;

    // Draw the face background
    final Paint fillBrush = Paint()..color = const Color(0xFF444974);
    canvas.drawCircle(Offset.zero, faceOutlineRadius, fillBrush);

    // draw the outline circle to the center area
    final Paint outlineBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = faceOutlineWidth;
    canvas.drawCircle(Offset.zero, faceOutlineRadius, outlineBrush);

    // Draw the center dot
    final Paint centerDotBrush = Paint()..color = const Color(0xFFEAECFF);
    canvas.drawCircle(Offset.zero, centerDotRadius, centerDotBrush);

    // Draw all the marks around the outside
    const double dashWidth = 0.005;
    final Paint dashBrush = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dashWidth;

    for (int hour = 1; hour < 13; hour += 1) {
      // They end touching the outermost circle of radius `outerCircleRadius`
      final double x1 = cos(_hoursAndMinutesToAngle(hour, 0));
      final double y1 = sin(_hoursAndMinutesToAngle(hour, 0));

      // They start at the `dashCircleInnerRadius`
      final double x2 = dashCircleInnerRadius * cos(_hoursAndMinutesToAngle(hour, 0));
      final double y2 = dashCircleInnerRadius * sin(_hoursAndMinutesToAngle(hour, 0));

      if (_dateTime.hour % 12 == hour) {
        _drawTextAt(canvas, hour.toString(), Offset((x1+x2)/2, (y1+y2)/2), 0.2, hourColor);
      } else {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
      }
    }

    return faceOutlineRadius;
  }

  // Limit start and end to the 12h on the clock and avoid overlap of start and end
  // post conditions:
  //  - end time must be after start time, but less than 12h after it
  Event _wedgeFromEvent(Event event) {
    return event;
  }

  Paint _brushFromEvent(double radius, Event event) {
    return Paint()
      ..shader =
          const RadialGradient(colors: [Color(0x2FC5FFFA), Color(0x5F8BFFF7)])
              .createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1;
  }

  // pre-conditions:
  //  - event.start is *after* from
  void _drawRemainingMinutes(
      Canvas canvas, double radius, DateTime from, Event event) {
    Path path = Path();

    final double minHandX = radius * cos(_minutesToAngle(from.minute));
    final double minHandY = radius * sin(_minutesToAngle(from.minute));
    path.relativeMoveTo(minHandX, minHandY);

    bool largeArc = ((from.minute + 30) % 60) < event.start.minute;
    final double arcEndX = radius * cos(_minutesToAngle(event.start.minute));
    final double arcEndY = radius * sin(_minutesToAngle(event.start.minute));
    path.arcToPoint(Offset(arcEndX, arcEndY),
        radius: Radius.circular(radius),
        largeArc: largeArc,
        clockwise: true);

    final Paint arcBrush = Paint()
      ..color = const Color(0xFF77DDFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1;

    canvas.drawPath(path, arcBrush);
  }

  // pre-conditions:
  //  - event.start is *after* from
  void _drawRemainingHours(
      Canvas canvas, double radius, DateTime from, Event event) {
    Path path = Path();

    final double hourHandX = radius * cos(_hoursAndMinutesToAngle(from.hour, from.minute));
    final double hourHandY = radius * sin(_hoursAndMinutesToAngle(from.hour, from.minute));
    path.relativeMoveTo(hourHandX, hourHandY);

    final double arcEndX = radius * cos(_hoursAndMinutesToAngle(event.start.hour, event.start.minute));
    final double arcEndY = radius * sin(_hoursAndMinutesToAngle(event.start.hour, event.start.minute));
    path.arcToPoint(Offset(arcEndX, arcEndY),
        radius: Radius.circular(radius), clockwise: true);

    final Paint arcBrush = Paint()
      ..color = hourColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1;

    canvas.drawPath(path, arcBrush);
  }

  // Draw a UI element to visually communicate how much time remains until
  // an upcoming event
  void _drawRemaining(
      Canvas canvas, double radius, DateTime from, List<Event> events) {
    if (events.isNotEmpty){
      if (from.add(const Duration(minutes: 60)).isAfter(events[0].start) && true) {
      // less that 60 minutes until the event
      _drawRemainingMinutes(canvas, radius, from, events[0]);
      } else {
      // more than 60minutes until the event
      _drawRemainingHours(canvas, radius * 0.7, from, events[0]);
      }
    }
  }

  void _drawEvent(Canvas canvas, double radius, Event event) {
    // Convert event to a wedge
    Event wedge = _wedgeFromEvent(event);

    // Crate the Path from the Wedge
    Path path = Path();
    path.relativeMoveTo(0, 0);

    final double wedgeStartX = radius *
            cos(_hoursAndMinutesToAngle(wedge.start.hour, wedge.start.minute));
    final double wedgeStartY = radius *
            sin(_hoursAndMinutesToAngle(wedge.start.hour, wedge.start.minute));
    path.lineTo(wedgeStartX, wedgeStartY);

    final double wedgeEndX = radius * cos(_hoursAndMinutesToAngle(wedge.end.hour, wedge.end.minute));
    final double wedgeEndY = radius * sin(_hoursAndMinutesToAngle(wedge.end.hour, wedge.end.minute));
    path.arcToPoint(Offset(wedgeEndX, wedgeEndY),
        radius: Radius.circular(radius), clockwise: true);

    path.close();

    final Paint wedgeBrush = _brushFromEvent(radius, event);

    canvas.drawPath(path, wedgeBrush);
  }

  void _drawEvents(
      Canvas canvas, double radius, List<Event> events) {
    for (Event event in events) {
      _drawEvent(canvas, radius, event);
    }
  }

  void _drawTime(Canvas canvas, double radius, DateTime time) {
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
      ..shader =
          const RadialGradient(colors: [Color(0xFF748EF6), minuteColor])
              .createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = minuteHandWidth;

    final Paint hourHandBrush = Paint()
      ..shader =
          const RadialGradient(colors: [Color(0xFFEA74AB), hourColor])
              .createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = hourHandWidth;

    // Draw the Hour hand
    final double hourHandX = hourHandLength * cos(_hoursAndMinutesToAngle(time.hour, time.minute));
    final double hourHandY = hourHandLength * sin(_hoursAndMinutesToAngle(time.hour, time.minute));
    canvas.drawLine(Offset.zero, Offset(hourHandX, hourHandY), hourHandBrush);

    // Draw the minute hand
    final double minHandX = minuteHandLength * cos(_minutesToAngle(time.minute));
    final double minHandY = minuteHandLength * sin(_minutesToAngle(time.minute));
    canvas.drawLine(Offset.zero, Offset(minHandX, minHandY), minHandBrush);

    // Draw the second hand
    if (secondHand) {
      final double secHandX = secondHandLength * cos(_secondsToAngle(time.second));
      final double secHandY = secondHandLength * sin(_secondsToAngle(time.second));
      canvas.drawLine(Offset.zero, Offset(secHandX, secHandY), secHandBrush);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    double radius = min(centerX, centerY);

    canvas.drawPaint(Paint()
      ..color = Colors.black);
    canvas.translate(centerX, centerY);
    canvas.scale(radius);

    double faceRadius = _drawFace(canvas);
    _drawEvents(canvas, faceRadius, _events);
    _drawRemaining(canvas, faceRadius * 0.75, _dateTime, _events);
    _drawTime(canvas, 0.8, _dateTime);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return true;
  }
}
