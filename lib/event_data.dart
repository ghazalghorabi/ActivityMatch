import 'model.dart';

class EventData {
  static final List<ActivityEvent> events = [];

  static final List<ActivityEvent> hostedEvents = [];
  static final Set<String> likedEvents = {};
  static final Set<String> attendingEvents = {};

  static void toggleLike(ActivityEvent event) {
    if (!likedEvents.add(event.title)) {
      likedEvents.remove(event.title);
    }
  }

  static void toggleJoin(ActivityEvent event) {
    if (!attendingEvents.add(event.title)) {
      attendingEvents.remove(event.title);
    }
  }

  static void addEvent(ActivityEvent event) {
    hostedEvents.add(event);
    events.add(event);
  }

  static void removeEvent(ActivityEvent event) {
    hostedEvents.remove(event);
    events.remove(event);
  }
}
