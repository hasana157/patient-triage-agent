import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Displays a list of red flags, each in a red-tinted row with a warning icon.
///
/// Renders nothing (SizedBox.shrink) if [flags] is empty.
class RedFlagList extends StatelessWidget {
  const RedFlagList({super.key, required this.flags});

  /// List of red flag description strings.
  final List<String> flags;

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: AppTheme.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Red Flags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.red,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...flags.map((flag) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          flag,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.red.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
