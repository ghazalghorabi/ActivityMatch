import 'package:flutter/material.dart';

import 'base_widgets.dart';
import 'create_event_page.dart';
import 'event_data.dart';

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

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final searchController = TextEditingController();

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
                    onSearch: (text) {
                      setState(() {});
                    },
                    onFilterPressed: () {
                      openFilter(
                        context,
                        filterContent: _ticketFilter(),
                      );
                    },
                  ),

                  const SizedBox(height: 15),
                  _ticketCategorySelector(),
                  const SizedBox(height: 25),

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
      ),
    );
  }

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

  Widget _ticketContent() {
    if (selectedTicketCategory == 'Liked' && isLiked) {
      return EventCard(
        imageUrl:
            'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
        title: 'Beginner Padel Night',
        date: 'Wed 15 Oct',
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
        date: 'Wed 15 Oct',
        location: 'Padel Center',
        availableSpots: 0,
        queuePosition: 4,
        onTap: () {},
      );
    }

    if (selectedTicketCategory == 'Hosting') {
      return Column(
        children: [
          _hostingHeader(),
          const SizedBox(height: 15),

          ...EventData.hostedEvents.map((event) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: EventCard(
                imageUrl: event.imageUrl,
                title: event.title,
                date: event.date,
                location: event.location,
                availableSpots: event.availableSpots,
                onTap: () {},
              ),
            );
          }),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'No $selectedTicketCategory events',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _hostingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your hosted events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),

        GestureDetector(
          onTap: _createEvent,
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventPage(),
      ),
    );

    setState(() {});
  }

  Widget _ticketFilter() {
    return FilterBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter tickets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Ticket filters will go here',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 25),

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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}