import 'package:flutter/material.dart';

import 'edit_profile_page.dart';
import 'app_bottom_navigation.dart';
import 'home_page.dart';
import 'notifications_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color backgroundColor = Color(0xFF120B06);
  static const Color cardColor = Color(0xFF211A15);
  static const Color orangeColor = Color(0xFFFFA33A);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'Guest';

    final userEmail = user?.email ?? 'Not signed in';
    final profileStream = user == null
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots();

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: profileStream,
          builder: (context, snapshot) {
            final data = snapshot.data?.data();

            final savedName = data?['name'] as String? ?? userName;
            final savedLocation = data?['location'] as String? ?? '';
            final savedBio = data?['bio'] as String? ?? '';
            final savedInterests = List<String>.from(data?['interests'] ?? []);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
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

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                savedName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      savedLocation.isEmpty
                                          ? 'Location not set'
                                          : savedLocation,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ), // Closes location Row
                            ], // Closes user information children
                          ), // Closes user information Column
                        ), // Closes Expanded
                      ], // Closes profile picture + information children
                    ), // Closes profile picture + information Row

                    const SizedBox(height: 20),

                    // BIO
                    Text(
                      savedBio.isEmpty
                          ? 'Your bio will appear here once you complete your profile.'
                          : savedBio,
                      style: const TextStyle(
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
                          style: TextStyle(color: Colors.white, fontSize: 15),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: savedInterests.isEmpty
                          ? [
                              const Text(
                                'No interests selected yet.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ]
                          : savedInterests.map((interest) {
                              IconData icon;

                              switch (interest) {
                                case 'Running':
                                  icon = Icons.directions_run;
                                  break;
                                case 'Padel':
                                  icon = Icons.sports_tennis;
                                  break;
                                case 'Coffee':
                                  icon = Icons.local_cafe;
                                  break;
                                case 'Hiking':
                                  icon = Icons.landscape;
                                  break;
                                case 'Food & Drinks':
                                  icon = Icons.restaurant;
                                  break;
                                case 'Travel':
                                  icon = Icons.flight;
                                  break;
                                default:
                                  icon = Icons.favorite_outline;
                              }

                              return InterestChip(icon: icon, text: interest);
                            }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) return;

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          'Log out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: cardColor,
                        ),
                      ),
                    ),
                  ],
                ), // Closes Column
              ), // Closes SingleChildScrollView
            ); // Ends the return Padding statement
          }, // Closes builder function
        ), // Closes StreamBuilder
      ), // Closes SafeArea
      // BOTTOM NAVIGATION
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 3),
    );
  }
}

// Widget for the interest buttons
class InterestChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InterestChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: ProfilePage.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ProfilePage.orangeColor, size: 18),
          const SizedBox(width: 7),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
