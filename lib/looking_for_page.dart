import 'package:flutter/material.dart';

class LookingForPage extends StatefulWidget {
  const LookingForPage({super.key});

  @override
  State<LookingForPage> createState() => _LookingForPageState();
}

class _LookingForPageState extends State<LookingForPage> {
  static const Color backgroundColor = Color(0xFF120B06);
  static const Color cardColor = Color(0xFF211A15);
  static const Color orangeColor = Color(0xFFFFA33A);

  final List<String> options = [
    'Make new friends',
    'Find activity partners',
    'Try new activities',
    'Meet other singles',
    'Join social events',
    'Meet people with similar interests',
  ];

  final Set<String> selectedOptions = {};

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
                'What are you looking for?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose what you would like to get out of ActivityMatch.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((option) {
                  final bool selected =
                  selectedOptions.contains(option);

                  return FilterChip(
                    label: Text(option),
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
                          selectedOptions.add(option);
                        } else {
                          selectedOptions.remove(option);
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
                  onPressed: selectedOptions.isEmpty
                      ? null
                      : () {
                    // Next onboarding page comes here.
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