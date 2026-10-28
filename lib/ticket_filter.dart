import 'package:flutter/material.dart';

import 'model.dart';
import 'app_theme.dart';

// ============================================================
// TICKET FILTER
// ============================================================

class TicketFilter {
  String when;
  String location;
  String distance;
  DateTime? startDate;
  DateTime? endDate;
  Set<String> activities;
  RangeValues age;
  String sortBy;
  bool availableOnly;

  TicketFilter({
    this.when = 'All',
    this.location = '',
    this.distance = 'Any',
    this.startDate,
    this.endDate,
    Set<String>? activities,
    this.age = const RangeValues(18, 70),
    this.sortBy = 'Soonest',
    this.availableOnly = false,
  }) : activities = activities ?? {};
}

// ============================================================
// FILTER EVENTS
// ============================================================

List<ActivityEvent> applyTicketFilters(
  List<ActivityEvent> events,
  TicketFilter filter, {
  bool isHosting = false,
  Set<String> cancelledEventIds = const {},
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final result = events.where((event) {
    final upcoming = !event.date.isBefore(today);

    final cancelled = cancelledEventIds.contains(event.id);
    if (isHosting) {
      if (filter.when == 'Cancelled' && !cancelled) return false;
      if (filter.when == 'Upcoming' && (cancelled || !upcoming)) return false;
      if (filter.when == 'Past' && (cancelled || upcoming)) return false;
    } else {
      if (filter.when == 'Upcoming' && !upcoming) return false;
      if (filter.when == 'Past' && upcoming) return false;
    }

    if (filter.location.isNotEmpty &&
        !event.location.toLowerCase().contains(filter.location.toLowerCase()) &&
        !event.city.toLowerCase().contains(filter.location.toLowerCase())) {
      return false;
    }

    if (filter.activities.isNotEmpty &&
        !filter.activities.contains(event.activity)) {
      return false;
    }

    final eventDay = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );
    if (filter.startDate != null &&
        eventDay.isBefore(
          DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            filter.startDate!.day,
          ),
        ))
      return false;
    if (filter.endDate != null &&
        eventDay.isAfter(
          DateTime(
            filter.endDate!.year,
            filter.endDate!.month,
            filter.endDate!.day,
          ),
        ))
      return false;

    if (event.maxAge < filter.age.start || event.minAge > filter.age.end) {
      return false;
    }

    return true;
  }).toList();

  result.sort(
    (a, b) => filter.sortBy == 'Soonest'
        ? a.date.compareTo(b.date)
        : b.date.compareTo(a.date),
  );

  return result;
}

// ============================================================
// FILTER WINDOW
// ============================================================

