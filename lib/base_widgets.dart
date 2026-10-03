import 'package:flutter/material.dart';
import 'model.dart';

const Color backgroundColor = Color(0xFF100D0B);


// ============================================================
// SEARCH
// ============================================================

class SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilterPressed;

  const SearchSection({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF292521),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 7),

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

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearch,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search for events, venues, or more',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          IconButton(
            onPressed: onFilterPressed,
            icon: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}


// ============================================================
// FILTER
// ============================================================

void openFilter(
  BuildContext context, {
  required Widget filterContent,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => filterContent,
  );
}


class FilterBase extends StatelessWidget {
  final Widget child;

  const FilterBase({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF201B18),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            child,
          ],
        ),
      ),
    );
  }
}


// ============================================================
// EVENT CARD
// ============================================================

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String location;
  final int availableSpots;
  final VoidCallback onTap;

  final double? width;
  final double height;

  final bool showFavoriteButton;
  final bool isLiked;
  final VoidCallback? onLikePressed;

  final int? queuePosition;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
    required this.availableSpots,
    required this.onTap,
    this.width,
    this.height = 255,
    this.showFavoriteButton = false,
    this.isLiked = false,
    this.onLikePressed,
    this.queuePosition,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
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
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              if (showFavoriteButton)
                Positioned(
                  right: 10,
                  top: 8,
                  child: IconButton(
                    onPressed: onLikePressed,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.25),
                    ),
                    icon: Icon(
                      isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isLiked
                          ? const Color(0xFFFF9800)
                          : Colors.white,
                      size: 21,
                    ),
                  ),
                ),

              Positioned(
                left: 14,
                right: 14,
                bottom: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                            location,
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
                      '$availableSpots spots left',
                      style: const TextStyle(
                        color: Color(0xFFFFB13B),
                        fontSize: 11,
                      ),
                    ),

                    if (queuePosition != null) ...[
                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white70,
                            size: 15,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            'Queue position: $queuePosition',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
          ),
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
            _navigationButton(
              Icons.home_rounded,
              0,
            ),
            _navigationButton(
              Icons.local_activity_outlined,
              1,
            ),
            _navigationButton(
              Icons.notifications_none_rounded,
              2,
            ),
            _navigationButton(
              Icons.person_outline_rounded,
              3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigationButton(
    IconData icon,
    int index,
  ) {
    final selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromARGB(125, 255, 255, 255)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected
              ? Colors.black
              : Colors.white70,
          size: 23,
        ),
      ),
    );
  }
}

