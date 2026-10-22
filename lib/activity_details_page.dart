import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_theme.dart';
import 'model.dart';
import 'auth_guard.dart';
import 'edit_event_page.dart';

// ============================================================
// EVENT DETAILS PAGE
// ============================================================

class EventDetailsPage extends StatefulWidget {
  final ActivityEvent event;
  const EventDetailsPage({super.key, required this.event});
  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isJoining = false;
  bool isUpdatingLike = false;
  Future<void> joinEvent() async {
    if (isJoining) return;

    final loggedIn = await requireLogin(context);
    if (!mounted || !loggedIn) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final eventId = widget.event.id;

    if (eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This event cannot be joined yet.')),
      );
      return;
    }

    setState(() => isJoining = true);

    final firestore = FirebaseFirestore.instance;
    final eventRef = firestore.collection('events').doc(eventId);
    final attendeeRef = eventRef.collection('attendees').doc(user.uid);

    // Read the signed-in user's own profile before starting the transaction.
    String displayName = user.displayName?.trim() ?? '';
    try {
      final profile = await firestore.collection('users').doc(user.uid).get();
      final savedName = profile.data()?['name'];
      if (savedName is String && savedName.trim().isNotEmpty) {
        displayName = savedName.trim();
      }
    } catch (_) {
      // Firebase Auth display name is an acceptable fallback.
    }
    if (displayName.isEmpty) displayName = 'Attendee';

    try {
      await firestore.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventRef);
        final attendeeSnapshot = await transaction.get(attendeeRef);

        if (!eventSnapshot.exists) {
          throw Exception('This event no longer exists.');
        }

        if (attendeeSnapshot.exists) {
          throw Exception('You have already joined this event.');
        }

        final data = eventSnapshot.data()!;
        if ((data['status'] ?? 'active') != 'active') {
          throw Exception('This event has been cancelled.');
        }
        final availableSpots = (data['availableSpots'] as num).toInt();
        final participantCount = (data['participantCount'] as num).toInt();

        if (availableSpots <= 0) {
          throw Exception('This event is full.');
        }

        if (data['hostId'] == user.uid) {
          throw Exception('You cannot join your own event.');
        }

        transaction.set(attendeeRef, {
          'userId': user.uid,
          'displayName': displayName,
          'joinedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(eventRef, {
          'availableSpots': availableSpots - 1,
          'participantCount': participantCount + 1,
        });

        // Create a notification for the event host.
        final hostId = data['hostId'] as String;
        final eventTitle = data['title'] as String? ?? 'your event';

        final notificationRef = firestore
            .collection('users')
            .doc(hostId)
            .collection('notifications')
            .doc();

        transaction.set(notificationRef, {
          'type': 'event_joined',
          'title': 'New attendee!',
          'message': '$displayName joined $eventTitle.',
          'eventId': eventId,
          'actorId': user.uid,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('You joined the event!')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not join: $e')));
    } finally {
      if (mounted) {
        setState(() => isJoining = false);
      }
    }
  }

  Future<void> leaveEvent() async {
    if (isJoining) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.event.id.isEmpty) return;

    setState(() => isJoining = true);

    final firestore = FirebaseFirestore.instance;
    final eventRef = firestore.collection('events').doc(widget.event.id);
    final attendeeRef = eventRef.collection('attendees').doc(user.uid);

    try {
      await firestore.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventRef);
        final attendeeSnapshot = await transaction.get(attendeeRef);

        if (!eventSnapshot.exists) {
          throw Exception('This event no longer exists.');
        }

        if (!attendeeSnapshot.exists) {
          throw Exception('You are not attending this event.');
        }

        final data = eventSnapshot.data()!;
        final capacity = (data['capacity'] as num).toInt();
        final participantCount = (data['participantCount'] as num).toInt();
        final availableSpots = (data['availableSpots'] as num).toInt();

