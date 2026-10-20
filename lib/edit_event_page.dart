import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_theme.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;

  const EditEventPage({super.key, required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _startTime = TextEditingController();
  final _endTime = TextEditingController();

  final _activities = const [
    'Padel',
    'Running',
    'Drinks',
    'Coffee',
    'Walk',
    'Gym',
    'Gaming',
  ];

  String _activity = 'Padel';
  DateTime? _date;
  int _capacity = 1;
  RangeValues _age = const RangeValues(18, 70);
  bool _loading = true;
  bool _saving = false;
  String? _error;

  DocumentReference<Map<String, dynamic>> get _eventRef =>
      FirebaseFirestore.instance.collection('events').doc(widget.eventId);

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Please log in first.');
      final snapshot = await _eventRef.get();
      if (!snapshot.exists) throw Exception('Event not found.');
      final data = snapshot.data()!;
      if (data['hostId'] != user.uid) {
        throw Exception('Only the host can edit this event.');
      }
      if ((data['status'] ?? 'active') != 'active') {
        throw Exception('Cancelled events cannot be edited.');
      }
      if (!mounted) return;
      setState(() {
        _title.text = data['title'] as String? ?? '';
        _description.text = data['description'] as String? ?? '';
        _location.text = data['location'] as String? ?? '';
        _startTime.text = data['time'] as String? ?? '';
        _endTime.text = data['endTime'] as String? ?? '';
        final savedActivity = data['activity'] as String? ?? 'Padel';
        _activity = _activities.contains(savedActivity)
            ? savedActivity
            : 'Padel';
        _date = (data['date'] as Timestamp?)?.toDate();
        _capacity = (data['capacity'] as num?)?.toInt() ?? 1;
        _age = RangeValues(
          ((data['minAge'] as num?)?.toDouble() ?? 18).clamp(18, 70),
          ((data['maxAge'] as num?)?.toDouble() ?? 70).clamp(18, 70),
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _startTime.dispose();
    _endTime.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial =
        _date != null &&
            !_date!.isBefore(DateTime(now.year, now.month, now.day))
        ? _date!
        : now;
    final chosen = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2035),
    );
    if (chosen != null && mounted) setState(() => _date = chosen);
  }

  Future<void> _save() async {
    if (_saving) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    final startText = _startTime.text.trim();
    final endText = _endTime.text.trim();
    if (_title.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        _location.text.trim().isEmpty ||
        _date == null ||
        !timePattern.hasMatch(startText) ||
        !timePattern.hasMatch(endText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete all fields. Use HH:mm for times.'),
        ),
      );
      return;
    }

    final startParts = startText.split(':').map(int.parse).toList();
    final endParts = endText.split(':').map(int.parse).toList();
    final start = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      startParts[0],
      startParts[1],
    );
    final end = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      endParts[0],
      endParts[1],
    );
    if (!start.isAfter(DateTime.now()) || !end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a future start and a later end time.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(_eventRef);
        if (!snapshot.exists) throw Exception('Event no longer exists.');
        final data = snapshot.data()!;
        if (data['hostId'] != user.uid)
          throw Exception('You are not the host.');
        if ((data['status'] ?? 'active') != 'active') {
          throw Exception('This event is cancelled.');
        }
        final participants = (data['participantCount'] as num?)?.toInt() ?? 0;
        if (_capacity < participants) {
          throw Exception('Capacity cannot be below $participants attendees.');
        }
        transaction.update(_eventRef, {
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'location': _location.text.trim(),
          'activity': _activity,
          'tags': [_activity],
          'date': Timestamp.fromDate(start),
          'time': startText,
          'endTime': endText,
          'duration': '$startText – $endText',
          'capacity': _capacity,
          'availableSpots': _capacity - participants,
          'minAge': _age.start.round(),
          'maxAge': _age.end.round(),
        });
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update event: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        maxLines: lines,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: label.contains('time') ? 'HH:mm' : null,
          filled: true,
          fillColor: AppColors.surface,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Edit Event'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('Event title', _title),
                  const Text(
                    'Activity',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _activities
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item),
                            selected: _activity == item,
                            selectedColor: AppColors.primary,
                            onSelected: (_) => setState(() => _activity = item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  _field('Description', _description, lines: 3),
                  ListTile(
                    tileColor: AppColors.surface,
                    title: Text(
                      _date == null
                          ? 'Select date'
                          : '${_date!.day}/${_date!.month}/${_date!.year}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    leading: const Icon(Icons.calendar_today_outlined),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _field('Start time', _startTime)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('End time', _endTime)),
                    ],
                  ),
                  _field('Location', _location),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Capacity',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: _capacity > 1
                            ? () => setState(() => _capacity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$_capacity',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _capacity++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Age: ${_age.start.round()} – ${_age.end.round()}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  RangeSlider(
                    values: _age,
                    min: 18,
                    max: 70,
                    divisions: 52,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _age = value),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: _saving
                          ? const CircularProgressIndicator()
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
