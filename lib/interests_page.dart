import 'package:flutter/material.dart';
import 'looking_for_page.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  static const Color backgroundColor = Color(0xFF120B06);
  static const Color cardColor = Color(0xFF211A15);
  static const Color orangeColor = Color(0xFFFFA33A);

  final List<String> interests = [
    'Running',
    'Padel',
    'Gym',
    'Hiking',
    'Coffee',
    'Food & Drinks',
    'Travel',
    'Gaming',
    'Music',
    'Movies',
  ];

  final Set<String> selectedInterests = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                'What are you interested in?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose the interests that describe you.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: interests.map((interest) {
                  final bool selected =
                  selectedInterests.contains(interest);

                  return FilterChip(
                    label: Text(interest),
                    selected: selected,
                    showCheckmark: false,
                    backgroundColor: cardColor,
                    selectedColor: orangeColor,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.black
                          : Colors.white,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedInterests.add(interest);
                        } else {
                          selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedInterests.isEmpty
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const LookingForPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: cardColor,
                    disabledForegroundColor: Colors.white38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}