import 'package:flutter/material.dart';

void main() {
  runApp(const ActivityMatchApp());
}

class ActivityMatchApp extends StatelessWidget {
  const ActivityMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ActivityMatch',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF100D0B),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All activities';
  int selectedNavigationIndex = 0;

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

  final List<ActivityEvent> events = [
    ActivityEvent(
      title: 'Beginner Padel Night',
      date: 'Wed 15 Oct',
      time: '18:00',
      location: 'Padel Center',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100D0B),

      // This allows the page to continue behind the bottom navigation.
      extendBody: true,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // APP NAME
                  const Header(),

                  const SizedBox(height: 25),

                  // SEARCH BAR
                  SearchSection(
                    controller: searchController,
                    onFilterPressed: openFilters,
                    onSearch: (text) {
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 15),

                  // CATEGORIES
                  CategorySelector(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onSelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),

                  const SizedBox(height: 28),

                  // SUGGESTED EVENTS TITLE
                  SectionHeader(
                    title: 'Suggested events',
                    onViewAll: () {
                      debugPrint('View all suggested events');
                    },
                  ),

                  const SizedBox(height: 10),

                  // LARGE FEATURED EVENT
                  FeaturedEventCard(
                    onExplore: () {
                      debugPrint('Explore event');
                    },
                  ),

                  const SizedBox(height: 25),

                  // POPULAR EVENTS TITLE
                  SectionHeader(
                    title: 'Popular events',
                    onViewAll: () {
                      debugPrint('View all popular events');
                    },
                  ),

                  const SizedBox(height: 10),
                ]),
              ),
            ),

            // HORIZONTAL EVENT LIST
            SliverToBoxAdapter(
              child: SizedBox(
                height: 255,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 12);
                  },
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return EventCard(
                      event: event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(event: event),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Space so the floating bottom navigation does not
            // cover the last cards.
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedNavigationIndex,
        onSelected: (index) {
          setState(() {
            selectedNavigationIndex = index;
          });
        },
      ),
    );
  }

  // ============================================================
  // FILTER WINDOW
  // ============================================================

  void openFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const FilterSheet();
      },
    );
  }
}

// ============================================================
// EVENT MODEL
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

// ============================================================
// HEADER
// ============================================================

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'ActivityMatch',
        style: TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH BAR
// ============================================================

class SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterPressed;
  final ValueChanged<String> onSearch;

  const SearchSection({
    super.key,
    required this.controller,
    required this.onFilterPressed,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF292521),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 7),

          // Orange search icon
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 10),

          // Search text field
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearch,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search for events, venues, or more',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          // Filter button
          IconButton(
            onPressed: onFilterPressed,
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 23),
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORY SELECTOR
// ============================================================

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
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF211D19),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                    ? const Color(0xFF554E47)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        TextButton(
          onPressed: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LARGE FEATURED EVENT CARD
// ============================================================

class FeaturedEventCard extends StatelessWidget {
  final VoidCallback onExplore;

  const FeaturedEventCard({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF292521),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(
            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200',
            fit: BoxFit.cover,

            // If internet/image loading fails.
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF3A2E27),
                child: const Center(
                  child: Icon(Icons.event, size: 60, color: Colors.white24),
                ),
              );
            },
          ),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.90),
                  Colors.black.withOpacity(0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Event content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '20 Slots Available',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Where Every Night\nFinds Its Vibe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 9),

                const Text(
                  'Find events, connect, and\nenjoy every night easily.',
                  style: TextStyle(
                    color: Colors.white70,
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

// ============================================================
// SMALL EVENT CARD
// ============================================================

class EventCard extends StatefulWidget {
  final ActivityEvent event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Event image
              Image.network(
                widget.event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF302824),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white30,
                      ),
                    ),
                  );
                },
              ),

              // Gradient over image
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),

              // Date
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.event.date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Favorite button
              Positioned(
                right: 10,
                top: 8,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.25),
                  ),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? const Color(0xFFFF9800) : Colors.white,
                    size: 21,
                  ),
                ),
              ),

              // Event information
              Positioned(
                left: 14,
                right: 14,
                bottom: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),

                        const SizedBox(width: 3),

                        Expanded(
                          child: Text(
                            widget.event.location,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${widget.event.availableSpots} spots left',
                      style: const TextStyle(
                        color: Color(0xFFFFB13B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(28, 0, 28, 15),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xF22A211F),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavigationButton(
              icon: Icons.home_rounded,
              selected: selectedIndex == 0,
              onTap: () {
                onSelected(0);
              },
            ),

            NavigationButton(
              icon: Icons.local_activity_outlined,
              selected: selectedIndex == 1,
              onTap: () {
                onSelected(1);
              },
            ),

            NavigationButton(
              icon: Icons.notifications_none_rounded,
              selected: selectedIndex == 2,
              onTap: () {
                onSelected(2);
              },
            ),

            NavigationButton(
              icon: Icons.person_outline_rounded,
              selected: selectedIndex == 3,
              onTap: () {
                onSelected(3);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const NavigationButton({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected ? Colors.black : Colors.white70,
          size: 23,
        ),
      ),
    );
  }
}

// ============================================================
// FILTER BOTTOM SHEET
// ============================================================

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  double distance = 10;

  bool availableOnly = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF201B18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Filter events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Distance: ${distance.round()} km',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),

            Slider(
              value: distance,
              min: 1,
              max: 50,
              divisions: 49,
              activeColor: const Color(0xFFFF9800),
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
                style: TextStyle(color: Colors.white),
              ),
              activeColor: const Color(0xFFFF9800),
              value: availableOnly,
              onChanged: (value) {
                setState(() {
                  availableOnly = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Apply filters',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
  bool isLiked = false;
  bool hasJoined = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFF100D0B),
      body: Stack(
        children: [
          // --------------------------------------------------
          // SCROLLABLE PAGE
          // --------------------------------------------------

          CustomScrollView(
            slivers: [
              // HERO IMAGE
              SliverToBoxAdapter(child: _buildHero(event)),

              // EVENT INFORMATION
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildParticipants(event),

                    const SizedBox(height: 16),

                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildDateAndLocation(event),

                    const SizedBox(height: 20),

                    _buildTags(event),

                    const SizedBox(height: 30),

                    const Text(
                      'About this event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      event.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildHost(event),

                    const SizedBox(height: 25),

                    _buildInformationBox(event),
                  ]),
                ),
              ),
            ],
          ),

          // --------------------------------------------------
          // BOTTOM JOIN BAR
          // --------------------------------------------------
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(event),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HERO IMAGE
  // ==========================================================

  Widget _buildHero(ActivityEvent event) {
    return SizedBox(
      height: 390,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            event.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF2A211D),
                child: const Center(
                  child: Icon(
                    Icons.sports_tennis,
                    color: Colors.white24,
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
                  Colors.black.withOpacity(0.10),
                  Colors.transparent,
                  const Color(0xFF100D0B),
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
            child: _CircleButton(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                });
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

  Widget _buildParticipants(ActivityEvent event) {
    return Row(
      children: [
        // Fake profile circles for now.
        SizedBox(
          width: 145,
          height: 42,
          child: Stack(
            children: [
              _participantCircle(0, 'A', const Color(0xFFCA7B53)),
              _participantCircle(28, 'M', const Color(0xFF96705B)),
              _participantCircle(56, 'J', const Color(0xFF607D8B)),
              _participantCircle(84, 'S', const Color(0xFF795548)),

              Positioned(
                left: 112,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF39322E),
                    border: Border.all(
                      color: const Color(0xFF100D0B),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '+${event.participantCount > 4 ? event.participantCount - 4 : 0}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        Text(
          '${event.participantCount}/${event.capacity} going',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _participantCircle(double left, String letter, Color color) {
    return Positioned(
      left: left,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF100D0B), width: 2),
        ),
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DATE + LOCATION
  // ==========================================================

  Widget _buildDateAndLocation(ActivityEvent event) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white70,
              size: 21,
            ),

            const SizedBox(width: 9),

            Text(
              '${event.date} · ${event.time}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.white70,
              size: 21,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                '${event.location} · ${event.distance}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // TAGS
  // ==========================================================

  Widget _buildTags(ActivityEvent event) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: event.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2622),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            tag,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

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
            color: Color(0xFFBC7659),
          ),
          child: Text(
            event.hostName.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hosted by',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),

            const SizedBox(height: 2),

            Text(
              event.hostName,
              style: const TextStyle(
                color: Colors.white,
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
            style: TextStyle(color: Color(0xFFFF9800)),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // EVENT INFORMATION BOX
  // ==========================================================

  Widget _buildInformationBox(ActivityEvent event) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF211D1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              icon: Icons.people_outline,
              value: '${event.participantCount}/${event.capacity}',
              label: 'going',
            ),
          ),

          _divider(),

          Expanded(
            child: _InfoItem(
              icon: Icons.access_time_rounded,
              value: event.duration,
              label: 'Duration',
            ),
          ),

          _divider(),

          Expanded(
            child: _InfoItem(
              icon: Icons.group_outlined,
              value: event.ageRange,
              label: 'All genders',
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 45, color: Colors.white12);
  }

  // ==========================================================
  // BOTTOM BAR
  // ==========================================================

  Widget _buildBottomBar(ActivityEvent event) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xF5100D0B),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          // SPOTS LEFT
          Expanded(
            child: Container(
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF292522),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Text(
                '${event.availableSpots} spots left',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // JOIN BUTTON
          Expanded(
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasJoined = !hasJoined;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        hasJoined
                            ? 'You joined ${event.title}!'
                            : 'You left ${event.title}.',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: hasJoined
                      ? const Color(0xFF39332E)
                      : const Color(0xFFFF922E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  hasJoined ? 'Joined ✓' : "I'm in",
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
      color: Colors.black.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
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
        Icon(icon, color: Colors.white70, size: 23),

        const SizedBox(height: 7),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}
