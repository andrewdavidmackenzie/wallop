@TestOn('mac-os')

import 'package:test/test.dart';
import 'package:wallop/widgets/clock.dart';

void main() {
  test("Test all hour and minute combinations in the day don't crash",
    testAllTimes);

  test("test an exact hour time is correct", () {
    ClockPainter painter = ClockPainter(false);
    DateTime time = DateTime(1966, 10, 11, 12, 0);
    String text = painter.timeToString(time);
    expect(text, "Twelve O'Clock");
  });

  test("test an 15 past is correct", () {
    ClockPainter painter = ClockPainter(false);
    DateTime time = DateTime(1966, 10, 11, 1, 15);
    String text = painter.timeToString(time);
    expect(text, "Quarter past One");
  });

  test("test 15 to is correct", () {
    ClockPainter painter = ClockPainter(false);
    DateTime time = DateTime(1966, 10, 11, 1, 45);
    String text = painter.timeToString(time);
    expect(text, "Quarter to Two");
  });
}

void testAllTimes() {
  ClockPainter painter = ClockPainter(false);

  for (int hour = 0; hour < 24; hour++) {
    for (int minute= 0; minute < 60; minute++) {
      DateTime time = DateTime(1966, 10, 11, hour, minute);
      String text = painter.timeToString(time);
    }
  }
}