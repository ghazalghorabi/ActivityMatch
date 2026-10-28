import 'dart:math';

import 'package:flutter/material.dart';

import 'app_bottom_navigation.dart';
import 'app_theme.dart';
import 'base_widgets.dart';
import 'create_event_page.dart';
import 'tickets_page.dart';
import 'activity_details_page.dart';
import 'model.dart';
import 'event_data.dart';
import 'ticket_filter.dart';
import 'notifications_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'auth_guard.dart';
import 'profile_page.dart';
import 'event_categories.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Random _random = Random();
  final List<String> _randomEventIds = [];

  List<ActivityEvent> getRandomEvents(List<ActivityEvent> events) {
    final byId = {for (final event in events) event.id: event};
    final ids = byId.keys.toSet();
    _randomEventIds.removeWhere((id) => !ids.contains(id));
    final newIds = ids.where((id) => !_randomEventIds.contains(id)).toList()
      ..shuffle(_random);
    _randomEventIds.addAll(newIds);
    return [for (final id in _randomEventIds) byId[id]!];
  }

  Widget buildEventCard(ActivityEvent event, {double? width}) {
    return EventCard(
      width: width,
      height: AppSizes.eventCardHeight,
      imageUrl: event.imageUrl.isNotEmpty
          ? event.imageUrl
          : 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
      title: event.title,
      date: event.formattedDate,
      location: event.city.trim().isNotEmpty
          ? event.city.trim()
          : (event.address.trim().isNotEmpty
                ? event.address.split(',').first.trim()
                : event.location),
      availableSpots: event.availableSpots,
      showFavoriteButton: true,
      eventId: event.id,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
        );
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> openViewAll(String title, List<ActivityEvent> events) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllEventsPage(title: title, events: events),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget buildCarousel(List<ActivityEvent> events) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Text(
          'No events match your filters.',
          style: AppTextStyles.emptyMessage,
        ),
      );
    }

    return SizedBox(
      height: AppSizes.eventCardHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) => buildEventCard(events[index], width: 180),
      ),
    );
  }

  ActivityEvent eventFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    final savedCategory =
        data['category'] as String? ?? data['activity'] as String? ?? 'Other';

    final category = EventCategories.all.contains(savedCategory)
        ? savedCategory
        : 'Other';

    final tags = <String>[category];

    return ActivityEvent(
      id: document.id,
      title: data['title'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      city: data['city'] as String? ?? '',
      address: data['address'] as String? ?? '',
      placeId: data['placeId'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      distance: data['distance'] as String? ?? '',
      availableSpots: (data['availableSpots'] as num?)?.toInt() ?? 0,
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      duration: data['duration'] as String? ?? '',
      minAge: (data['minAge'] as num?)?.toInt() ?? 18,
      maxAge: (data['maxAge'] as num?)?.toInt() ?? 70,
      hostName: data['hostName'] as String? ?? 'Host',
      tags: tags,
      activity: category,
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All activities';
  int selectedNavigationIndex = 0;
  final exploreFilter = TicketFilter();

  final List<String> categories = ['All activities', ...EventCategories.all];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ActivityEvent> getRecommendedEvents(
    List<ActivityEvent> sourceEvents,
    List<String> interests,
    String userLocation,
  ) {
    final city = userLocation.trim().toLowerCase();

    final events = getFilteredEvents(sourceEvents).where((event) {
      if (city.isEmpty) return false;
      return event.city.trim().toLowerCase() == city;
    }).toList();

    final selectedInterests = interests
        .where((interest) => EventCategories.all.contains(interest))
        .toSet();

    int score(ActivityEvent event) {
      int total = 0;

      if (selectedInterests.contains(event.activity)) {
        total += 10;
      }

      if (event.availableSpots > 0) {
        total += 3;
      }

      final daysUntilEvent = event.date.difference(DateTime.now()).inDays;

      if (daysUntilEvent >= 0 && daysUntilEvent <= 7) {
        total += 2;
      }

      return total;
    }

    events.sort((a, b) {
      final scoreComparison = score(b).compareTo(score(a));

      if (scoreComparison != 0) {
        return scoreComparison;
      }

      return a.date.compareTo(b.date);
    });

    return events;
  }

  List<ActivityEvent> getFilteredEvents(List<ActivityEvent> sourceEvents) {
    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);

    return sourceEvents.where((event) {
      if (event.date.isBefore(currentDay)) return false;

      final place = exploreFilter.location.trim().toLowerCase();
      final matchesLocation =
          place.isEmpty ||
          event.city.toLowerCase().contains(place) ||
          event.location.toLowerCase().contains(place) ||
          event.address.toLowerCase().contains(place);

      final matchesCategory =
          selectedCategory == 'All activities' ||
          event.tags.contains(selectedCategory);

      final matchesAvailability =
          !exploreFilter.availableOnly || event.availableSpots > 0;

      final from = exploreFilter.startDate;
      final to = exploreFilter.endDate;
      final day = DateTime(event.date.year, event.date.month, event.date.day);

      final matchesDate =
          (from == null ||
              !day.isBefore(DateTime(from.year, from.month, from.day))) &&
          (to == null || !day.isAfter(DateTime(to.year, to.month, to.day)));

      final search = searchController.text.trim().toLowerCase();
      final matchesSearch =
          search.isEmpty ||
          event.title.toLowerCase().contains(search) ||
          event.location.toLowerCase().contains(search) ||
          event.city.toLowerCase().contains(search) ||
          event.tags.any((tag) => tag.toLowerCase().contains(search));

      return matchesLocation &&
          matchesCategory &&
          matchesAvailability &&
          matchesDate &&
          matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: user == null
          ? null
          : FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final interests = List<String>.from(data?['interests'] ?? []);
        final userLocation = data?['location'] as String? ?? '';

        debugPrint('PROFILE LOCATION: $userLocation');

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, eventsSnapshot) {
            if (eventsSnapshot.hasError) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Text('Could not load events: ${eventsSnapshot.error}'),
                ),
              );
            }

            if (!eventsSnapshot.hasData) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Hide cancelled events from discovery.
            // Older events without a status field remain active.
            final realEvents = eventsSnapshot.data!.docs
                .where((document) {
                  final status = document.data()['status'];
                  return status == null || status == 'active';
                })
                .map(eventFromFirestore)
                .toList();

            final randomEvents = getRandomEvents(realEvents);
            final filteredEvents = getFilteredEvents(randomEvents);

            final recommendedEvents = getRecommendedEvents(
              realEvents,
              interests,
              userLocation,
            );

            debugPrint(
              'RECOMMENDED CITIES: ${recommendedEvents.map((e) => e.city).toList()}',
            );

            final isAllActivities = selectedCategory == 'All activities';

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
                          const Header(),
                          const SizedBox(height: AppSpacing.xl),
                          SearchSection(
                            controller: searchController,
                            onFilterPressed: openFilters,
                            onSearch: (text) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          CategorySelector(
                            categories: categories,
                            selectedCategory: selectedCategory,
                            onSelected: (category) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          if (isAllActivities) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Explore events',
                                  style: AppTextStyles.sectionTitle,
                                ),
                                TextButton(
                                  onPressed: () => openViewAll(
                                    'Explore events',
                                    filteredEvents,
                                  ),
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ] else ...[
                            Text(
                              '$selectedCategory events',
                              style: AppTextStyles.sectionTitle,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ]),
                      ),
                    ),
                    if (isAllActivities) ...[
                      SliverToBoxAdapter(child: buildCarousel(filteredEvents)),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recommended for you',
                                style: AppTextStyles.sectionTitle,
                              ),
                              TextButton(
                                onPressed: () => openViewAll(
                                  'Recommended for you',
                                  recommendedEvents,
                                ),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.md),
                      ),
                      SliverToBoxAdapter(
                        child: buildCarousel(recommendedEvents),
                      ),
                    ] else if (filteredEvents.isEmpty)
                      const SliverPadding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'No events match your filters.',
                            style: AppTextStyles.emptyMessage,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.crossAxisExtent;
                            const columns = 2;
                            final cardWidth =
                                (availableWidth - AppSpacing.md) / 2;
                            final cardHeight = cardWidth * 1.38;

                            return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: AppSpacing.md,
                                    crossAxisSpacing: AppSpacing.md,
                                    mainAxisExtent: cardHeight,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    buildEventCard(filteredEvents[index]),
                                childCount: filteredEvents.length,
                              ),
                            );
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                ),
              ),
              bottomNavigationBar: const AppBottomNavigation(selectedIndex: 0),
            );
          },
        );
      },
    );
  }

  Future<void> openFilters() async {
    final result = await showTicketFilter(
      context,
      exploreFilter,
      isExplore: true,
    );
    if (!mounted || result == null) return;
    setState(() {});
  }
}

