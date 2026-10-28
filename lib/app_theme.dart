import 'package:flutter/material.dart';

// ============================================================
// COLORS
// ============================================================

class AppColors {
  AppColors._();

  // BACKGROUNDS

  static const Color background = Color(0xFF100D0B);

  static const Color surface = Color(0xFF292521);

  static const Color surfaceDark = Color(0xFF201B18);

  static const Color surfaceSecondary = Color(0xFF211D19);

  static const Color cardFallback = Color(0xFF302824);

  static const Color navigation = Color(0xF22A211F);

  static const Color selectedTab = Color(0xFF554E47);

  // BRAND COLORS

  static const Color primary = Color(0xFFFF9800);

  static const Color primaryLight = Color(0xFFFFB13B);

  // TEXT COLORS

  static const Color textPrimary = Colors.white;

  static const Color textSecondary = Colors.white70;

  static const Color textMuted = Colors.white54;

  static const Color textDisabled = Colors.white30;

  static const Color textDark = Colors.black;

  // TRANSPARENT COLORS

  static const Color transparent = Colors.transparent;

  static const Color border = Color(0x1FFFFFFF);

  static const Color borderSubtle = Color(0x14FFFFFF);

  static const Color selectedNavigation = Color.fromARGB(125, 255, 255, 255);

  // OVERLAYS

  static Color overlayLight = Colors.black.withOpacity(0.15);

  static Color overlayMedium = Colors.black.withOpacity(0.35);

  static Color overlayDark = Colors.black.withOpacity(0.9);
}

// ============================================================
// SPACING
// ============================================================

class AppSpacing {
  AppSpacing._();

  static const double xxs = 3;
  static const double xs = 5;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 15;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 30;
  static const double huge = 40;

  // PAGE PADDING

  static const EdgeInsets page = EdgeInsets.all(20);

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 20);

  static const EdgeInsets filter = EdgeInsets.fromLTRB(20, 20, 20, 35);

  static const EdgeInsets bottomNavigation = EdgeInsets.fromLTRB(28, 0, 28, 15);

  // FORM SPACING

  static const double fieldLabelTop = 24;

  static const double fieldLabelBottom = 8;

  static const double sectionGap = 25;
}

// ============================================================
// BORDER RADIUS
// ============================================================

class AppRadii {
  AppRadii._();

  static const double small = 10;

  static const double medium = 18;

  static const double cardValue = 20;

  static const double chipValue = 20;

  static const double tabValue = 25;

  static const double large = 30;

  static const double navigationValue = 40;

  static final BorderRadius field = BorderRadius.circular(medium);

  static final BorderRadius card = BorderRadius.circular(cardValue);

  static final BorderRadius chip = BorderRadius.circular(chipValue);

  static final BorderRadius tab = BorderRadius.circular(tabValue);

  static final BorderRadius search = BorderRadius.circular(large);

  static final BorderRadius navigation = BorderRadius.circular(navigationValue);

  static final BorderRadius bottomSheet = const BorderRadius.vertical(
    top: Radius.circular(30),
  );
}

// ============================================================
// COMPONENT SIZES
// ============================================================

class AppSizes {
  AppSizes._();

  // SEARCH

  static const double searchHeight = 55;

  static const double searchIconSize = 42;

  // EVENT CARD

  static const double eventCardHeight = 255;

  // NAVIGATION

  static const double navigationHeight = 70;

  static const double navigationButton = 50;

  static const double navigationIcon = 23;

  static const double addIcon = 30;

  // BUTTONS

  static const double primaryButtonHeight = 52;

  // INPUTS

  static const double photoHeight = 180;

  // TABS

  static const double categorySelectorHeight = 48;

  // FILTERS

  static const double activeFilterHeight = 36;

  static const double bottomSheetHandleWidth = 45;

  static const double bottomSheetHandleHeight = 4;
}

// ============================================================
// TEXT STYLES
// ============================================================

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Arial';

  // PAGE TITLE

  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 27,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // SECTION TITLE

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  // FILTER TITLE

  static const TextStyle filterTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // FORM LABEL

  static const TextStyle formLabel = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // BODY TEXT

  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  // EVENT CARD

  static const TextStyle eventTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle eventDate = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle eventLocation = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );

  static const TextStyle eventSpots = TextStyle(
    color: AppColors.primaryLight,
    fontSize: 13,
  );

  static const TextStyle eventQueue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // SEARCH

  static const TextStyle searchInput = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  static const TextStyle searchHint = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
  );

  // TABS

  static const TextStyle tabSelected = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle tabUnselected = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // FILTER CHIPS

  static const TextStyle filterChip = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  // EMPTY STATE

  static const TextStyle emptyMessage = TextStyle(
    color: AppColors.textMuted,
    fontSize: 14,
  );
}

// ============================================================
// DECORATIONS
// ============================================================

class AppDecorations {
  AppDecorations._();

  // SEARCH CONTAINER

  static BoxDecoration search = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadii.search,
    border: Border.all(color: AppColors.border),
  );

  // EVENT CARD

  static BoxDecoration eventCard = BoxDecoration(
    color: AppColors.cardFallback,
    borderRadius: AppRadii.card,
  );

  // INPUT FIELD

  static BoxDecoration input = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadii.field,
  );

  // CATEGORY SELECTOR

  static BoxDecoration categorySelector = BoxDecoration(
    color: AppColors.surfaceSecondary,
    borderRadius: AppRadii.search,
    border: Border.all(color: AppColors.borderSubtle),
  );

  // NAVIGATION BAR

  static BoxDecoration navigation = BoxDecoration(
    color: AppColors.navigation,
    borderRadius: AppRadii.navigation,
    border: Border.all(color: AppColors.borderSubtle),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // FILTER CHIP

  static BoxDecoration filterChip = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadii.chip,
    border: Border.all(color: AppColors.borderSubtle),
  );

  // EVENT IMAGE GRADIENT

  static const LinearGradient eventGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x26000000), Color(0xE6000000)],
  );
}

// ============================================================
// INPUT DECORATIONS
// ============================================================

class AppInputs {
  AppInputs._();

  static InputDecoration field({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: AppRadii.field,
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ============================================================
// BUTTON STYLES
// ============================================================

class AppButtons {
  AppButtons._();

  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textPrimary,
    minimumSize: const Size(0, AppSizes.primaryButtonHeight),
  );
}

// ============================================================
// APP THEME
// ============================================================

class AppTheme {
  AppTheme._();

  static final ThemeData dark = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    fontFamily: AppTextStyles.fontFamily,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),

    // APP BAR
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    // INPUT FIELDS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: AppRadii.field,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.field,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.field,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    // ELEVATED BUTTONS
    elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtons.primary),

    // CHOICE CHIPS
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textPrimary,
      labelStyle: AppTextStyles.body,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.chip),
      side: BorderSide.none,
    ),

    // SLIDERS
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      thumbColor: AppColors.primary,
      inactiveTrackColor: AppColors.surface,
    ),

    // ICONS
    iconTheme: const IconThemeData(color: AppColors.textPrimary),

    // TEXT
    textTheme: const TextTheme(
      bodyMedium: AppTextStyles.body,
      bodyLarge: AppTextStyles.bodyLarge,
      titleLarge: AppTextStyles.pageTitle,
    ),

    // DIVIDERS
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),

    // BOTTOM SHEETS
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.bottomSheet),
    ),
  );
}
