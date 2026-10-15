import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'home_page.dart' show ActivityEvent;

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
      backgroundColor: AppColors.background,
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
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDateAndLocation(event),
                    const SizedBox(height: AppSpacing.xl),
                    _buildTags(event),
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
                      event.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    _buildHost(event),
                    const SizedBox(height: AppSpacing.xl),
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
              _participantCircle(0, 'A', AppColors.primary),
              _participantCircle(28, 'M', AppColors.surface),
              _participantCircle(56, 'J', AppColors.surfaceDark),
              _participantCircle(84, 'S', AppColors.cardFallback),
              Positioned(
                left: 112,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.selectedTab,
                    border: Border.all(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '+${event.participantCount > 4 ? event.participantCount - 4 : 0}',
                    style: AppTextStyles.eventDate,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '${event.participantCount}/${event.capacity} going',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
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
          border: Border.all(color: AppColors.background, width: 2),
        ),
        child: Text(
          letter,
          style: const TextStyle(
            color: AppColors.textPrimary,
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
              color: AppColors.textSecondary,
              size: 21,
            ),
            const SizedBox(width: 9),
            Text(
              '${event.date} · ${event.time}',
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
            Expanded(
              child: Text(
                '${event.location} · ${event.distance}',
                style: AppTextStyles.bodySecondary,
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
            color: AppColors.surface,
            borderRadius: AppRadii.chip,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            tag,
            style: AppTextStyles.filterChip,
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
  Widget _buildInformationBox(ActivityEvent event) {
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
    return Container(width: 1, height: 45, color: AppColors.border);
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
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          // SPOTS LEFT
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
                '${event.availableSpots} spots left',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                      ? AppColors.selectedTab
                      : AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.search,
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