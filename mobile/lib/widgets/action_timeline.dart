import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Vertical timeline displaying action steps with status icons.
/// Shows placeholder text if [steps] is empty.
class ActionTimeline extends StatelessWidget {
  const ActionTimeline({super.key, required this.steps});
  final List<ActionStep> steps;

  Widget _statusMarker(String status) {
    final color = _statusColor(status);
    if (status == 'in_progress') {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Icon(
      status == 'done'
          ? Icons.check_circle
          : status == 'failed'
              ? Icons.cancel
              : Icons.schedule,
      size: 20,
      color: color,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return AppTheme.success;
      case 'in_progress':
        return AppTheme.fallbackInfo;
      case 'failed':
        return AppTheme.errorCritical;
      case 'planned':
      default:
        return AppTheme.captionText;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Container(
        decoration: AppTheme.cardDecoration(),
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        child: const Column(
          children: [
            Icon(Icons.playlist_add, size: 40, color: Color(0xFF718096)),
            SizedBox(height: 12),
            Text('Actions will appear after evaluation',
                style: TextStyle(color: Color(0xFF718096), fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];

        final color = _statusColor(step.status);

        return Container(
          decoration: AppTheme.cardDecoration(),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: _statusMarker(step.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Step ${step.sequence}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                                fontWeight: FontWeight.w600)),
                        Text(step.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A2B3C))),
                      ],
                    ),
                  ),
                  Text(step.status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              Text(step.description,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF4A5568), fontWeight: FontWeight.w400)),
              const SizedBox(height: 12),
            ],
          ),
        );
      }),
    );
  }
}
