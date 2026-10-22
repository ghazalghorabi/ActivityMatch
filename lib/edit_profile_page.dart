import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';
import 'interests_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final customInterestController = TextEditingController();
  final selectedInterests = <String>{};
  DateTime? birthDate;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final document = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!mounted) return;
      final data = document.data() ?? {};
      setState(() {
        nameController.text = data['name'] as String? ?? user.displayName ?? '';
        locationController.text = data['location'] as String? ?? '';
        bioController.text = data['bio'] as String? ?? '';
        birthDate = data['birthDate'] is Timestamp
            ? (data['birthDate'] as Timestamp).toDate()
            : null;
        selectedInterests..clear()..addAll(List<String>.from(data['interests'] ?? []));
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load profile: $e')));
    }
  }

  Future<void> pickBirthDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null && mounted) setState(() => birthDate = picked);
  }

  void addCustomInterest() {
    final interest = customInterestController.text.trim();
    if (interest.isEmpty) return;
    setState(() {
      selectedInterests.add(interest);
      customInterestController.clear();
    });
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    if (nameController.text.trim().isEmpty || birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name and date of birth')));
      return;
    }
    setState(() => saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text.trim(),
        'birthDate': Timestamp.fromDate(birthDate!),
        'location': locationController.text.trim(),
        'bio': bioController.text.trim(),
        'interests': selectedInterests.toList(),
      }, SetOptions(merge: true));
      await user.updateDisplayName(nameController.text.trim());
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget field(String title, TextEditingController controller, {int lines = 1}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.formLabel),
        const SizedBox(height: AppSpacing.fieldLabelBottom),
        TextField(controller: controller, maxLines: lines, style: AppTextStyles.bodyLarge,
          decoration: AppInputs.field()),
        const SizedBox(height: AppSpacing.xl),
      ]);

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    bioController.dispose();
    customInterestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final additional = selectedInterests.where((i) => !InterestsPage.interests.contains(i));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile', style: AppTextStyles.pageTitle)),
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: CircleAvatar(radius: 50, backgroundColor: AppColors.surface,
            child: Icon(Icons.person, size: 58, color: AppColors.textPrimary))),
          const SizedBox(height: AppSpacing.xxxl),
          field('Name', nameController),
          const Text('Date of birth', style: AppTextStyles.formLabel),
          const SizedBox(height: AppSpacing.fieldLabelBottom),
          InkWell(onTap: pickBirthDate, child: InputDecorator(
            decoration: AppInputs.field(icon: Icons.calendar_today_outlined),
            child: Text(birthDate == null ? 'Select your date of birth'
              : '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}',
              style: birthDate == null ? AppTextStyles.bodySecondary : AppTextStyles.bodyLarge),
          )),
          const SizedBox(height: AppSpacing.xl),
          field('Location', locationController),
          field('Bio', bioController, lines: 4),
          const Text('Interests', style: AppTextStyles.formLabel),
          const SizedBox(height: AppSpacing.sm),
          const Text('Choose your interests', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.md),
          InterestSelector(selected: selectedInterests, additionalOptions: additional,
            onToggle: (interest) => setState(() {
              if (!selectedInterests.add(interest)) selectedInterests.remove(interest);
            })),
          const SizedBox(height: AppSpacing.xxl),
          const Text('Add your own interest', style: AppTextStyles.formLabel),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(child: TextField(controller: customInterestController,
              decoration: AppInputs.field(hint: 'e.g. Horse riding'), onSubmitted: (_) => addCustomInterest())),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton(onPressed: addCustomInterest, child: const Text('Add')),
          ]),
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: saving ? null : saveProfile,
            child: saving ? const CircularProgressIndicator() : const Text('Save changes'),
          )),
          const SizedBox(height: AppSpacing.xxxl),
        ]),
      ),
    );
  }
}
