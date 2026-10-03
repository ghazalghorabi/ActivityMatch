import 'model.dart';

class EventData {
  static final List<ActivityEvent> hostedEvents = [];

  static void addEvent(ActivityEvent event) {
    hostedEvents.add(event);
  }

  static void removeEvent(ActivityEvent event) {
    hostedEvents.remove(event);
  }
}