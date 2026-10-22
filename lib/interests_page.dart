import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'looking_for_page.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  // One shared source for signup, onboarding and profile editing.
  static const List<String> interests = [
    'Running', 'Padel', 'Gym', 'Hiking', 'Coffee',
    'Food & Drinks', 'Travel', 'Gaming', 'Music', 'Movies',
  ];

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

// Shared selection widget. It does not own the selected values.
class InterestSelector extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final Iterable<String> additionalOptions;

  const InterestSelector({
    super.key,
    required this.selected,
    required this.onToggle,
    this.additionalOptions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final options = <String>{...InterestsPage.interests, ...additionalOptions};
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: options.map((interest) {
        final chosen = selected.contains(interest);
        return FilterChip(
          label: Text(interest),
          selected: chosen,
          showCheckmark: false,
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary,
          side: BorderSide.none,
          labelStyle: AppTextStyles.body.copyWith(
            color: chosen ? AppColors.textDark : AppColors.textPrimary,
            fontWeight: chosen ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (_) => onToggle(interest),
        );
      }).toList(),
    );
  }
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> selectedInterests = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pageHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Text('What are you interested in?', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.sm),
              const Text('Choose the interests that describe you.', style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.xxxl),
              InterestSelector(
                selected: selectedInterests,
                onToggle: (interest) => setState(() {
                  if (!selectedInterests.add(interest)) selectedInterests.remove(interest);
                }),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedInterests.isEmpty ? null : () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LookingForPage()));
                  },
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
