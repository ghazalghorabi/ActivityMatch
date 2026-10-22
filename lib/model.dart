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
  final String city;
  final String distance;
  final String address;
  final String placeId;
  final double? latitude;
  final double? longitude;
  final int participantCount;
  final List<String> tags;
  final String id;

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
    this.city = '',
    this.distance = '',
    this.address = '',
    this.placeId = '',
    this.latitude,
    this.longitude,
    this.participantCount = 0,
    this.tags = const [],
    this.id = '',
  });

  String get ageRange => '$minAge–$maxAge';

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
