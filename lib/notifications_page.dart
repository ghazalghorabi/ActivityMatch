import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_bottom_navigation.dart';
import 'home_page.dart';
import 'tickets_page.dart';
import 'profile_page.dart';
import 'auth_guard.dart';
import 'model.dart';
import 'activity_details_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const Color backgroundColor = AppColors.background;
  static const Color cardColor = AppColors.surface;
  static const Color orangeColor = AppColors.primary;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _markingAll = false;

  Future<void> _openNotification(
    String uid,
    String notificationId,
    Map<String, dynamic> notification,
  ) async {
    if (notification['read'] != true) {
      await _markAsRead(uid, notificationId);
    }

    if (!mounted) return;

    final eventId = notification['eventId'];

    if (eventId is! String || eventId.isEmpty) {
      return;
    }

    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (!mounted) return;

      if (!eventDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This event no longer exists.')),
        );
        return;
      }

      final data = eventDoc.data()!;

      final event = ActivityEvent(
        id: eventDoc.id,
        title: data['title'] as String? ?? 'Untitled event',
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        location: data['location'] as String? ?? '',
        availableSpots: (data['availableSpots'] as num?)?.toInt() ?? 0,
        imageUrl: data['imageUrl'] as String? ?? '',
        time: data['time'] as String? ?? '',
        description: data['description'] as String? ?? '',
        hostName: data['hostName'] as String? ?? 'Host',
        duration: data['duration'] as String? ?? '',
        minAge: (data['minAge'] as num?)?.toInt() ?? 18,
        maxAge: (data['maxAge'] as num?)?.toInt() ?? 70,
        capacity: (data['capacity'] as num?)?.toInt() ?? 0,
        activity: data['activity'] as String? ?? '',
        city: data['city'] as String? ?? '',
        distance: data['distance'] as String? ?? '',
        participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
        tags: (data['tags'] as List?)?.whereType<String>().toList() ?? [],
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open event: $error')));
    }
  }

  CollectionReference<Map<String, dynamic>> _notifications(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications');

  Future<void> _markAsRead(String uid, String notificationId) async {
    try {
      await _notifications(uid).doc(notificationId).update({'read': true});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not mark notification as read: $error')),
      );
    }
  }

  Future<void> _markAllAsRead(
    String uid,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (_markingAll) return;
    final unread = docs.where((doc) => doc.data()['read'] != true).toList();
    if (unread.isEmpty) return;

    setState(() => _markingAll = true);

    try {
      for (var start = 0; start < unread.length; start += 400) {
        final batch = FirebaseFirestore.instance.batch();
        final end = (start + 400 < unread.length) ? start + 400 : unread.length;

        for (final doc in unread.sublist(start, end)) {
          batch.update(_notifications(uid).doc(doc.id), {'read': true});
        }

        await batch.commit();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not mark all as read: $error')),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'event_joined':
        return Icons.group_outlined;
      case 'event_cancelled':
        return Icons.event_busy_outlined;
      case 'event_reminder':
        return Icons.event_available_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  String _timeLabel(dynamic value) {
    if (value is! Timestamp) return 'Just now';

    final date = value.toDate().toLocal();
    final elapsed = DateTime.now().difference(date);

    if (elapsed.isNegative || elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} min ago';
    if (elapsed.inHours < 24) return '${elapsed.inHours} hours ago';
    if (elapsed.inDays < 7) return '${elapsed.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: NotificationsPage.backgroundColor,
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text(
                  'Log in to see your notifications.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _notifications(user.uid)
                    .orderBy('createdAt', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final unreadCount = docs
                      .where((doc) => doc.data()['read'] != true)
                      .length;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Notifications',
                                style: AppTextStyles.pageTitle,
                              ),
                            ),
                            TextButton(
                              onPressed: unreadCount == 0 || _markingAll
                                  ? null
                                  : () => _markAllAsRead(user.uid, docs),
                              style: TextButton.styleFrom(
                                backgroundColor: NotificationsPage.cardColor,
                                foregroundColor: AppColors.textPrimary,
                              ),
                              child: Text(
                                _markingAll
                                    ? 'Updating...'
                                    : 'Mark all as read',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: snapshot.hasError
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'Could not load notifications:\n${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            : !snapshot.hasData
                            ? const Center(child: CircularProgressIndicator())
                            : docs.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      color: AppColors.primary,
                                      size: 52,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No notifications yet',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Updates about your activities will appear here.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  8,
                                  24,
                                  24,
                                ),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final data = doc.data();

                                  return NotificationCard(
                                    icon: _iconForType(
                                      data['type'] as String? ?? '',
                                    ),
                                    title:
                                        data['title'] as String? ??
                                        'Activity update',
                                    message: data['message'] as String? ?? '',
                                    time: _timeLabel(data['createdAt']),
                                    unread: data['read'] != true,
                                    onTap: () => _openNotification(
                                      user.uid,
                                      doc.id,
                                      data,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 2),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.onTap,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NotificationsPage.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: NotificationsPage.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: NotificationsPage.orangeColor, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
