
enum EventType { meeting }

class Event {
  DateTime start;
  DateTime end;
  EventType type;

  Event(this.start, this.end, {this.type = EventType.meeting});
}