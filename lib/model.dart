// ============================================================
// ACTIVITY EVENT MODEL
// ============================================================
class ActivityEvent {
  final String title;
  final String date;
  final String location;
  final int availableSpots;
  final String imageUrl;

  final String time;
  final String distance;
  final String description;
  final String hostName;
  final String duration;
  final String ageRange;
  final int participantCount;
  final int capacity;
  final List<String> tags;

  const ActivityEvent({
    required this.title,
    required this.date,
    required this.location,
    required this.availableSpots,
    required this.imageUrl,
    required this.time,
    required this.description,
    required this.hostName,
    required this.duration,
    required this.ageRange,
    required this.capacity,
    this.distance = '',
    this.participantCount = 0,
    this.tags = const [],
  });
}