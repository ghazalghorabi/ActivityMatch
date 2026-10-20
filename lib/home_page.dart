import 'package:flutter/material.dart';

import 'app_bottom_navigation.dart';
import 'app_theme.dart';
import 'base_widgets.dart';
import 'create_event_page.dart';
import 'tickets_page.dart';
import 'activity_details_page.dart';
import 'model.dart';
import 'event_data.dart';
import 'notifications_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'auth_guard.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ActivityEvent eventFromFirestore(
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

    final savedTags = List<String>.from(data['tags'] ?? []);
    final tags = <String>{category, activity, ...savedTags}.toList();

    return ActivityEvent(
      id: document.id,
      title: data['title'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      city: data['city'] as String? ?? '',
      distance: data['distance'] as String? ?? '',
      availableSpots: (data['availableSpots'] as num?)?.toInt() ?? 0,
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      duration: data['duration'] as String? ?? '',
      minAge: (data['minAge'] as num?)?.toInt() ?? 18,
      maxAge: (data['maxAge'] as num?)?.toInt() ?? 70,
      hostName: data['hostName'] as String? ?? 'Host',
      tags: tags,
      activity: activity,
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All activities';
  int selectedNavigationIndex = 0;
  String selectedCity = 'All cities';
  double selectedDistance = 50;
  bool availableOnly = false;
  final List<String> categories = [
    'All activities',
    'Sports',
    'Food',
    'Music',
    'Art',
    'Nightlife',
    'Games',
    'Wellness',
    'Other',
  ];
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ActivityEvent> getRecommendedEvents(
    List<ActivityEvent> sourceEvents,
    List<String> interests,
  ) {
    final events = List<ActivityEvent>.from(getFilteredEvents(sourceEvents));

    if (interests.isEmpty) return events;

    final normalizedInterests = interests
        .map((interest) => interest.trim().toLowerCase())
        .toSet();

    int score(ActivityEvent event) {
      return event.tags.where((tag) {
        return normalizedInterests.contains(tag.trim().toLowerCase());
      }).length;
    }

    events.sort((a, b) => score(b).compareTo(score(a)));

    return events;
  }

  List<ActivityEvent> getFilteredEvents(List<ActivityEvent> sourceEvents) {
    return sourceEvents.where((event) {
      final matchesCity =
          selectedCity == 'All cities' || event.city == selectedCity;
      final matchesCategory =
          selectedCategory == 'All activities' ||
          event.tags.contains(selectedCategory);
      final matchesAvailability = !availableOnly || event.availableSpots > 0;
      final search = searchController.text.trim().toLowerCase();
      final matchesSearch =
          search.isEmpty ||
          event.title.toLowerCase().contains(search) ||
          event.location.toLowerCase().contains(search) ||
          event.city.toLowerCase().contains(search) ||
          event.tags.any((tag) => tag.toLowerCase().contains(search));
      return matchesCity &&
          matchesCategory &&
          matchesAvailability &&
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

            final recommendedEvents = getRecommendedEvents(
              realEvents,
              interests,
            );

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
                          SectionHeader(
                            title: 'Suggested events',
                            onViewAll: () {
                              debugPrint('View all suggested events');
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FeaturedEventCard(
                            onExplore: () {
                              debugPrint('Explore event');
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            title: 'Events for you',
                            onViewAll: () {
                              debugPrint('View all popular events');
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ]),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppSizes.eventCardHeight,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendedEvents.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: AppSpacing.sm);
                          },
                          itemBuilder: (context, index) {
                            final event = recommendedEvents[index];
                            return EventCard(
                              width: 180,
                              height: AppSizes.eventCardHeight,
                              imageUrl: event.imageUrl.isNotEmpty
                                  ? event.imageUrl
                                  : 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
                              title: event.title,
                              date: event.formattedDate,
                              location: event.location,
                              availableSpots: event.availableSpots,
                              showFavoriteButton: true,
                              isLiked: EventData.likedEvents.contains(
                                event.title,
                              ),
                              onLikePressed: () async {
                                final loggedIn = await requireLogin(context);
                                if (!loggedIn || !mounted) return;

                                setState(() {
                                  EventData.toggleLike(event);
                                });
                              },
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailsPage(event: event),
                                  ),
                                );
                                if (mounted) setState(() {});
                              },
                            );
                          },
                        ),
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
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return FilterSheet(
          initialCity: selectedCity,
          initialDistance: selectedDistance,
          initialAvailableOnly: availableOnly,
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedCity = result['city'] as String;
        selectedDistance = result['distance'] as double;
        availableOnly = result['availableOnly'] as bool;
      });
    }
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

class FilterSheet extends StatefulWidget {
  final String initialCity;
  final double initialDistance;
  final bool initialAvailableOnly;
  const FilterSheet({
    super.key,
    required this.initialCity,
    required this.initialDistance,
    required this.initialAvailableOnly,
  });
  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String selectedCity;
  late double distance;
  late bool availableOnly;
  final List<String> cities = [
    'All cities',
    'Gothenburg',
    'Stockholm',
    'Malmö',
    'Copenhagen',
    'Oslo',
  ];
  @override
  void initState() {
    super.initState();
    selectedCity = widget.initialCity;
    distance = widget.initialDistance;
    availableOnly = widget.initialAvailableOnly;
  }

  @override
  Widget build(BuildContext context) {
    return FilterBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter events', style: AppTextStyles.filterTitle),
          const SizedBox(height: AppSpacing.xl),
          const Text('City', style: AppTextStyles.formLabel),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.field,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCity,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
                style: AppTextStyles.bodyLarge,
                items: cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (city) {
                  if (city == null) return;
                  setState(() {
                    selectedCity = city;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Distance: ${distance.round()} km',
            style: AppTextStyles.bodyLarge,
          ),
          Slider(
            value: distance,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                distance = value;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Only events with available spots',
              style: AppTextStyles.bodyLarge,
            ),
            activeColor: AppColors.primary,
            value: availableOnly,
            onChanged: (value) {
              setState(() {
                availableOnly = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSizes.primaryButtonHeight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'city': selectedCity,
                  'distance': distance,
                  'availableOnly': availableOnly,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: AppRadii.tab),
              ),
              child: const Text(
                'Apply filters',
                style: AppTextStyles.tabSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
