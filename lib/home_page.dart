import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'base_widgets.dart';
import 'create_event_page.dart';
import 'tickets_page.dart';
import 'activity_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
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
  final Set<String> likedEvents = {};
  final List<ActivityEvent> events = [
    ActivityEvent(
      title: 'Beginner Padel Night',
      date: 'Wed 15 Oct',
      time: '18:00',
      location: 'Padel Center',
      city: 'Gothenburg',
      distance: '2.3 km',
      availableSpots: 2,
      participantCount: 6,
      capacity: 8,
      duration: '2h',
      ageRange: '20–35',
      hostName: 'Emma',
      tags: ['Sports', 'Social', 'Beginner friendly'],
      description:
          'A relaxed padel session for beginners and intermediate players. '
          'Meet new people, enjoy a fun game and afterwards we can grab a '
          'drink together nearby!',
      imageUrl:
          'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
    ),
    ActivityEvent(
      title: 'Friday Drinks',
      date: 'Fri 17 Oct',
      time: '20:00',
      location: 'City Centre',
      city: 'Stockholm',
      distance: '1.1 km',
      availableSpots: 3,
      participantCount: 5,
      capacity: 8,
      duration: '3h',
      ageRange: '22–35',
      hostName: 'Lucas',
      tags: ['Nightlife', 'Drinks', 'Social'],
      description:
          'Come meet some new people over drinks in the city. '
          'A casual evening with no pressure — just good conversation '
          'and a fun night out.',
      imageUrl:
          'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?w=1200',
    ),
    ActivityEvent(
      title: 'Morning Run',
      date: 'Sat 18 Oct',
      time: '10:00',
      location: 'Central Park',
      city: 'Gothenburg',
      distance: '3.4 km',
      availableSpots: 8,
      participantCount: 4,
      capacity: 12,
      duration: '1h',
      ageRange: '18–40',
      hostName: 'Sara',
      tags: ['Sports', 'Outdoor', 'Beginner friendly'],
      description:
          'Start the weekend with an easy social run. '
          'All running levels are welcome and we will grab coffee '
          'together afterwards.',
      imageUrl:
          'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=1200',
    ),
  ];
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  List<ActivityEvent> get filteredEvents {
    return events.where((event) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
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
                    title: 'Popular events',
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredEvents.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: AppSpacing.sm);
                  },
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                     return EventCard(
                       width: 180,
                       height: AppSizes.eventCardHeight,
                       imageUrl: event.imageUrl,
                       title: event.title,
                       date: event.date,
                       location: event.location,
                       availableSpots: event.availableSpots,
                       showFavoriteButton: true,
                       isLiked: likedEvents.contains(event.title),
                       onLikePressed: () => setState(() {
                         if (!likedEvents.add(event.title)) likedEvents.remove(event.title);
                       }),
                       onTap: () => Navigator.push(
                         context,
                         MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
                       ),
                     );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedNavigationIndex,
        onSelected: (index) {
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TicketsPage()),
          );
        } else {
          setState(() => selectedNavigationIndex = index);
        }
      },
      onAddPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateEventPage()),
        );
        if (mounted) setState(() {});
      },
      ),
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

class ActivityEvent {
  final String title;
  final String date;
  final String location;
  final String city;
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
    required this.city,
    required this.availableSpots,
    required this.imageUrl,
    this.time = '18:00',
    this.distance = '2.3 km',
    this.description = 'A relaxed activity for meeting new people. Come along, have fun and enjoy the activity together!',
    this.hostName = 'Emma',
    this.duration = '2h',
    this.ageRange = '20–35',
    this.participantCount = 6,
    this.capacity = 8,
    this.tags = const [],
  });
}

class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'ActivityMatch',
        style: AppTextStyles.pageTitle,
      ),
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
                style: isSelected ? AppTextStyles.tabSelected : AppTextStyles.tabUnselected,
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
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text(
            'View All',
            style: AppTextStyles.filterChip,
          ),
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
                  child: Icon(Icons.event, size: 60, color: AppColors.textDisabled),
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
                  style: AppTextStyles.eventTitle.copyWith(fontSize: 21, height: 1.15),
                ),
                const SizedBox(height: 9),
                Text(
                  'Find events, connect, and\nenjoy every night easily.',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 12, height: 1.4),
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
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.chip,
                      ),
                    ),
                    child: Text(
                      'Explore',
                      style: AppTextStyles.tabSelected.copyWith(color: AppColors.textDark),
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
            const Text(
              'Filter events',
              style: AppTextStyles.filterTitle,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'City',
              style: AppTextStyles.formLabel,
            ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.tab,
                  ),
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
