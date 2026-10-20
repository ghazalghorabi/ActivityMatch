import 'model.dart';

class EventData {
  static final List<ActivityEvent> events = [
    ActivityEvent(
      title: 'Beginner Padel Night',
      date: DateTime.parse('2026-10-15'),
      time: '18:00',
      location: 'Padel Center',
      city: 'Gothenburg',
      distance: '2.3 km',
      availableSpots: 2,
      participantCount: 6,
      capacity: 8,
      duration: '2h',
      minAge: 20,
      maxAge: 35,
      hostName: 'Emma',
      tags: ['Sports', 'Social', 'Beginner friendly'],
      activity: 'Sports',
      description:
          'A relaxed padel session for beginners and intermediate players. '
          'Meet new people, enjoy a fun game and afterwards we can grab a '
          'drink together nearby!',
      imageUrl:
          'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
    ),
    ActivityEvent(
      title: 'Friday Drinks',
      date: DateTime.parse('2026-10-17'),
      time: '20:00',
      location: 'City Centre',
      city: 'Stockholm',
      distance: '1.1 km',
      availableSpots: 3,
      participantCount: 5,
      capacity: 8,
      duration: '3h',
      minAge: 22,
      maxAge: 35,
      hostName: 'Lucas',
      tags: ['Nightlife', 'Drinks', 'Social'],
      activity: 'Nightlife',
      description:
          'Come meet some new people over drinks in the city. '
          'A casual evening with no pressure — just good conversation '
          'and a fun night out.',
      imageUrl:
          'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?w=1200',
    ),
    ActivityEvent(
      title: 'Morning Run',
      date: DateTime.parse('2026-10-18'),
      time: '10:00',
      location: 'Central Park',
      city: 'Gothenburg',
      distance: '3.4 km',
      availableSpots: 8,
      participantCount: 4,
      capacity: 12,
      duration: '1h',
      minAge: 18,
      maxAge: 40,
      hostName: 'Sara',
      tags: ['Sports', 'Outdoor', 'Beginner friendly'],
      activity: 'Sports',
      description:
          'Start the weekend with an easy social run. '
          'All running levels are welcome and we will grab coffee '
          'together afterwards.',
      imageUrl:
          'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=1200',
    ),
  ];

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
