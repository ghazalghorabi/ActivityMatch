import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'base_widgets.dart';
import 'create_event_page.dart';
import 'model.dart';
import 'activity_details_page.dart';
import 'ticket_filter.dart';
import 'app_bottom_navigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================
// TICKETS PAGE
// ============================================================

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  ActivityEvent _eventFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    final activity = data['activity'] as String? ?? 'Other';

    final category = switch (activity) {
      'Padel' || 'Running' || 'Gym' => 'Sports',
      'Drinks' => 'Nightlife',
      'Coffee' => 'Food',
      'Gaming' => 'Games',
      'Walk' => 'Wellness',
      _ => 'Other',
    };

    return ActivityEvent(
      id: document.id,
      title: data['title'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
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
      activity: activity,
      city: data['city'] as String? ?? '',
      distance: data['distance'] as String? ?? '',
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      tags: <String>{
        category,
        activity,
        ...List<String>.from(data['tags'] ?? []),
      }.toList(),
    );
  }

  Widget _buildRealEventCard(ActivityEvent event, {bool isCancelled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: EventCard(
        imageUrl: event.imageUrl.isNotEmpty ? event.imageUrl : 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
        title: event.title,
        date: event.formattedDate,
        location: event.location,
        availableSpots: event.availableSpots,
        isCancelled: isCancelled,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
          );
          if (mounted) setState(() {});
        },
      ),
    );
  }

  final searchController = TextEditingController();
  final ticketFilter = TicketFilter();

  int selectedNavigationIndex = 1;
  String selectedTicketCategory = 'Liked';

  final ticketCategories = ['Liked', 'Queued', 'Attending', 'Hosting'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _pageTitle(),
                  const SizedBox(height: AppSpacing.sectionGap),

                  SearchSection(
                    controller: searchController,
                    onSearch: (_) => setState(() {}),
                    onFilterPressed: _openFilter,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _ticketCategorySelector(),

                  const SizedBox(height: AppSpacing.md),

                  ActiveTicketFilters(
                    filter: ticketFilter,
                    onChanged: () => setState(() {}),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _ticketContent(),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 1),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _pageTitle() {
    return const Center(
      child: Text('Your Tickets', style: AppTextStyles.pageTitle),
    );
  }

  // ============================================================
  // TICKET CATEGORIES
  // ============================================================

  Widget _ticketCategorySelector() {
    return Container(
      height: AppSizes.categorySelectorHeight,
      padding: const EdgeInsets.all(4),
      decoration: AppDecorations.categorySelector,
      child: Row(
        children: ticketCategories.map((category) {
          final selected = category == selectedTicketCategory;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTicketCategory = category;
                  if (category != 'Hosting' && ticketFilter.when == 'Cancelled')
                    ticketFilter.when = 'All';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.selectedTab
                      : AppColors.transparent,
                  borderRadius: AppRadii.tab,
                ),
                child: Text(
                  category,
                  style: selected
                      ? AppTextStyles.tabSelected
                      : AppTextStyles.tabUnselected,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // TICKET CONTENT
  // ============================================================

  Widget _ticketContent() {
    if (selectedTicketCategory == 'Liked') {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return _emptyMessage('Please log in to see your liked events');
      }

      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('likedEvents')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _emptyMessage(
              'Could not load liked events: ${snapshot.error}',
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final likedDocs = snapshot.data!.docs;

          if (likedDocs.isEmpty) {
            return _emptyMessage('No liked events yet');
          }

          return Column(
            children: likedDocs.map((likedDoc) {
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .doc(likedDoc.id)
                    .snapshots(),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.hasError) {
                    return _emptyMessage('Could not load a liked event');
                  }

                  if (!eventSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!eventSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final event = _eventFromFirestore(eventSnapshot.data!);
                  if (applyTicketFilters([event], ticketFilter).isEmpty)
                    return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: EventCard(
                      imageUrl: event.imageUrl.isNotEmpty ? event.imageUrl : 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
                      title: event.title,
                      date: event.formattedDate,
                      location: event.location,
                      availableSpots: event.availableSpots,
                      showFavoriteButton: true,
                      eventId: event.id,
                      isLiked: true,

                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailsPage(event: event),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      );
    }

    if (selectedTicketCategory == 'Attending') {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return _emptyMessage('Please log in to see your events');
      }

      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collectionGroup('attendees')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _emptyMessage(
              'Could not load attending events: ${snapshot.error}',
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendeeDocs = snapshot.data!.docs;

          if (attendeeDocs.isEmpty) {
            return _emptyMessage('No attending events yet');
          }

          return Column(
            children: attendeeDocs.map((attendeeDoc) {
              final eventRef = attendeeDoc.reference.parent.parent;

              if (eventRef == null) {
                return const SizedBox.shrink();
              }

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: eventRef.snapshots(),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.hasError) {
                    return _emptyMessage('Could not load an event');
                  }

                  if (!eventSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!eventSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final event = _eventFromFirestore(eventSnapshot.data!);
                  if (applyTicketFilters([event], ticketFilter).isEmpty)
                    return const SizedBox.shrink();

                  return _buildRealEventCard(event);
                },
              );
            }).toList(),
          );
        },
      );
    }

    if (selectedTicketCategory == 'Queued') {
      return _emptyMessage('No queued events yet');
    }

    if (selectedTicketCategory == 'Hosting') {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return _emptyMessage('Please log in to see your hosted events');
      }

      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('hostId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _emptyMessage(
              'Could not load hosted events: ${snapshot.error}',
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final events = docs.map(_eventFromFirestore).toList();
          final cancelledById = <String, bool>{
            for (final doc in docs) doc.id: doc.data()['status'] == 'cancelled',
          };

          final filteredEvents = applyTicketFilters(
            events,
            ticketFilter,
            isHosting: true,
            cancelledEventIds: cancelledById.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toSet(),
          );

          if (filteredEvents.isEmpty) {
            return _emptyMessage('No hosted events yet');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your hosted events',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...filteredEvents.map(
                (event) => _buildRealEventCard(
                  event,
                  isCancelled: cancelledById[event.id] ?? false,
                ),
              ),
            ],
          );
        },
      );
    }

    return _emptyMessage('No $selectedTicketCategory events');
  }

  Widget _emptyMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.huge),
      child: Center(child: Text(text, style: AppTextStyles.emptyMessage)),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Future<void> _openFilter() async {
    final result = await showTicketFilter(
      context,
      ticketFilter,
      isHosting: selectedTicketCategory == 'Hosting',
    );

    if (result != null) {
      setState(() {});
    }
  }

  // ============================================================
  // CREATE EVENT
  // ============================================================

  Future<void> _createEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventPage()),
    );

    setState(() {});
  }
}
