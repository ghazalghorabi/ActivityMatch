import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'notifications_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});


  static const Color backgroundColor = Color(0xFF120B06);
  static const Color cardColor = Color(0xFF211A15);
  static const Color orangeColor = Color(0xFFFFA33A);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,


      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),


              // PROFILE TITLE
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 20),


              // PROFILE PICTURE + USER INFORMATION
              Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 55,
                          color: Colors.white,
                        ),
                      ),


                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: orangeColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(width: 18),


                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emma',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '23 years old',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Lund',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),


              const SizedBox(height: 20),


              // BIO
              const Text(
                'Just moved to Lund and excited to meet new people! '
                    'I love being active, trying new things and good coffee. '
                    'Always up for a fun activity and great company!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),


              const SizedBox(height: 18),


              // EDIT PROFILE BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 19,
                  ),
                  label: const Text(
                    'Edit profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: cardColor,
                  ),
                ),
              ),


              const SizedBox(height: 26),


              // INTERESTS
              const Text(
                'Interests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 12),


              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InterestChip(
                    icon: Icons.directions_run,
                    text: 'Running',
                  ),
                  InterestChip(
                    icon: Icons.sports_tennis,
                    text: 'Padel',
                  ),
                  InterestChip(
                    icon: Icons.local_cafe,
                    text: 'Coffee',
                  ),
                  InterestChip(
                    icon: Icons.landscape,
                    text: 'Hiking',
                  ),
                  InterestChip(
                    icon: Icons.restaurant,
                    text: 'Food & Drinks',
                  ),
                  InterestChip(
                    icon: Icons.flight,
                    text: 'Travel',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),


      // BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A130E),
        indicatorColor: const Color(0xFF573313),
        selectedIndex: 3,

        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsPage(),
              ),
            );
          }
        },

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


// Widget for the interest buttons
class InterestChip extends StatelessWidget {
  final IconData icon;
  final String text;


  const InterestChip({
    super.key,
    required this.icon,
    required this.text,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: ProfilePage.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: ProfilePage.orangeColor,
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

