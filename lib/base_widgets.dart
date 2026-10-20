import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model.dart';
import 'app_theme.dart';

const Color backgroundColor = AppColors.background;

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
      height: AppSizes.searchHeight,
      decoration: AppDecorations.search,
      child: Row(
        children: [
          const SizedBox(width: 7),

          Container(
            width: AppSizes.searchIconSize,
            height: AppSizes.searchIconSize,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
              size: AppSizes.navigationIcon,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearch,
              style: AppTextStyles.searchInput,
              decoration: const InputDecoration(
                hintText: 'Search for events, venues, or more',
                hintStyle: AppTextStyles.searchHint,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          IconButton(
            onPressed: onFilterPressed,
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.textPrimary,
              size: AppSizes.navigationIcon,
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

void openFilter(BuildContext context, {required Widget filterContent}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (context) => filterContent,
  );
}

class FilterBase extends StatelessWidget {
  final Widget child;

  const FilterBase({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadii.bottomSheet,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppSizes.bottomSheetHandleWidth,
                height: AppSizes.bottomSheetHandleHeight,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

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
    this.height = AppSizes.eventCardHeight,
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
          borderRadius: AppRadii.card,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.cardFallback,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  );
                },
              ),

              Container(
                decoration: const BoxDecoration(
                  gradient: AppDecorations.eventGradient,
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
                    color: AppColors.overlayMedium,
                    borderRadius: AppRadii.chip,
                  ),
                  child: Text(date, style: AppTextStyles.eventDate),
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
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked
                          ? AppColors.primary
                          : AppColors.textPrimary,
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
                      style: AppTextStyles.eventTitle,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textSecondary,
                          size: 14,
                        ),

                        const SizedBox(width: AppSpacing.xxs),

                        Expanded(
                          child: Text(
                            location,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.eventLocation,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      '$availableSpots spots left',
                      style: AppTextStyles.eventSpots,
                    ),

                    if (queuePosition != null) ...[
                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.textSecondary,
                            size: 15,
                          ),

                          const SizedBox(width: AppSpacing.xs),

                          Text(
                            'Queue position: $queuePosition',
                            style: AppTextStyles.eventQueue,
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
  final VoidCallback onAddPressed;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        return SafeArea(
          minimum: AppSpacing.bottomNavigation,
          child: Container(
            height: AppSizes.navigationHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: AppDecorations.navigation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navigationButton(Icons.home_rounded, 0),

                _navigationButton(Icons.local_activity_outlined, 1),

                // CENTER ADD BUTTON
                GestureDetector(
                  onTap: onAddPressed,
                  child: Container(
                    width: AppSizes.navigationButton,
                    height: AppSizes.navigationButton,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.textPrimary,
                      size: AppSizes.addIcon,
                    ),
                  ),
                ),

                // NOTIFICATION BELL
                if (user == null)
                  _navigationButton(Icons.notifications_outlined, 2)
                else
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    key: ValueKey(user.uid),
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('notifications')
                        .where('read', isEqualTo: false)
                        .limit(1)
                        .snapshots(),
                    builder: (context, notificationSnapshot) {
                      final hasUnread =
                          notificationSnapshot.data?.docs.isNotEmpty ?? false;

                      return _navigationButton(
                        Icons.notifications_outlined,
                        2,
                        showDot: hasUnread,
                      );
                    },
                  ),

                _navigationButton(Icons.person_outline_rounded, 3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navigationButton(IconData icon, int index, {bool showDot = false}) {
    final selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: AppSizes.navigationButton,
        height: AppSizes.navigationButton,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.selectedNavigation
              : AppColors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.textDark : AppColors.textSecondary,
              size: AppSizes.navigationIcon,
            ),

            if (showDot && index == 2)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
