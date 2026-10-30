import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_theme.dart';
import 'interests_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final Set<String> selectedInterests = {};
  static const List<String> swedishCities = [
    'Göteborg',
    'Stockholm',
    'Malmö',
    'Uppsala',
    'Linköping',
    'Västerås',
    'Örebro',
    'Helsingborg',
    'Jönköping',
    'Norrköping',
    'Lund',
    'Umeå',
    'Gävle',
    'Borås',
    'Eskilstuna',
    'Södertälje',
    'Karlstad',
    'Täby',
    'Halmstad',
    'Växjö',
    'Sundsvall',
    'Luleå',
    'Trollhättan',
    'Östersund',
    'Borlänge',
    'Falun',
    'Kalmar',
    'Skövde',
    'Kristianstad',
    'Karlskrona',
    'Uddevalla',
    'Varberg',
    'Kungsbacka',
    'Alingsås',
    'Kungälv',
    'Mölndal',
    'Partille',
    'Lerum',
    'Lidköping',
    'Mariestad',
    'Nyköping',
    'Nässjö',
    'Motala',
    'Piteå',
    'Skellefteå',
    'Örnsköldsvik',
    'Visby',
    'Ystad',
    'Trelleborg',
    'Landskrona',
    'Ängelholm',
    'Falkenberg',
    'Enköping',
    'Sala',
    'Arvika',
    'Kiruna',
    'Gällivare',
    'Marstrand',
  ];
  DateTime? birthDate;
  bool isLoading = false;

  String formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> pickBirthDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          birthDate ?? DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null && mounted) setState(() => birthDate = picked);
  }

  String? requiredValue(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> signUp() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }
    if (!swedishCities.contains(locationController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a city from the suggestions.'),
        ),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final name = nameController.text.trim();
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );
      final user = credential.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': emailController.text.trim(),
        'location': locationController.text.trim(),
        'birthDate': Timestamp.fromDate(birthDate!),
        'interests': selectedInterests.toList(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.updateDisplayName(name);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not create account.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your profile: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget citySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        requiredLabel('Location'),
        const SizedBox(height: AppSpacing.fieldLabelBottom),

        Autocomplete<String>(
          optionsBuilder: (TextEditingValue value) {
            final query = value.text.trim().toLowerCase();

            if (query.isEmpty) {
              return swedishCities;
            }

            return swedishCities.where(
              (city) => city.toLowerCase().contains(query),
            );
          },

          onSelected: (String city) {
            locationController.text = city;
          },

          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: AppTextStyles.bodyLarge,
                  decoration: AppInputs.field(
                    hint: 'Search for your city',
                    icon: Icons.location_city_outlined,
                  ),
                  onChanged: (_) {
                    // Typing invalidates the previous selection.
                    locationController.clear();
                  },
                );
              },
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget requiredLabel(String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: AppTextStyles.formLabel),
      Text(
        ' *',
        style: AppTextStyles.formLabel.copyWith(color: AppColors.primary),
      ),
    ],
  );

  Widget field(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        requiredLabel(label),
        const SizedBox(height: AppSpacing.fieldLabelBottom),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: AppTextStyles.bodyLarge,
          decoration: AppInputs.field(hint: hint),
          validator: validator ?? requiredValue,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account', style: AppTextStyles.pageTitle),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field('Name', nameController, 'Enter your name'),
              requiredLabel('Date of birth'),
              const SizedBox(height: AppSpacing.fieldLabelBottom),
              FormField<DateTime>(
                validator: (_) =>
                    birthDate == null ? 'Date of birth is required' : null,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: pickBirthDate,
                      child: InputDecorator(
                        decoration: AppInputs.field(
                          hint: 'Select your date of birth',
                          icon: Icons.calendar_today_outlined,
                        ).copyWith(errorText: state.errorText),
                        child: Text(
                          birthDate == null
                              ? 'Select your date of birth'
                              : formatDate(birthDate!),
                          style: birthDate == null
                              ? AppTextStyles.bodySecondary
                              : AppTextStyles.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              citySelector(),
              field(
                'Email',
                emailController,
                'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (requiredValue(value) != null) return 'Email is required';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                      .hasMatch(value!.trim()))
                    return 'Enter a valid email';
                  return null;
                },
              ),
              field(
                'Password',
                passwordController,
                'Create a password',
                obscure: true,
                validator: (value) {
                  if (requiredValue(value) != null)
                    return 'Password is required';
                  return value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null;
                },
              ),
              const Text('Interests', style: AppTextStyles.formLabel),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Choose interests (optional).',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              InterestSelector(
                selected: selectedInterests,
                onToggle: (interest) => setState(() {
                  if (!selectedInterests.add(interest))
                    selectedInterests.remove(interest);
                }),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create account'),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
