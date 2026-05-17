import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Displays a patient's risk score as a linear progress bar and confidence
/// as a percentage label below.
///
/// The progress bar colour is derived from the risk level.
class RiskScoreCard extends StatelessWidget {
  const RiskScoreCard({
    super.key,
    required this.riskScore,
    required this.confidence,
  });

  /// Risk score from 0.0 to 1.0.
  final double riskScore;

  /// Confidence from 0.0 to 1.0.
  final double confidence;

  Color _riskColor() {
    if (riskScore >= 0.85) return AppTheme.red;
    if (riskScore >= 0.70) return AppTheme.orange;
    if (riskScore >= 0.45) return AppTheme.yellow;
    return AppTheme.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor();
    final riskPct = (riskScore * 100).toStringAsFixed(0);
    final confPct = (confidence * 100).toStringAsFixed(0);

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, size: 20),
              const SizedBox(width: 8),
              Text(
                'Risk Score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                '$riskPct%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: riskScore,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Model confidence: $confPct%',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