Future<TicketFilter?> showTicketFilter(
  BuildContext context,
  TicketFilter filter, {
  bool isHosting = false,
  bool isExplore = false,
}) {
  final activities = [
    'Padel',
    'Running',
    'Drinks',
    'Coffee',
    'Walk',
    'Gym',
    'Gaming',
  ];

  return showModalBottomSheet<TicketFilter>(
    context: context,
    backgroundColor: AppColors.surfaceSecondary,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Widget title(String text) => Padding(
            padding: const EdgeInsets.only(top: 22, bottom: AppSpacing.sm),
            child: Text(text, style: AppTextStyles.formLabel),
          );

          Widget choices(
            List<String> values,
            String selected,
            ValueChanged<String> onSelected,
          ) {
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: values.map((value) {
                return ChoiceChip(
                  label: Text(value),
                  selected: selected == value,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(() => onSelected(value)),
                );
              }).toList(),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.filter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExplore ? 'Filter events' : 'Filter tickets',
                    style: AppTextStyles.filterTitle,
                  ),

                  if (!isExplore) ...[
                    title('When'),
                    choices(
                      isHosting
                          ? ['All', 'Upcoming', 'Past', 'Cancelled']
                          : ['All', 'Upcoming', 'Past'],
                      filter.when,
                      (value) => filter.when = value,
                    ),
                  ],

                  title('Location'),
                  TextFormField(
                    initialValue: filter.location,
                    decoration: const InputDecoration(
                      hintText: 'Enter location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    onChanged: (value) => filter.location = value,
                  ),

                  title('Distance'),
                  choices(
                    ['Any', '1 km', '5 km', '10 km', '25 km'],
                    filter.distance,
                    (value) => filter.distance = value,
                  ),
                  if (isExplore)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Distance filtering requires a selected map location and is not active yet.',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),

                  title('Date range'),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            filter.startDate == null
                                ? 'From'
                                : '${filter.startDate!.day}/${filter.startDate!.month}/${filter.startDate!.year}',
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: filter.startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null)
                              setState(() {
                                filter.startDate = picked;
                                if (filter.endDate != null &&
                                    filter.endDate!.isBefore(picked))
                                  filter.endDate = null;
                              });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            filter.endDate == null
                                ? 'To'
                                : '${filter.endDate!.day}/${filter.endDate!.month}/${filter.endDate!.year}',
                          ),
                          onPressed: () async {
                            final first = filter.startDate ?? DateTime(2020);
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  filter.endDate ??
                                  (DateTime.now().isBefore(first)
                                      ? first
                                      : DateTime.now()),
                              firstDate: first,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null)
                              setState(() => filter.endDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (filter.startDate != null || filter.endDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() {
                          filter.startDate = null;
                          filter.endDate = null;
                        }),
                        child: const Text('Clear dates'),
                      ),
                    ),

                  if (!isExplore) ...[
                    title('Activity'),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: activities.map((activity) {
                        final selected = filter.activities.contains(activity);

                        return FilterChip(
                          label: Text(activity),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          onSelected: (_) {
                            setState(() {
                              selected
                                  ? filter.activities.remove(activity)
                                  : filter.activities.add(activity);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    title('Age'),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${filter.age.start.round()}'),
                        Text(
                          filter.age.end == 70
                              ? '70+'
                              : '${filter.age.end.round()}',
                        ),
                      ],
                    ),

                    RangeSlider(
                      values: filter.age,
                      min: 18,
                      max: 70,
                      divisions: 52,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() => filter.age = value);
                      },
                    ),

                    title('Sort by'),
                    choices(
                      ['Soonest', 'Latest'],
                      filter.sortBy,
                      (value) => filter.sortBy = value,
                    ),
                  ],
                  if (isExplore) ...[
                    title('Only events with available spots'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Only events with available spots'),
                      value: filter.availableOnly,
                      activeColor: AppColors.primary,
                      onChanged: (value) =>
                          setState(() => filter.availableOnly = value),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxxl),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              filter.when = 'All';
                              filter.location = '';
                              filter.distance = 'Any';
                              filter.startDate = null;
                              filter.endDate = null;
                              filter.activities.clear();
                              filter.age = const RangeValues(18, 70);
                              filter.sortBy = 'Soonest';
                              filter.availableOnly = false;
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: ElevatedButton(
                          style: AppButtons.primary,
                          onPressed: () {
                            Navigator.pop(context, filter);
                          },
                          child: const Text('Apply filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ============================================================
// ACTIVE FILTERS
// ============================================================

class ActiveTicketFilters extends StatelessWidget {
  final TicketFilter filter;
  final VoidCallback onChanged;

  const ActiveTicketFilters({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = <MapEntry<String, VoidCallback>>[];

    if (filter.when != 'All') {
      filters.add(MapEntry(filter.when, () => filter.when = 'All'));
    }

    if (filter.location.isNotEmpty) {
      filters.add(MapEntry(filter.location, () => filter.location = ''));
    }

    if (filter.distance != 'Any') {
      filters.add(
        MapEntry('≤ ${filter.distance}', () => filter.distance = 'Any'),
      );
    }

    if (filter.startDate != null) {
      filters.add(
        MapEntry(
          'From ${filter.startDate!.day}/${filter.startDate!.month}/${filter.startDate!.year}',
          () => filter.startDate = null,
        ),
      );
    }
    if (filter.endDate != null) {
      filters.add(
        MapEntry(
          'To ${filter.endDate!.day}/${filter.endDate!.month}/${filter.endDate!.year}',
          () => filter.endDate = null,
        ),
      );
    }

    for (final activity in filter.activities) {
      filters.add(MapEntry(activity, () => filter.activities.remove(activity)));
    }

    if (filter.age.start != 18 || filter.age.end != 70) {
      filters.add(
        MapEntry(
          '${filter.age.start.round()}–${filter.age.end.round() == 70 ? '70+' : filter.age.end.round()}',
          () => filter.age = const RangeValues(18, 70),
        ),
      );
    }

    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AppSizes.activeFilterHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final item = filters[index];

          return Container(
            padding: const EdgeInsets.only(left: 12, right: AppSpacing.xs),
            decoration: AppDecorations.filterChip,
            child: Row(
              children: [
                Text(item.key, style: AppTextStyles.filterChip),

                const SizedBox(width: AppSpacing.xxs),

                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: const Icon(
                    Icons.close,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    item.value();
                    onChanged();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
