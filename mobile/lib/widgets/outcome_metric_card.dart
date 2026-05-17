import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Side-by-side before/after values with a coloured arrow.
/// Green arrow if [lowerIsBetter] and after < before (or vice versa).
class OutcomeMetricCard extends StatelessWidget {
  const OutcomeMetricCard({
    super.key,
    required this.label,
    required this.before,
    required this.after,
    this.lowerIsBetter = true,
  });

  final String label;
  final String before;
  final String after;
  /// If true, a lower "after" value is better (e.g. wait time, queue position).
  /// If false, a higher "after" value is better (e.g. alerts sent).
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final beforeNum = double.tryParse(before);
    final afterNum = double.tryParse(after);

    bool isBetter = false;
    if (beforeNum != null && afterNum != null) {
      isBetter = lowerIsBetter
          ? afterNum < beforeNum
          : afterNum > beforeNum;
    }

    final arrowColor = isBetter ? AppTheme.success : AppTheme.errorCritical;
    final arrowIcon =
        isBetter ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(before,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryText)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(arrowIcon, color: arrowColor, size: 20),
              ),
              Text(after,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: arrowColor)),
            ],
          ),
        ],
      ),
    );
  }
}
