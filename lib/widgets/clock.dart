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
    );
    TextSpan textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size * 2,
    );
    double textX = position.dx - textPainter.width/2;
    double textY = position.dy - textPainter.height/2;
    textPainter.paint(canvas, Offset(textX, textY));
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
  double _drawFace(Canvas canvas, Offset center, double radius) {
    // Concentric circles
    // - where tick marks end   - radius
    // - where tick marks start - dashCircleInnerRadius
    // - face circle            - faceOutlineRadius
    // - center dot             - centerDotRadius
    final double dashCircleInnerRadius = radius * 0.9;
    final double faceOutlineRadius = dashCircleInnerRadius * 0.9;
    final double centerDotRadius = faceOutlineRadius * 0.1;
    final double faceOutlineWidth = centerDotRadius;

    // Draw the face background
    final Paint fillBrush = Paint()..color = const Color(0xFF444974);
    canvas.drawCircle(center, faceOutlineRadius, fillBrush);

    // draw the outline circle to the center area
    final Paint outlineBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = faceOutlineWidth;
    canvas.drawCircle(center, faceOutlineRadius, outlineBrush);

    // Draw the center dot
    final Paint centerDotBrush = Paint()..color = const Color(0xFFEAECFF);
    canvas.drawCircle(center, centerDotRadius, centerDotBrush);

    // Draw all the marks around the outside
    final double dashWidth = radius * 0.005;
    final Paint dashBrush = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dashWidth;

    for (int hour = 1; hour < 13; hour += 1) {
      // They end touching the outermost circle of radius `outerCircleRadius`
      final double x1 = center.dx + radius * cos(_hoursAndMinutesToAngle(hour, 0));
      final double y1 = center.dy + radius * sin(_hoursAndMinutesToAngle(hour, 0));

      // They start at the `dashCircleInnerRadius`
      final double x2 =
          center.dx + dashCircleInnerRadius * cos(_hoursAndMinutesToAngle(hour, 0));
      final double y2 =
          center.dy + dashCircleInnerRadius * sin(_hoursAndMinutesToAngle(hour, 0));

      if (_dateTime.hour % 12 == hour) {
        _drawTextAt(canvas, hour.toString(), Offset((x1+x2)/2, (y1+y2)/2), 50, hourColor);
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

  Paint _brushFromEvent(Offset center, double radius, Event event) {
    return Paint()
      ..shader =
          const RadialGradient(colors: [Color(0x2FC5FFFA), Color(0x5F8BFFF7)])
              .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1;
  }

  // pre-conditions:
  //  - event.start is *after* from
  void _drawRemainingMinutes(
      Canvas canvas, Offset center, double radius, DateTime from, Event event) {
    Path path = Path();

    final double minHandX =
        center.dx + radius * cos(_minutesToAngle(from.minute));
    final double minHandY =
        center.dy + radius * sin(_minutesToAngle(from.minute));
    path.relativeMoveTo(minHandX, minHandY);

    bool largeArc = ((from.minute + 30) % 60) < event.start.minute;
    final double arcEndX =
        center.dx + radius * cos(_minutesToAngle(event.start.minute));
    final double arcEndY =
        center.dy + radius * sin(_minutesToAngle(event.start.minute));
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
      Canvas canvas, Offset center, double radius, DateTime from, Event event) {
    Path path = Path();

    final double hourHandX = center.dx +
        radius * cos(_hoursAndMinutesToAngle(from.hour, from.minute));
    final double hourHandY = center.dy +
        radius * sin(_hoursAndMinutesToAngle(from.hour, from.minute));
    path.relativeMoveTo(hourHandX, hourHandY);

    final double arcEndX = center.dx +
        radius * cos(_hoursAndMinutesToAngle(event.start.hour, event.start.minute));
    final double arcEndY = center.dy +
        radius * sin(_hoursAndMinutesToAngle(event.start.hour, event.start.minute));
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
      Canvas canvas, Offset center, double radius, DateTime from, List<Event> events) {
    if (events.isNotEmpty){
      if (from.add(const Duration(minutes: 60)).isAfter(events[0].start) && true) {
      // less that 60 minutes until the event
      _drawRemainingMinutes(canvas, center, radius, from, events[0]);
      } else {
      // more than 60minutes until the event
      _drawRemainingHours(canvas, center, radius * 0.7, from, events[0]);
      }
    }
  }

  void _drawEvent(Canvas canvas, Offset center, double radius, Event event) {
    // Convert event to a wedge
    Event wedge = _wedgeFromEvent(event);

    // Crate the Path from the Wedge
    Path path = Path();
    path.relativeMoveTo(center.dx, center.dy);

    final double wedgeStartX = center.dx +
        radius *
            cos(_hoursAndMinutesToAngle(wedge.start.hour, wedge.start.minute));
    final double wedgeStartY = center.dy +
        radius *
            sin(_hoursAndMinutesToAngle(wedge.start.hour, wedge.start.minute));
    path.lineTo(wedgeStartX, wedgeStartY);

    final double wedgeEndX = center.dx +
        radius * cos(_hoursAndMinutesToAngle(wedge.end.hour, wedge.end.minute));
    final double wedgeEndY = center.dy +
        radius * sin(_hoursAndMinutesToAngle(wedge.end.hour, wedge.end.minute));
    path.arcToPoint(Offset(wedgeEndX, wedgeEndY),
        radius: Radius.circular(radius), clockwise: true);

    path.close();

    final Paint wedgeBrush = _brushFromEvent(center, radius, event);

    canvas.drawPath(path, wedgeBrush);
  }

  void _drawEvents(
      Canvas canvas, Offset center, double radius, List<Event> events) {
    for (Event event in events) {
      _drawEvent(canvas, center, radius, event);
    }
  }

  void _drawTime(Canvas canvas, Offset center, double radius, DateTime time) {
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
              .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = minuteHandWidth;

    final Paint hourHandBrush = Paint()
      ..shader =
          const RadialGradient(colors: [Color(0xFFEA74AB), hourColor])
              .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = hourHandWidth;

    // Draw the Hour hand
    final double hourHandX = center.dx +
        hourHandLength * cos(_hoursAndMinutesToAngle(time.hour, time.minute));
    final double hourHandY = center.dy +
        hourHandLength * sin(_hoursAndMinutesToAngle(time.hour, time.minute));
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    // Draw the minute hand
    final double minHandX =
        center.dx + minuteHandLength * cos(_minutesToAngle(time.minute));
    final double minHandY =
        center.dy + minuteHandLength * sin(_minutesToAngle(time.minute));
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    // Draw the second hand
    if (secondHand) {
      final double secHandX =
          center.dx + secondHandLength * cos(_secondsToAngle(time.second));
      final double secHandY =
          center.dy + secondHandLength * sin(_secondsToAngle(time.second));
      canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = min(centerX, centerY);

    double faceRadius = _drawFace(canvas, center, radius);
    _drawEvents(canvas, center, faceRadius, _events);
    _drawRemaining(canvas, center, faceRadius * 0.75, _dateTime, _events);
    _drawTime(canvas, center, radius * 0.8, _dateTime);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return true;
  }
}
