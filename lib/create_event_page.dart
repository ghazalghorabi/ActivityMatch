import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'base_widgets.dart';
import 'event_data.dart';
import 'model.dart';
import 'app_theme.dart';

// ============================================================
// CREATE EVENT PAGE
// ============================================================

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final startTime = TextEditingController();
  final endTime = TextEditingController();

  XFile? image;
  DateTime? date;
  String activity = 'Padel';
  int capacity = 8;
  RangeValues age = const RangeValues(18, 70);

  final activities = [
    'Padel',
    'Running',
    'Drinks',
    'Coffee',
    'Walk',
    'Gym',
    'Gaming',
  ];

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    location.dispose();
    startTime.dispose();
    endTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Create Event'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photo(),
            _label('Event title'),
            _field(title, 'Event name'),
            _label('Activity'),
            Wrap(
              spacing: AppSpacing.sm,
              children: activities.map((a) {
                return ChoiceChip(
                  label: Text(a),
                  selected: activity == a,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(() => activity = a),
                );
              }).toList(),
            ),
            _label('Description'),
            _field(description, 'Tell people about the event', lines: 3),
            _label('Date'),
            _box(
              Icons.calendar_today_outlined,
              date == null
                  ? 'Select date'
                  : '${date!.day}/${date!.month}/${date!.year}',
              _pickDate,
            ),
            _label('Time'),
            Row(
              children: [
                Expanded(child: _timeField(startTime, 'Start time')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _timeField(endTime, 'End time')),
              ],
            ),
            _label('Location'),
            _field(
              location,
              'Where is the event?',
              icon: Icons.location_on_outlined,
            ),
            _label('Participants'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: capacity > 1
                      ? () => setState(() => capacity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$capacity people', style: AppTextStyles.bodyLarge),
                IconButton(
                  onPressed: () => setState(() => capacity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            _label('Age'),
            Text(
              '${age.start.round()} – ${age.end.round() == 70 ? '70+' : age.end.round()} years',
            ),
            RangeSlider(
              values: age,
              min: 18,
              max: 70,
              divisions: 52,
              activeColor: AppColors.primary,
              onChanged: (value) => setState(() => age = value),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: AppSizes.primaryButtonHeight,
              child: ElevatedButton(
                onPressed: _create,
                style: AppButtons.primary,
                child: const Text('Create Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PHOTO
  // ============================================================

  Widget _photo() => GestureDetector(
    onTap: () async {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() => image = picked);
      }
    },
    child: Container(
      height: AppSizes.photoHeight,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: AppDecorations.input,
      child: image != null
          ? FutureBuilder<Uint8List>(
              future: image!.readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              },
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 35),
                SizedBox(height: AppSpacing.sm),
                Text('Add photo *'),
              ],
            ),
    ),
  );

  // ============================================================
  // FIELDS
  // ============================================================

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xxl, bottom: AppSpacing.sm),
    child: Text('$text *', style: AppTextStyles.formLabel),
  );

  Widget _field(
    TextEditingController controller,
    String hint, {
    int lines = 1,
    IconData? icon,
  }) => TextField(
    controller: controller,
    maxLines: lines,
    decoration: AppInputs.field(hint: hint, icon: icon),
  );

  Widget _box(IconData icon, String text, VoidCallback tap) => ListTile(
    onTap: tap,
    tileColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: AppRadii.field),
    leading: Icon(icon),
    title: Text(text),
  );

  // ============================================================
  // TIME
  // ============================================================

  Widget _timeField(TextEditingController controller, String hint) {
    final times = [
      for (var h = 0; h < 24; h++)
        for (var m in [0, 15, 30, 45])
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
    ];

    return Autocomplete<String>(
      optionsBuilder: (value) {
        final input = value.text.replaceAll(':', '');
        if (input.isEmpty) return const Iterable<String>.empty();

        return times.where((t) => t.replaceAll(':', '').startsWith(input));
      },
      onSelected: (value) => controller.text = value,
      fieldViewBuilder: (_, textController, focus, __) {
        return TextField(
          controller: textController,
          focusNode: focus,
          keyboardType: TextInputType.number,
          onChanged: (value) => controller.text = value,
          decoration: AppInputs.field(hint: hint, icon: Icons.access_time),
        );
      },
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (selected != null) setState(() => date = selected);
  }

  // ============================================================
  // CREATE EVENT
  // ============================================================

  Future<void> _create() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    final validTime = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

    if (title.text.trim().isEmpty ||
        description.text.trim().isEmpty ||
        location.text.trim().isEmpty ||
        date == null ||
        !validTime.hasMatch(startTime.text) ||
        !validTime.hasMatch(endTime.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final startParts = startTime.text.split(':').map(int.parse).toList();
    final endParts = endTime.text.split(':').map(int.parse).toList();

    final eventStart = DateTime(
      date!.year,
      date!.month,
      date!.day,
      startParts[0],
      startParts[1],
    );

    final eventEnd = DateTime(
      date!.year,
      date!.month,
      date!.day,
      endParts[0],
      endParts[1],
    );

    if (!eventStart.isAfter(DateTime.now()) || !eventEnd.isAfter(eventStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a future event with a valid end time'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': title.text.trim(),
        'description': description.text.trim(),
        'location': location.text.trim(),
        'activity': activity,
        'tags': [activity],
        'date': Timestamp.fromDate(eventStart),
        'time': startTime.text,
        'endTime': endTime.text,
        'duration': '${startTime.text} – ${endTime.text}',
        'capacity': capacity,
        'availableSpots': capacity,
        'participantCount': 0,
        'minAge': age.start.round(),
        'maxAge': age.end.round(),
        'hostId': user.uid,
        'hostName': user.displayName ?? user.email ?? 'Host',
        'status': 'active',
        'city': '',
        'distance': '',
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not create event: $e')));
    }
  }
}
