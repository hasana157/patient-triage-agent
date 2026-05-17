import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Colour-coded rounded chip displaying a triage priority level.
///
/// Levels: RED, ORANGE, YELLOW, GREEN, BLUE, MANUAL_REVIEW.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.level,
    this.large = false,
  });

  /// One of: RED, ORANGE, YELLOW, GREEN, BLUE, MANUAL_REVIEW.
  final String level;

  /// If true, renders a larger badge suitable for result screen headers.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.priorityColor(level);
    final fgColor = AppTheme.priorityForeground(level);
    final label = level.replaceAll('_', ' ');

    if (large) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fgColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