// Full event list opened from either carousel on the home page.
class AllEventsPage extends StatefulWidget {
  final String title;
  final List<ActivityEvent> events;

  const AllEventsPage({super.key, required this.title, required this.events});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final TextEditingController searchController = TextEditingController();
  final exploreFilter = TicketFilter();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ActivityEvent> get visibleEvents {
    final query = searchController.text.trim().toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return widget.events.where((event) {
      if (event.date.isBefore(today)) return false;

      final matchesSearch =
          query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.city.toLowerCase().contains(query) ||
          event.activity.toLowerCase().contains(query) ||
          event.tags.any((tag) => tag.toLowerCase().contains(query));

      final place = exploreFilter.location.trim().toLowerCase();
      final matchesLocation =
          place.isEmpty ||
          event.city.toLowerCase().contains(place) ||
          event.location.toLowerCase().contains(place) ||
          event.address.toLowerCase().contains(place);

      final matchesAvailability =
          !exploreFilter.availableOnly || event.availableSpots > 0;

      final from = exploreFilter.startDate;
      final to = exploreFilter.endDate;
      final day = DateTime(event.date.year, event.date.month, event.date.day);

      final matchesDate =
          (from == null ||
              !day.isBefore(DateTime(from.year, from.month, from.day))) &&
          (to == null || !day.isAfter(DateTime(to.year, to.month, to.day)));

      return matchesSearch &&
          matchesLocation &&
          matchesAvailability &&
          matchesDate;
    }).toList();
  }

