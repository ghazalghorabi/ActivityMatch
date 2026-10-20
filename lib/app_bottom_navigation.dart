import 'package:flutter/material.dart';

import 'auth_guard.dart';
import 'base_widgets.dart';
import 'create_event_page.dart';
import 'home_page.dart';
import 'tickets_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNavigation({super.key, required this.selectedIndex});

  Future<void> _navigate(BuildContext context, int index) async {
    if (index == selectedIndex) return;

    if (index == 0) {
      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
        (route) => false,
      );
      return;
    }

    final loggedIn = await requireLogin(context);
    if (!loggedIn || !context.mounted) return;

    Widget destination;

    switch (index) {
      case 1:
        destination = const TicketsPage();
        break;
      case 2:
        destination = const NotificationsPage();
        break;
      case 3:
        destination = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
      (route) => false,
    );
  }

  Future<void> _openCreateEvent(BuildContext context) async {
    final loggedIn = await requireLogin(context);
    if (!loggedIn || !context.mounted) return;

    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreateEventPage()));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigation(
      selectedIndex: selectedIndex,
      onSelected: (index) => _navigate(context, index),
      onAddPressed: () => _openCreateEvent(context),
    );
  }
}
