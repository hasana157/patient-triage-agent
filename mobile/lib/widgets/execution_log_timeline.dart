import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Timestamped execution log list, colour-coded by status.
/// Status colours: success=green, failed=red, retry=orange, fallback=blue.
class ExecutionLogTimeline extends StatelessWidget {
  const ExecutionLogTimeline({super.key, required this.logs});
  final List<ExecutionLog> logs;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return AppTheme.success;
      case 'failed':
        return AppTheme.errorCritical;
      case 'retry':
        return AppTheme.retry;
      case 'fallback':
        return AppTheme.fallbackInfo;
      default:
        return AppTheme.captionText;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline;
      case 'failed':
        return Icons.error_outline;
      case 'retry':
        return Icons.refresh;
      case 'fallback':
        return Icons.alt_route;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts);
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      final s = dt.second.toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      return ts;
    }
  }

  Color _eventTypeColor(String eventType) {
    if (eventType.contains('fallback')) return AppTheme.fallbackInfo;
    if (eventType.contains('retry')) return AppTheme.retry;
    return AppTheme.captionText;
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        decoration: AppTheme.cardDecoration(),
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        child: const Column(
          children: [
            Icon(Icons.receipt_long, size: 40, color: Color(0xFF718096)),
            SizedBox(height: 12),
            Text('No execution logs yet',
                style: TextStyle(color: Color(0xFF718096), fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(logs.length, (i) {
        final log = logs[i];
        final isLast = i == logs.length - 1;
        final color = _statusColor(log.status);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_formatTimestamp(log.timestamp),
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w400)),
                const SizedBox(width: 8),
                Icon(_statusIcon(log.status), color: color, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              decoration: AppTheme.accentCardDecoration(color),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(log.status.toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _eventTypeColor(log.eventType)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                            log.eventType.replaceAll('_', ' '),
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF4A5568))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(log.eventType.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A2B3C), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(log.message,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568))),
                  if (log.retryCount > 0) ...[
                    const SizedBox(height: 4),
                    Text('Retry #${log.retryCount}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.retry)),
                  ],
                ],
              ),
            ),
            if (!isLast) const SizedBox(height: 12),
          ],
        );
      }),
    );
  }
}
