import 'package:flutter/material.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});


  static const Color backgroundColor = Color(0xFF120B06);
  static const Color cardColor = Color(0xFF211A15);
  static const Color orangeColor = Color(0xFFFFA33A);


  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}


class _NotificationsPageState extends State<NotificationsPage> {
  final List<bool> unreadNotifications = [
    true,
    true,
    true,
    false,
    false,
    false,
    false,
  ];


  void markAsRead(int index) {
    setState(() {
      unreadNotifications[index] = false;
    });
  }


  void markAllAsRead() {
    setState(() {
      for (int i = 0; i < unreadNotifications.length; i++) {
        unreadNotifications[i] = false;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotificationsPage.backgroundColor,


      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  TextButton(
                    onPressed: markAllAsRead,
                    style: TextButton.styleFrom(
                      backgroundColor: NotificationsPage.cardColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 24),


              // TODAY
              const Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 12),


              NotificationCard(
                icon: Icons.group_outlined,
                title: 'New participant joined',
                message: 'Emma joined Padel Night',
                time: '5 min ago',
                unread: unreadNotifications[0],
                onTap: () {
                  markAsRead(0);
                },
              ),


              NotificationCard(
                icon: Icons.chat_bubble_outline,
                title: 'New message',
                message: 'You have a new message in Padel Night',
                time: '20 min ago',
                unread: unreadNotifications[1],
                onTap: () {
                  markAsRead(1);
                },
              ),


              NotificationCard(
                icon: Icons.event_available_outlined,
                title: 'Hiking Trip is starting soon',
                message: 'Remember to bring what you need',
                time: '1 hour ago',
                unread: unreadNotifications[2],
                onTap: () {
                  markAsRead(2);
                },
              ),


              const SizedBox(height: 20),


              // THIS WEEK
              const Text(
                'This week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 12),


              NotificationCard(
                icon: Icons.favorite_outline,
                title: 'You might like this activity',
                message: 'A new activity matches your interests',
                time: 'Yesterday',
                unread: unreadNotifications[3],
                onTap: () {
                  markAsRead(3);
                },
              ),


              NotificationCard(
                icon: Icons.schedule,
                title: 'Event reminder',
                message: 'Your event starts tomorrow',
                time: '2 days ago',
                unread: unreadNotifications[4],
                onTap: () {
                  markAsRead(4);
                },
              ),


              NotificationCard(
                icon: Icons.people_outline,
                title: '2 new people joined',
                message: 'Your event has new participants',
                time: '3 days ago',
                unread: unreadNotifications[5],
                onTap: () {
                  markAsRead(5);
                },
              ),


              const SizedBox(height: 20),


              // EARLIER
              const Text(
                'Earlier',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 12),


              NotificationCard(
                icon: Icons.star_outline,
                title: 'New events near you',
                message: 'See new activities around Lund',
                time: '1 week ago',
                unread: unreadNotifications[6],
                onTap: () {
                  markAsRead(6);
                },
              ),
            ],
          ),
        ),
      ),


      // BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A130E),
        indicatorColor: const Color(0xFF573313),
        selectedIndex: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}




// WIDGET FOR EACH NOTIFICATION
class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;


  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.onTap,
    this.unread = false,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NotificationsPage.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // ICON
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: NotificationsPage.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: NotificationsPage.orangeColor,
                size: 25,
              ),
            ),


            const SizedBox(width: 14),


            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                      unread ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),


                  const SizedBox(height: 3),


                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),


                  const SizedBox(height: 5),


                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),




            if (unread)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: NotificationsPage.orangeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