        if (participantCount <= 0 || availableSpots >= capacity) {
          throw Exception('The event attendance data is invalid.');
        }

        transaction.delete(attendeeRef);

        transaction.update(eventRef, {
          'participantCount': participantCount - 1,
          'availableSpots': availableSpots + 1,
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You have left the event.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not leave event: $e')));
    } finally {
      if (mounted) {
        setState(() => isJoining = false);
      }
    }
  }

  Future<void> toggleLike() async {
    if (isUpdatingLike) return;

    final loggedIn = await requireLogin(context);
    if (!mounted || !loggedIn) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final eventId = widget.event.id;

    if (eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This event cannot be saved yet.')),
      );
      return;
    }

    setState(() => isUpdatingLike = true);

    final likeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('likedEvents')
        .doc(eventId);

    try {
      final likeSnapshot = await likeRef.get();

      if (likeSnapshot.exists) {
        await likeRef.delete();
      } else {
        await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update like: $e')));
    } finally {
      if (mounted) {
        setState(() => isUpdatingLike = false);
      }
    }
  }

  bool isCancelling = false;

  Future<void> editEvent() async {
    if (widget.event.id.isEmpty) return;

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEventPage(eventId: widget.event.id),
      ),
    );
  }

  Future<void> cancelEvent() async {
    if (isCancelling || widget.event.id.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel event?'),
        content: const Text(
          'This event will be cancelled and all attendees '
          'will receive a notification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep event'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel event'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isCancelling = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final eventRef = firestore.collection('events').doc(widget.event.id);

      // Load attendees before creating the batch.
      final attendeesSnapshot = await eventRef.collection('attendees').get();

      // Keep the operation within Firestore batch limits.
      if (attendeesSnapshot.docs.length > 400) {
        throw Exception(
          'This event has too many attendees for '
          'a single cancellation batch.',
        );
      }

      final batch = firestore.batch();

      batch.update(eventRef, {'status': 'cancelled'});

      for (final attendee in attendeesSnapshot.docs) {
        final notificationRef = firestore
            .collection('users')
            .doc(attendee.id)
            .collection('notifications')
            .doc('cancel_${widget.event.id}');

        batch.set(notificationRef, {
          'type': 'event_cancelled',
          'title': 'Event cancelled',
          'message': '${widget.event.title} has been cancelled.',
          'eventId': widget.event.id,
          'actorId': user.uid,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event cancelled. Attendees have been notified.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not cancel event: $e')));
    } finally {
      if (mounted) {
        setState(() => isCancelling = false);
      }
    }
  }

  Widget _buildHostActions(ActivityEvent event) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || event.id.isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        if (data == null || data['hostId'] != user.uid) {
          return const SizedBox.shrink();
        }

        final cancelled = data['status'] == 'cancelled';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Manage your event',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (cancelled)
              const Text(
                'This event has been cancelled.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: editEvent,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Event'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isCancelling ? null : cancelEvent,
                icon: const Icon(Icons.event_busy_outlined),
                label: Text(isCancelling ? 'Cancelling...' : 'Cancel Event'),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final original = widget.event;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: original.id.isEmpty
          ? null
          : FirebaseFirestore.instance
                .collection('events')
                .doc(original.id)
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Could not load event.')),
          );
        }
        if (original.id.isNotEmpty && !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : const Text('Event not found.'),
            ),
          );
        }
        final data = snapshot.data?.data();
        if (original.id.isNotEmpty && data == null) {
          return const Scaffold(body: Center(child: Text('Event not found.')));
        }
        final title = data?['title'] as String? ?? original.title;
        final description =
            data?['description'] as String? ?? original.description;
        final location = data?['location'] as String? ?? original.location;
        final time = data?['time'] as String? ?? original.time;
        final date = (data?['date'] as Timestamp?)?.toDate() ?? original.date;
        final duration = data?['duration'] as String? ?? original.duration;
        final tags =
            (data?['tags'] as List?)?.whereType<String>().toList() ??
            original.tags;
        final minAge = (data?['minAge'] as num?)?.toInt();
        final maxAge = (data?['maxAge'] as num?)?.toInt();
        final ageRange = minAge == null || maxAge == null
            ? original.ageRange
            : '$minAge–${maxAge == 70 ? '70+' : maxAge} years';
        final cancelled = data?['status'] == 'cancelled';
        final participantCount =
            (data?['participantCount'] as num?)?.toInt() ??
            original.participantCount;
        final capacity =
            (data?['capacity'] as num?)?.toInt() ?? original.capacity;
        final user = FirebaseAuth.instance.currentUser;
        final isHost = user != null && data?['hostId'] == user.uid;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHero(original, imageUrl: data?['imageUrl'] as String? ?? original.imageUrl)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildParticipants(original),
                        const SizedBox(height: AppSpacing.lg),
                        if (cancelled) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: AppRadii.field,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'This event has been cancelled.',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildLiveDateAndLocation(date, time, location),
                        const SizedBox(height: AppSpacing.xl),
                        _buildLiveTags(tags),
                        const SizedBox(height: AppSpacing.huge),
                        const Text(
                          'About this event',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        _buildHost(original),
                        const SizedBox(height: AppSpacing.xl),
                        _buildLiveInformationBox(
                          participantCount,
                          capacity,
                          duration,
                          ageRange,
                        ),
                        if (isHost) _buildHostActions(original),
                      ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(original),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveDateAndLocation(
    DateTime date,
    String time,
    String location,
  ) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.textSecondary,
              size: 21,
            ),
            const SizedBox(width: 9),
            Text(
              '${date.day}/${date.month}/${date.year} · $time',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.textSecondary,
              size: 21,
            ),
            const SizedBox(width: 9),
            Expanded(child: Text(location, style: AppTextStyles.bodySecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveTags(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.chip,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(tag, style: AppTextStyles.filterChip),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLiveInformationBox(
    int participantCount,
    int capacity,
    String duration,
    String ageRange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppRadii.field,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              icon: Icons.people_outline,
              value: '$participantCount/$capacity',
              label: 'going',
            ),
          ),
          _divider(),
          Expanded(
            child: _InfoItem(
              icon: Icons.access_time_rounded,
              value: duration,
              label: 'Duration',
            ),
          ),
          _divider(),
          Expanded(
            child: _InfoItem(
              icon: Icons.group_outlined,
              value: ageRange,
              label: 'All genders',
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HERO IMAGE
  // ==========================================================
  Widget _buildHero(ActivityEvent event, {required String imageUrl}) {
    return SizedBox(
      height: 390,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceDark,
                child: const Center(
                  child: Icon(
                    Icons.sports_tennis,
                    color: AppColors.textDisabled,
                    size: 80,
                  ),
                ),
              );
            },
          ),
          // Dark gradient at bottom of photo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.overlayLight,
                  AppColors.transparent,
                  AppColors.background,
                ],
                stops: const [0, 0.65, 1],
              ),
            ),
          ),
          // BACK BUTTON
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 18,
            child: _CircleButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // LIKE BUTTON

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 70,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseAuth.instance.currentUser == null || event.id.isEmpty
                  ? null
                  : FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('likedEvents')
                        .doc(event.id)
                        .snapshots(),
              builder: (context, snapshot) {
                final liked = snapshot.data?.exists ?? false;

                return _CircleButton(
                  icon: liked ? Icons.favorite : Icons.favorite_border,
                  onPressed: toggleLike,
                );
              },
            ),
          ),

          // SHARE BUTTON
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 18,
            child: _CircleButton(
              icon: Icons.ios_share_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share functionality will be added later.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PARTICIPANTS
  // ==========================================================

  String _attendeeName(Map<String, dynamic> data) {
    final name = data['displayName'];
    return name is String && name.trim().isNotEmpty ? name.trim() : 'Attendee';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _showAttendees(String eventId) async {
    if (eventId.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Event attendees',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId)
                      .collection('attendees')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Could not load attendees.'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final attendees = snapshot.data!.docs;
                    if (attendees.isEmpty) {
                      return const Center(child: Text('No attendees yet.'));
                    }
                    return ListView.builder(
                      itemCount: attendees.length,
                      itemBuilder: (context, index) {
                        final name = _attendeeName(attendees[index].data());
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              _initials(name),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipants(ActivityEvent event) {
    if (event.id.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .collection('attendees')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Attendee list unavailable',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 42,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final attendees = snapshot.data!.docs;
        final preview = attendees.take(4).toList();
        return Row(
          children: [
            if (preview.isNotEmpty)
              SizedBox(
                width: preview.length * 28.0 + 12,
                height: 40,
                child: Stack(
                  children: [
                    for (var i = 0; i < preview.length; i++)
                      Positioned(
                        left: i * 28.0,
                        child: CircleAvatar(
                          radius: 19,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _initials(_attendeeName(preview[i].data())),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${attendees.length} attending',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () => _showAttendees(event.id),
              child: const Text('See all attendees'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // DATE + LOCATION
  // ==========================================================
  // ==========================================================
  // TAGS
  // ==========================================================
  // ==========================================================
  // HOST
  // ==========================================================
  Widget _buildHost(ActivityEvent event) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Text(
            (event.hostName.isNotEmpty ? event.hostName[0] : '?'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hosted by',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              event.hostName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text(
            'View profile',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // EVENT INFORMATION BOX
  // ==========================================================

  Widget _divider() {
    return Container(width: 1, height: 45, color: AppColors.border);
  }

  // ==========================================================
  // BOTTOM BAR
  // ==========================================================

  Widget _buildBottomBar(ActivityEvent event) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: event.id.isEmpty
          ? null
          : FirebaseFirestore.instance
                .collection('events')
                .doc(event.id)
                .snapshots(),
      builder: (context, eventSnapshot) {
        final eventData = eventSnapshot.data?.data();
        final spotsLeft =
            (eventData?['availableSpots'] as num?)?.toInt() ??
            event.availableSpots;

        final isHost = user != null && eventData?['hostId'] == user.uid;
        final isCancelled = eventData?['status'] == 'cancelled';

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: user == null || event.id.isEmpty
              ? null
              : FirebaseFirestore.instance
                    .collection('events')
                    .doc(event.id)
                    .collection('attendees')
                    .doc(user.uid)
                    .snapshots(),
          builder: (context, attendeeSnapshot) {
            final joined = attendeeSnapshot.data?.exists ?? false;
            final loading =
                isJoining ||
                (user != null &&
                    event.id.isNotEmpty &&
                    !attendeeSnapshot.hasData);

            final disabled =
                loading ||
                isHost ||
                (isCancelled && !joined) ||
                (!joined && spotsLeft <= 0) ||
                event.id.isEmpty;

            final buttonText = isHost
                ? 'Your event'
                : joined
                ? 'Leave event'
                : isCancelled
                ? 'Event cancelled'
                : spotsLeft <= 0
                ? 'Event full'
                : "I'm in";

            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.search,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '$spotsLeft spots left',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed: disabled
                            ? null
                            : joined
                            ? leaveEvent
                            : joinEvent,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: joined
                              ? AppColors.selectedTab
                              : AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          disabledBackgroundColor: AppColors.selectedTab,
                          disabledForegroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.search,
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                buttonText,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
// ============================================================
// ROUND BUTTON USED ON EVENT IMAGE
// ============================================================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleButton({required this.icon, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlayMedium,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}
// ============================================================
// INFORMATION ITEM
// ============================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _InfoItem({
    required this.icon,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 23),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.searchHint.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

