import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_theme.dart';
import 'event_place_field.dart';
import 'event_cover_gallery.dart';
import 'event_categories.dart';

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
  SelectedEventPlace? selectedPlace;
  final startTime = TextEditingController();
  final endTime = TextEditingController();

  String? selectedCoverUrl;
  DateTime? date;
  String? activity;
  int capacity = 8;
  RangeValues age = const RangeValues(18, 70);

  final activities = EventCategories.all;
  bool showErrors = false;
  final GlobalKey _photoKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _descriptionKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _timeKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();

  static final RegExp _validTime = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  String? get _photoError => showErrors && selectedCoverUrl == null
      ? 'Please choose a cover photo.'
      : null;
  String? get _titleError => showErrors && title.text.trim().isEmpty
      ? 'Please enter an event title.'
      : null;
  String? get _categoryError =>
      showErrors && activity == null ? 'Please select a category.' : null;
  String? get _descriptionError => showErrors && description.text.trim().isEmpty
      ? 'Please enter a description.'
      : null;
  String? get _dateError =>
      showErrors && date == null ? 'Please select an event date.' : null;
  String? get _locationError => showErrors && selectedPlace == null
      ? 'Please select an event location.'
      : null;

  DateTime? _dateTimeFor(String value) {
    if (date == null || !_validTime.hasMatch(value.trim())) return null;
    final parts = value.trim().split(':').map(int.parse).toList();
    return DateTime(date!.year, date!.month, date!.day, parts[0], parts[1]);
  }

  String? get _startError {
    if (!showErrors) return null;
    if (startTime.text.trim().isEmpty) return 'Select a start time.';
    if (!_validTime.hasMatch(startTime.text.trim()))
      return 'Use HH:mm (e.g. 13:00).';
    final start = _dateTimeFor(startTime.text);
    if (start != null && !start.isAfter(DateTime.now())) {
      return 'Start time must be in the future.';
    }
    return null;
  }

  String? get _endError {
    if (!showErrors) return null;
    if (endTime.text.trim().isEmpty) return 'Select an end time.';
    if (!_validTime.hasMatch(endTime.text.trim()))
      return 'Use HH:mm (e.g. 14:00).';
    final start = _dateTimeFor(startTime.text);
    final end = _dateTimeFor(endTime.text);
    if (start != null && end != null && !end.isAfter(start)) {
      return 'End time must be after start time.';
    }
    return null;
  }

  static const Color _errorColor = Color(0xFFF87171);

  Widget _errorText(String? error) => error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            error,
            style: const TextStyle(color: _errorColor, fontSize: 12),
          ),
        );

  void _scrollToFirstError() {
    final keys = <GlobalKey?>[
      if (_photoError != null) _photoKey,
      if (_titleError != null) _titleKey,
      if (_categoryError != null) _categoryKey,
      if (_descriptionError != null) _descriptionKey,
      if (_dateError != null) _dateKey,
      if (_startError != null || _endError != null) _timeKey,
      if (_locationError != null) _locationKey,
    ];
    if (keys.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = keys.first?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 300),
          alignment: 0.12,
        );
      }
    });
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
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
            Column(
              key: _photoKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_photo(), _errorText(_photoError)],
            ),
            _label('Event title'),
            Column(
              key: _titleKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(title, 'Event name', error: _titleError),
                _errorText(_titleError),
              ],
            ),
            _label('Category'),
            Column(
              key: _categoryKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
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
                _errorText(_categoryError),
              ],
            ),
            _label('Description'),
            Column(
              key: _descriptionKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(
                  description,
                  'Tell people about the event',
                  lines: 3,
                  error: _descriptionError,
                ),
                _errorText(_descriptionError),
              ],
            ),
            _label('Date'),
            Column(
              key: _dateKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(
                  Icons.calendar_today_outlined,
                  date == null
                      ? 'Select date'
                      : '${date!.day}/${date!.month}/${date!.year}',
                  _pickDate,
                ),
                _errorText(_dateError),
              ],
            ),
            _label('Time'),
            Row(
              key: _timeKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _timeField(startTime, 'Start time', _startError),
                      _errorText(_startError),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _timeField(endTime, 'End time', _endError),
                      _errorText(_endError),
                    ],
                  ),
                ),
              ],
            ),
            _label('Location'),
            Column(
              key: _locationKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventPlaceField(
                  value: selectedPlace,
                  onChanged: (place) => setState(() => selectedPlace = place),
                ),
                _errorText(_locationError),
              ],
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
      final chosen = await EventCoverGallery.choose(
        context,
        selected: selectedCoverUrl,
      );
      if (chosen != null && mounted) setState(() => selectedCoverUrl = chosen);
    },
    child: Container(
      height: AppSizes.photoHeight,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: AppDecorations.input,
      child: selectedCoverUrl == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 35),
                SizedBox(height: AppSpacing.sm),
                Text('Choose cover photo *'),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  selectedCoverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: Chip(label: Text('Change cover')),
                ),
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
    String? error,
  }) => TextField(
    controller: controller,
    maxLines: lines,
    onChanged: (_) {
      if (showErrors) setState(() {});
    },
    decoration: AppInputs.field(hint: hint, icon: icon).copyWith(
      enabledBorder: error == null
          ? null
          : OutlineInputBorder(
              borderRadius: AppRadii.field,
              borderSide: const BorderSide(color: _errorColor),
            ),
      focusedBorder: error == null
          ? null
          : OutlineInputBorder(
              borderRadius: AppRadii.field,
              borderSide: const BorderSide(color: _errorColor),
            ),
    ),
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

  Widget _timeField(
    TextEditingController controller,
    String hint,
    String? error,
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

        return times.where((t) => t.replaceAll(':', '').startsWith(input));
      },
      onSelected: (value) => setState(() => controller.text = value),
      fieldViewBuilder: (_, textController, focus, __) {
        return TextField(
          controller: textController,
          focusNode: focus,
          keyboardType: TextInputType.number,
          onChanged: (value) => setState(() => controller.text = value),
          decoration: AppInputs.field(hint: hint, icon: Icons.access_time)
              .copyWith(
                enabledBorder: error == null
                    ? null
                    : const OutlineInputBorder(
                        borderSide: BorderSide(color: _errorColor),
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

  Future<void> _create() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    setState(() => showErrors = true);

    if (selectedCoverUrl == null ||
        title.text.trim().isEmpty ||
        activity == null ||
        description.text.trim().isEmpty ||
        selectedPlace == null ||
        date == null ||
        !_validTime.hasMatch(startTime.text.trim()) ||
        !_validTime.hasMatch(endTime.text.trim())) {
      _scrollToFirstError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final startParts = startTime.text.trim().split(':').map(int.parse).toList();
    final endParts = endTime.text.trim().split(':').map(int.parse).toList();

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
      _scrollToFirstError();
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
        ...selectedPlace!.toFirestore(),
        'activity': activity!,
        'category': activity!,
        'tags': [activity!],
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
        'distance': '',
        'imageUrl': selectedCoverUrl!,
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
