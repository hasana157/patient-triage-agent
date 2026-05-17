import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Displays contradictions between clinical evidence.
///
/// Renders nothing (SizedBox.shrink) if [contradictions] is empty.
/// Phase 4 will populate this with real data.
class ContradictionCard extends StatelessWidget {
  const ContradictionCard({super.key, required this.contradictions});

  /// List of contradictions to display.
  final List<Contradiction> contradictions;

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppTheme.red;
      case 'medium':
        return AppTheme.orange;
      case 'low':
        return AppTheme.yellow;
      default:
        return AppTheme.captionText;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (contradictions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, size: 20),
              const SizedBox(width: 8),
              Text(
                'Contradictions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...contradictions.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _severityColor(c.severity),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              c.severity.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.conflictType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Evidence A',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(c.evidenceA,
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.compare_arrows,
                                size: 16, color: Colors.grey),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Evidence B',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(c.evidenceB,
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (c.resolutionAction.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Resolution: ${c.resolutionAction}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
