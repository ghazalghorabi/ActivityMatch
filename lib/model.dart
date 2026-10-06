// ============================================================
// ACTIVITY EVENT MODEL
// ============================================================

class ActivityEvent {
  final String title;
  final DateTime date;
  final String location;
  final int availableSpots;
  final String imageUrl;
  final String time;
  final String description;
  final String hostName;
  final String duration;
  final int minAge;
  final int maxAge;
  final int capacity;
  final String activity;

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
    required this.minAge,
    required this.maxAge,
    required this.capacity,
    required this.activity,
  });

  String get formattedDate =>
      '${date.day}/${date.month}/${date.year}';
}