  Future<void> openFilters() async {
    final result = await showTicketFilter(
      context,
      exploreFilter,
      isExplore: true,
    );
    if (!mounted || result == null) return;
    setState(() {});
  }

  Widget _eventCard(ActivityEvent event) {
    return EventCard(
      height: AppSizes.eventCardHeight,
      imageUrl: event.imageUrl.isNotEmpty
          ? event.imageUrl
          : 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
      title: event.title,
      date: event.formattedDate,
      location: event.city.trim().isNotEmpty
          ? event.city.trim()
          : (event.address.trim().isNotEmpty
                ? event.address.split(',').first.trim()
                : event.location),
      availableSpots: event.availableSpots,
      showFavoriteButton: true,
      eventId: event.id,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
        );
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = visibleEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: SearchSection(
                controller: searchController,
                onFilterPressed: openFilters,
                onSearch: (_) => setState(() {}),
              ),
            ),
          ),
          if (events.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.all(AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'No events match your filters.',
                  style: AppTextStyles.emptyMessage,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                100,
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final cardWidth = (width - AppSpacing.md) / 2;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: cardWidth * 1.38,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _eventCard(events[index]),
                      childCount: events.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text('ActivityMatch', style: AppTextStyles.pageTitle),
        ),
        const SizedBox(height: 12),
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (user == null) {
              return TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text('Log in / Sign up'),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.displayName ?? user.email ?? 'My account',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Log out'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.categorySelectorHeight,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.search,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 4);
        },
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              onSelected(category);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.selectedTab
                    : AppColors.transparent,
                borderRadius: AppRadii.tab,
              ),
              child: Text(
                category,
                style: isSelected
                    ? AppTextStyles.tabSelected
                    : AppTextStyles.tabUnselected,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View All', style: AppTextStyles.filterChip),
        ),
      ],
    );
  }
}

class FeaturedEventCard extends StatelessWidget {
  final VoidCallback onExplore;

  const FeaturedEventCard({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadii.card,
        color: AppColors.surface,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.cardFallback,
                child: const Center(
                  child: Icon(
                    Icons.event,
                    size: 60,
                    color: AppColors.textDisabled,
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.overlayDark,
                  AppColors.overlayMedium,
                  AppColors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '20 Slots Available',
                  style: AppTextStyles.eventSpots,
                ),
                const SizedBox(height: 8),
                Text(
                  'Where Every Night\nFinds Its Vibe',
                  style: AppTextStyles.eventTitle.copyWith(
                    fontSize: 21,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Find events, connect, and\nenjoy every night easily.',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onExplore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: AppColors.textDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.chip,
                      ),
                    ),
                    child: Text(
                      'Explore',
                      style: AppTextStyles.tabSelected.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
