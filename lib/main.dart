import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'base_widgets.dart';
import 'create_event_page.dart';
import 'event_data.dart';
import 'ticket_filter.dart';

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
      theme: AppTheme.dark,
      home: const TicketsPage(),
    );
  }
}

// ============================================================
// TICKETS PAGE
// ============================================================

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final searchController = TextEditingController();
  final ticketFilter = TicketFilter();

  int selectedNavigationIndex = 1;
  String selectedTicketCategory = 'Liked';
  bool isLiked = true;

  final ticketCategories = [
    'Liked',
    'Queued',
    'Attending',
    'Hosting',
  ];

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

            const SliverToBoxAdapter(
              child: SizedBox(height: 110),
            ),
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
        onAddPressed: _createEvent,
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _pageTitle() {
    return const Center(
      child: Text(
        'Your Tickets',
        style: AppTextStyles.pageTitle,
      ),
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
    if (selectedTicketCategory == 'Liked' && isLiked) {
      return EventCard(
        imageUrl:
            'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
        title: 'Beginner Padel Night',
        date: '15/10/2026',
        location: 'Padel Center',
        availableSpots: 2,
        showFavoriteButton: true,
        isLiked: true,
        onLikePressed: () {
          setState(() {
            isLiked = false;
          });
        },
        onTap: () {},
      );
    }

    if (selectedTicketCategory == 'Queued') {
      return EventCard(
        imageUrl:
            'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
        title: 'Beginner Padel Night',
        date: '15/10/2026',
        location: 'Padel Center',
        availableSpots: 0,
        queuePosition: 4,
        onTap: () {},
      );
    }

    if (selectedTicketCategory == 'Hosting') {
      final events = applyTicketFilters(
        EventData.hostedEvents,
        ticketFilter,
      );

      if (events.isEmpty) {
        return _emptyMessage('No hosted events');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your hosted events',
            style: AppTextStyles.sectionTitle,
          ),

          const SizedBox(height: AppSpacing.lg),

          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.lg,
              ),
              child: EventCard(
                imageUrl: event.imageUrl,
                title: event.title,
                date: event.formattedDate,
                location: event.location,
                availableSpots: event.availableSpots,
                onTap: () {},
              ),
            ),
          ),
        ],
      );
    }

    return _emptyMessage(
      'No $selectedTicketCategory events',
    );
  }

  Widget _emptyMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.huge,
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.emptyMessage,
        ),
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Future<void> _openFilter() async {
    final result = await showTicketFilter(
      context,
      ticketFilter,
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
      MaterialPageRoute(
        builder: (context) => const CreateEventPage(),
      ),
    );

    setState(() {});
  }
}