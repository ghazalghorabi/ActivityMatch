import 'package:flutter/material.dart';

import 'base_widgets.dart';
import 'model.dart';
import 'event_data.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // ============================================================
  // VARIABLES
  // ============================================================

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final otherActivityController = TextEditingController();
  final startTimeController = TextEditingController(text: '18:00');
  final endTimeController = TextEditingController();

  String selectedActivity = 'Padel';
  String? openTimeMenu;

  DateTime? selectedDate;
  int participants = 8;

  RangeValues ageRange = const RangeValues(20, 35);

  final activities = [
    'Padel',
    'Running',
    'Drinks',
    'Coffee',
    'Walk',
    'Gym',
    'Gaming',
    'Other',
  ];

  final tags = [
    'Sports',
    'Social',
    'Outdoor',
    'Nightlife',
    'Beginner friendly',
  ];

  final Set<String> selectedTags = {};

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    otherActivityController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  // ============================================================
  // PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Create Event'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Event title'),
            _field(
              titleController,
              'Give your event a name',
            ),

            _space(),

            _title('Activity'),
            _activities(),

            if (selectedActivity == 'Other') ...[
              const SizedBox(height: 12),
              _field(
                otherActivityController,
                'What activity is it?',
              ),
            ],

            _space(),

            _title('Description'),
            _field(
              descriptionController,
              'Tell people about the event...',
              maxLines: 4,
            ),

            _space(),

            _title('Date'),
            _dateSelector(),

            _space(),

            _title('Time'),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _timeField(
                    label: 'Start time',
                    controller: startTimeController,
                    menuName: 'start',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _timeField(
                    label: 'End time (optional)',
                    controller: endTimeController,
                    menuName: 'end',
                  ),
                ),
              ],
            ),

            _space(),

            _title('Location'),
            _field(
              locationController,
              'Where is the event?',
              icon: Icons.location_on_outlined,
            ),

            _space(),

            _title('Number of participants'),
            _participants(),

            _space(),

            _title('Age range'),
            _ageSelector(),

            _space(),

            _title('Tags'),
            _tags(),

            _space(),

            _title('Add a picture'),
            _imagePicker(),

            const SizedBox(height: 35),

            _createButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GENERAL WIDGETS
  // ============================================================

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _space() {
    return const SizedBox(height: 25);
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        prefixIcon: icon == null
            ? null
            : Icon(
                icon,
                color: Colors.white54,
              ),
        filled: true,
        fillColor: const Color(0xFF292521),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITY
  // ============================================================

  Widget _activities() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: activities.map((activity) {
        final selected = selectedActivity == activity;

        return ChoiceChip(
          label: Text(activity),
          selected: selected,
          showCheckmark: false,

          selectedColor: const Color(0xFFFF9800),
          backgroundColor: const Color(0xFF292521),

          side: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          labelStyle: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white70,
          ),

          onSelected: (_) {
            setState(() {
              selectedActivity = activity;
            });
          },
        );
      }).toList(),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _dateSelector() {
    return GestureDetector(
      onTap: _selectDate,

      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFF292521),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white54,
              size: 20,
            ),

            const SizedBox(width: 10),

            Text(
              selectedDate == null
                  ? 'Select date'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // ============================================================
  // TIME
  // ============================================================

  Widget _timeField({
    required String label,
    required TextEditingController controller,
    required String menuName,
  }) {
    final isOpen = openTimeMenu == menuName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,
          keyboardType: TextInputType.datetime,

          onTap: () {
            setState(() {
              openTimeMenu = menuName;
            });
          },

          onChanged: (_) {
            setState(() {
              openTimeMenu = menuName;
            });
          },

          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),

          decoration: InputDecoration(
            hintText: menuName == 'start'
                ? '18:00'
                : '--:--',

            hintStyle: const TextStyle(
              color: Colors.white38,
            ),

            prefixIcon: const Icon(
              Icons.access_time_rounded,
              color: Colors.white54,
              size: 20,
            ),

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  openTimeMenu =
                      isOpen ? null : menuName;
                });
              },
              icon: Icon(
                isOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white54,
              ),
            ),

            filled: true,
            fillColor: const Color(0xFF292521),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        if (isOpen)
          Container(
            margin: const EdgeInsets.only(top: 5),

            decoration: BoxDecoration(
              color: const Color(0xFF292521),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              children: _timeOptions(
                controller,
                menuName,
              ).map((time) {
                return ListTile(
                  dense: true,

                  title: Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  onTap: () {
                    setState(() {
                      controller.text = time;
                      openTimeMenu = null;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  List<String> _timeOptions(
    TextEditingController controller,
    String menuName,
  ) {
    String value = controller.text.trim();

    // If end time is empty, use start time as base.
    if (menuName == 'end' && value.isEmpty) {
      value = startTimeController.text;
    }

    final parts = value.split(':');

    int hour = int.tryParse(parts.first) ?? 18;

    int minute = parts.length > 1
        ? int.tryParse(parts[1]) ?? 0
        : 0;

    hour = hour.clamp(0, 23);
    minute = minute.clamp(0, 59);

    int start = hour * 60 + minute;

    // First end-time suggestion is 15 minutes later.
    if (menuName == 'end' &&
        controller.text.isEmpty) {
      start += 15;
    }

    return List.generate(5, (index) {
      final total =
          (start + index * 15) % (24 * 60);

      final hour = total ~/ 60;
      final minute = total % 60;

      return '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}';
    });
  }

  // ============================================================
  // PARTICIPANTS
  // ============================================================

  Widget _participants() {
    return Container(
      height: 55,

      decoration: BoxDecoration(
        color: const Color(0xFF292521),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (participants > 2) {
                setState(() {
                  participants--;
                });
              }
            },
            icon: const Icon(Icons.remove),
          ),

          Expanded(
            child: Text(
              '$participants people',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                participants++;
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AGE RANGE
  // ============================================================

  Widget _ageSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${ageRange.start.round()} years',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            Text(
              '${ageRange.end.round()} years',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),

        RangeSlider(
          values: ageRange,
          min: 18,
          max: 70,
          divisions: 52,
          activeColor: const Color(0xFFFF9800),
          inactiveColor: const Color(0xFF292521),

          onChanged: (value) {
            setState(() {
              ageRange = value;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // TAGS
  // ============================================================

  Widget _tags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,

      children: tags.map((tag) {
        final selected = selectedTags.contains(tag);

        return FilterChip(
          label: Text(tag),
          selected: selected,
          showCheckmark: false,

          selectedColor: const Color(0xFFFF9800),
          backgroundColor: const Color(0xFF292521),

          side: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          labelStyle: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white70,
          ),

          onSelected: (_) {
            setState(() {
              if (selected) {
                selectedTags.remove(tag);
              } else {
                selectedTags.add(tag);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _imagePicker() {
    return Container(
      width: double.infinity,
      height: 120,

      decoration: BoxDecoration(
        color: const Color(0xFF292521),
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),

      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: Colors.white54,
            size: 32,
          ),

          SizedBox(height: 8),

          Text(
            'Add photo',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CREATE EVENT
  // ============================================================

  Widget _createButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton(
        onPressed: _createEvent,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),

        child: const Text(
          'Create Event',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _createEvent() {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        selectedDate == null ||
        startTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all required fields',
          ),
        ),
      );

      return;
    }

    final event = ActivityEvent(
      title: titleController.text.trim(),

      date:
          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',

      location: locationController.text.trim(),

      availableSpots: participants,

      imageUrl: '',

      time: startTimeController.text.trim(),

      description:
          descriptionController.text.trim(),

      hostName: 'You',

      // For now duration stores the optional end time.
      duration: endTimeController.text.trim(),

      ageRange:
          '${ageRange.start.round()}–${ageRange.end.round()}',

      capacity: participants,

      tags: selectedTags.toList(),
    );

    EventData.addEvent(event);

    Navigator.pop(context);
  }
}