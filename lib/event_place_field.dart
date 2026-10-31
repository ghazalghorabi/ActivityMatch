import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_theme.dart';

/// Plats som användaren valt från OpenStreetMaps sökresultat.
class SelectedEventPlace {
  final String placeId;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;

  const SelectedEventPlace({
    required this.placeId,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  factory SelectedEventPlace.fromFirestore(Map<String, dynamic> data) {
    return SelectedEventPlace(
      placeId: data['placeId'] as String? ?? '',
      name: data['location'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'location': name,
    'address': address,
    'city': city,
    'placeId': placeId,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class EventPlaceField extends StatefulWidget {
  final SelectedEventPlace? value;
  final ValueChanged<SelectedEventPlace?> onChanged;

  const EventPlaceField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<EventPlaceField> createState() => _EventPlaceFieldState();
}

class _EventPlaceFieldState extends State<EventPlaceField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  List<SelectedEventPlace> _results = [];
  bool _loading = false;
  String? _error;
  int _revision = 0;

  // Nominatims publika server: högst ett anrop per sekund totalt från appen.
  static DateTime? _lastRequest;
  static Future<void> _requestQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _controller.text = _display(widget.value);
  }

  String _display(SelectedEventPlace? place) => place == null
      ? ''
      : (place.address.isNotEmpty ? place.address : place.name);

  @override
  void didUpdateWidget(covariant EventPlaceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value?.placeId != oldWidget.value?.placeId && !_focus.hasFocus) {
      _controller.text = _display(widget.value);
    }
  }

  @override
  void dispose() {
    _revision++;
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _textChanged(String _) {
    ++_revision;
    if (widget.value != null) widget.onChanged(null);
    setState(() {
      _results = [];
      _error = null;
      _loading = false;
    });
  }

  static String _cityFromAddress(Map<String, dynamic> address) {
    for (final key in ['city', 'town', 'village', 'municipality', 'county']) {
      final value = address[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (_loading) return;
    if (query.length < 3) {
      setState(() => _error = 'Skriv minst tre tecken.');
      return;
    }
    final revision = ++_revision;
    _focus.unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    try {
      // Serialisera sökningarna så flera fält inte överskrider 1 req/s.
      final previous = _requestQueue;
      final completed = Completer<void>();
      _requestQueue = completed.future;
      try {
        await previous;
        if (_lastRequest != null) {
          final wait =
              const Duration(milliseconds: 1100) -
              DateTime.now().difference(_lastRequest!);
          if (wait > Duration.zero) await Future<void>.delayed(wait);
        }
        if (!mounted || revision != _revision) return;
        _lastRequest = DateTime.now();
        final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
          'q': query,
          'format': 'jsonv2',
          'addressdetails': '1',
          'limit': '8',
          'countrycodes': 'se',
          'accept-language': 'sv',
        });
        final response = await http
            .get(
              uri,
              headers: {
                'Accept': 'application/json',
                // För mobil/desktop. På webben används webbläsarens User-Agent/Referer.
                if (!kIsWeb)
                  'User-Agent':
                      'ActivityMatchSchoolProject/1.0 (educational project)',
              },
            )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception('Söktjänsten svarade med ${response.statusCode}.');
        }
        final decoded = jsonDecode(response.body) as List<dynamic>;
        final matches = <SelectedEventPlace>[];
        for (final raw in decoded) {
          final item = raw as Map<String, dynamic>;
          final address = (item['address'] as Map<String, dynamic>?) ?? {};
          final city = _cityFromAddress(address);
          final lat = double.tryParse(item['lat'].toString());
          final lon = double.tryParse(item['lon'].toString());
          if (lat == null || lon == null || city.isEmpty) continue;
          final fullAddress = (item['display_name'] as String? ?? '').trim();
          final name = (item['name'] as String? ?? '').trim();
          final street = (address['road'] as String? ?? '').trim();
          final number = (address['house_number'] as String? ?? '').trim();
          final streetAddress = street.isEmpty
              ? ''
              : number.isEmpty
              ? street
              : '$street $number';
          final displayName = (name.isEmpty || name == number)
              ? (streetAddress.isNotEmpty
                    ? streetAddress
                    : fullAddress.split(',').first.trim())
              : name;
          matches.add(
            SelectedEventPlace(
              placeId: 'osm:${item['osm_type']}:${item['osm_id']}',
              name: displayName,
              address: fullAddress,
              city: city,
              latitude: lat,
              longitude: lon,
            ),
          );
        }
        if (!mounted || revision != _revision) return;
        setState(() {
          _results = matches;
          _loading = false;
          if (matches.isEmpty) {
            _error = 'Ingen plats hittades. Prova adress + stad, t.ex. Storgatan 5, Uppsala.';
          }
        });
      } finally {
        completed.complete();
      }
    } catch (_) {
      if (!mounted || revision != _revision) return;
      setState(() {
        _loading = false;
        _error =
            'Kunde inte söka just nu. Kontrollera internet och försök igen.';
      });
    }
  }

  void _select(SelectedEventPlace place) {
    ++_revision;
    _controller.text = place.address;
    _focus.unfocus();
    widget.onChanged(place);
    setState(() {
      _results = [];
      _error = null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focus,
          style: AppTextStyles.bodyLarge,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          onChanged: _textChanged,
          decoration: AppInputs.field(
            hint: 'Adress, café, park eller plats + stad',
            icon: Icons.location_on_outlined,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loading ? null : _search,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(_loading ? 'Söker…' : 'Sök adress'),
          ),
        ),
        if (widget.value != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'Vald plats: ${widget.value!.name} · ${widget.value!.city}',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              _error!,
              style: AppTextStyles.bodySecondary.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: AppDecorations.input,
            child: Column(
              children: [
                for (final place in _results)
                  ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(place.name, style: AppTextStyles.bodyLarge),
                    subtitle: Text(
                      '${place.city} · ${place.address}',
                      style: AppTextStyles.bodySecondary,
                    ),
                    onTap: () => _select(place),
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Adressdata © OpenStreetMap contributors · Nominatim',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
