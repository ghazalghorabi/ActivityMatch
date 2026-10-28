import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page.dart';
import 'app_bottom_navigation.dart';
import 'home_page.dart';
import 'app_theme.dart';
import 'event_categories.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static int calculateAge(DateTime birthDate, DateTime today) {
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day))
      age--;
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profileStream = user == null
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots();
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: profileStream,
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final fallbackName = user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : user?.email?.split('@').first ?? 'Guest';
            final name = data['name'] as String? ?? fallbackName;
            final location = data['location'] as String? ?? '';
            final bio = data['bio'] as String? ?? '';
            final interests = List<String>.from(data['interests'] ?? [])
                .where((interest) => EventCategories.all.contains(interest))
                .toList();
            final birthDate = data['birthDate'] is Timestamp
                ? (data['birthDate'] as Timestamp).toDate()
                : null;
            final age = birthDate == null
                ? null
                : calculateAge(birthDate, DateTime.now());
            return SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profile', style: AppTextStyles.pageTitle),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surface,
                        child: Icon(
                          Icons.person,
                          size: 55,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.eventTitle),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              user?.email ?? 'Not signed in',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 17,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    location.isEmpty
                                        ? 'Location not set'
                                        : location,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (age != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '$age years old',
                                style: AppTextStyles.bodySecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    bio.isEmpty
                        ? 'Your bio will appear here once you complete your profile.'
                        : bio,
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit profile'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.field,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const Text('Interests', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.md),
                  interests.isEmpty
                      ? const Text(
                          'No interests selected yet.',
                          style: AppTextStyles.bodySecondary,
                        )
                      : Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: interests
                              .map(
                                (interest) => InterestChip(
                                  icon: interestIcon(interest),
                                  text: interest,
                                ),
                              )
                              .toList(),
                        ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomePage()),
                          (_) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log out'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.field,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 3),
    );
  }

  static IconData interestIcon(String interest) {
    switch (interest) {
      case 'Sports':
        return Icons.sports_soccer;
      case 'Food & Drinks':
        return Icons.restaurant;
      case 'Outdoors':
        return Icons.landscape;
      case 'Entertainment':
        return Icons.movie;
      case 'Arts & Culture':
        return Icons.palette;
      case 'Social':
        return Icons.people_outline;
      case 'Wellness':
        return Icons.spa;
      case 'Travel':
        return Icons.flight;
      case 'Other':
        return Icons.category_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class InterestChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const InterestChip({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
