import 'package:flutter/material.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Arial',
      ),
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
      backgroundColor: backgroundColor,
      extendBody: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _pageTitle(),
                  const SizedBox(height: 25),

                  SearchSection(
                    controller: searchController,
                    onSearch: (_) => setState(() {}),
                    onFilterPressed: _openFilter,
                  ),

                  const SizedBox(height: 15),

                  _ticketCategorySelector(),

                  const SizedBox(height: 10),

                  ActiveTicketFilters(
                    filter: ticketFilter,
                    onChanged: () => setState(() {}),
                  ),

                  const SizedBox(height: 20),

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
        style: TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ============================================================
  // TICKET CATEGORIES
  // ============================================================

  Widget _ticketCategorySelector() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF211D19),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
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
                      ? const Color(0xFF554E47)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white70,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),

          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
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
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
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