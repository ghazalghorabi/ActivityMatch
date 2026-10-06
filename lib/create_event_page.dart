import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'base_widgets.dart';
import 'event_data.dart';
import 'model.dart';

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photo(),
            _label('Event title'),
            _field(title, 'Event name'),
            _label('Activity'),
            Wrap(
              spacing: 8,
              children: activities.map((a) {
                return ChoiceChip(
                  label: Text(a),
                  selected: activity == a,
                  showCheckmark: false,
                  selectedColor: const Color(0xFFFF9800),
                  onSelected: (_) => setState(() => activity = a),
                );
              }).toList(),
            ),
            _label('Description'),
            _field(
              description,
              'Tell people about the event',
              lines: 3,
            ),
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
                const SizedBox(width: 10),
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
                Text(
                  '$capacity people',
                  style: const TextStyle(fontSize: 16),
                ),
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
              activeColor: const Color(0xFFFF9800),
              onChanged: (value) => setState(() => age = value),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
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
          final picked = await ImagePicker().pickImage(
            source: ImageSource.gallery,
          );
          if (picked != null) setState(() => image = picked);
        },
        child: Container(
          height: 180,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF292521),
            borderRadius: BorderRadius.circular(18),
          ),
          child: image != null
              ? Image.file(File(image!.path), fit: BoxFit.cover)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 35),
                    SizedBox(height: 8),
                    Text('Add photo *'),
                  ],
                ),
        ),
      );

  // ============================================================
  // FIELDS
  // ============================================================

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          '$text *',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String hint, {
    int lines = 1,
    IconData? icon,
  }) =>
      TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon),
          filled: true,
          fillColor: const Color(0xFF292521),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _box(IconData icon, String text, VoidCallback tap) => ListTile(
        onTap: tap,
        tileColor: const Color(0xFF292521),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: Icon(icon),
        title: Text(text),
      );

  // ============================================================
  // TIME
  // ============================================================

  Widget _timeField(
    TextEditingController controller,
    String hint,
  ) {
    final times = [
      for (var h = 0; h < 24; h++)
        for (var m in [0, 15, 30, 45])
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
    ];

    return Autocomplete<String>(
      optionsBuilder: (value) {
        final input = value.text.replaceAll(':', '');
        if (input.isEmpty) return const Iterable<String>.empty();

        return times.where(
          (t) => t.replaceAll(':', '').startsWith(input),
        );
      },
      onSelected: (value) => controller.text = value,
      fieldViewBuilder: (_, textController, focus, __) {
        return TextField(
          controller: textController,
          focusNode: focus,
          keyboardType: TextInputType.number,
          onChanged: (value) => controller.text = value,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.access_time),
            filled: true,
            fillColor: const Color(0xFF292521),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
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

  void _create() {
    final validTime = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

    if (image == null ||
        title.text.trim().isEmpty ||
        description.text.trim().isEmpty ||
        location.text.trim().isEmpty ||
        date == null ||
        !validTime.hasMatch(startTime.text) ||
        !validTime.hasMatch(endTime.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
        ),
      );
      return;
    }

    EventData.addEvent(
      ActivityEvent(
        title: title.text.trim(),
        date: date!,
        location: location.text.trim(),
        availableSpots: capacity,
        imageUrl: image!.path,
        time: startTime.text,
        description: description.text.trim(),
        hostName: 'You',
        duration: '${startTime.text} – ${endTime.text}',
        minAge: age.start.round(),
        maxAge: age.end.round(),
        capacity: capacity,
        activity: activity,
      ),
    );

    Navigator.pop(context);
  }
}