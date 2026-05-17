import 'package:flutter/material.dart';

/// Centralised theme for the TriageFlow AI app.
///
/// Design rules:
/// - Hospital dashboard aesthetic: clean, high contrast, no decorative gradients
/// - White card backgrounds with a single 1dp border
/// - Priority colour used as left border accent on cards, not as full background fill
/// - Font: system default (no custom fonts)
/// - Touch targets: minimum 48×48dp on all interactive elements
class AppTheme {
  AppTheme._();

  // BACKGROUNDS
  static const Color appBackground = Color(0xFFF0F4F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFD1D9E0);

  // TYPOGRAPHY
  static const Color primaryText = Color(0xFF1A2B3C);
  static const Color secondaryText = Color(0xFF4A5568);
  static const Color captionText = Color(0xFF718096);
  static const Color cardTitle = Color(0xFF1A2B3C);
  static const Color bodyText = Color(0xFF2D3748);

  // PRIORITY COLOURS
  static const Color red = Color(0xFFD32F2F);
  static const Color orange = Color(0xFFE65100);
  static const Color yellow = Color(0xFFF9A825);
  static const Color green = Color(0xFF2E7D32);
  static const Color blue = Color(0xFF1565C0);
  static const Color manualReview = Color(0xFF546E7A);

  // ACCENT COLOURS
  static const Color primaryAction = Color(0xFF1565C0);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color errorCritical = Color(0xFFC62828);
  static const Color fallbackInfo = Color(0xFF1565C0);
  static const Color retry = Color(0xFFE65100);

  // SAFETY BANNER
  static const Color safetyBannerBg = Color(0xFFFFF8E1);
  static const Color safetyBannerBorder = Color(0xFFF9A825);
  static const Color safetyBannerIcon = Color(0xFFF9A825);
  static const Color safetyBannerText = Color(0xFF4A5568);

  static const double minTouchTarget = 48.0;

  /// Maps a priority level string to its colour.
  static Color priorityColor(String level) {
    switch (level.toUpperCase()) {
      case 'RED':
        return red;
      case 'ORANGE':
        return orange;
      case 'YELLOW':
        return yellow;
      case 'GREEN':
        return green;
      case 'BLUE':
        return blue;
      case 'MANUAL_REVIEW':
        return manualReview;
      default:
        return manualReview;
    }
  }

  /// Returns a high-contrast foreground colour for text on a priority colour.
  static Color priorityForeground(String level) {
    switch (level.toUpperCase()) {
      case 'YELLOW':
        return primaryText;
      default:
        return Colors.white;
    }
  }

  static String priorityDescription(String level) {
    switch (level.toUpperCase()) {
      case 'RED':
        return 'Critical — Immediate clinician review required';
      case 'ORANGE':
        return 'Emergency — Urgent clinician review';
      case 'YELLOW':
        return 'Urgent — Timely care needed';
      case 'GREEN':
        return 'Semi-urgent — Standard queue';
      case 'BLUE':
        return 'Non-urgent — Routine care';
      case 'MANUAL_REVIEW':
        return 'Manual Review — Clinician assessment required';
      default:
        return 'Priority under review';
    }
  }

  /// Standard card decoration: white background, 1dp border, 8dp radius.
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: cardBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  /// Card decoration with a coloured left accent border.
  static BoxDecoration accentCardDecoration(Color accentColor) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(8),
      border: Border(
        left: BorderSide(color: accentColor, width: 4),
        top: const BorderSide(color: cardBorder, width: 1),
        right: const BorderSide(color: cardBorder, width: 1),
        bottom: const BorderSide(color: cardBorder, width: 1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  static Widget buildSafetyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: safetyBannerBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: safetyBannerBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user, size: 18, color: safetyBannerIcon),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Clinician must confirm. Not for clinical deployment.',
              style: TextStyle(
                fontSize: 12,
                color: safetyBannerText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: appBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAction,
        brightness: Brightness.light,
        surface: cardBackground,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBackground,
        foregroundColor: primaryText,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          backgroundColor: primaryAction,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          foregroundColor: primaryAction,
          side: const BorderSide(color: primaryAction),
          backgroundColor: cardBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          foregroundColor: primaryAction,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryAction, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorCritical),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryText),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primaryText),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cardTitle),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: bodyText),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: bodyText),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: captionText),
      ),
    );
  }
}
