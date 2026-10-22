import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Shared, preselected cover photos. Only the URL is stored in Firestore.
/// No image uploads or Firebase Storage are required.
class EventCoverGallery {
  static const covers = <EventCover>[
    EventCover('Padel', 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200'),
    EventCover('Running', 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=1200'),
    EventCover('Coffee', 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=1200'),
    EventCover('Drinks', 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=1200'),
    EventCover('Walk', 'https://images.unsplash.com/photo-1472396961693-142e6e269027?w=1200'),
    EventCover('Gaming', 'https://images.unsplash.com/photo-1535223289827-42f1e9919769?w=1200'),
  ];

  static Future<String?> choose(BuildContext context, {String? selected}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Choose event cover', style: TextStyle(color: AppColors.textPrimary, fontSize: 23, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Select a photo for your event', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 18),
              Expanded(child: GridView.builder(
                itemCount: covers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.25, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemBuilder: (context, index) {
                  final cover = covers[index];
                  final active = cover.url == selected;
                  return InkWell(
                    onTap: () => Navigator.pop(sheetContext, cover.url),
                    borderRadius: BorderRadius.circular(14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.network(cover.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.surface, child: Icon(Icons.image_not_supported_outlined))),
                        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]))),
                        Positioned(left: 12, bottom: 10, child: Text(cover.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        if (active) const Positioned(top: 9, right: 9, child: Icon(Icons.check_circle, color: AppColors.primary)),
                      ]),
                    ),
                  );
                },
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

class EventCover {
  final String label;
  final String url;
  const EventCover(this.label, this.url);
}