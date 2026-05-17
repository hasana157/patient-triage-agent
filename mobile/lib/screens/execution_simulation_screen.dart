import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'queue_dashboard_screen.dart';

class ExecutionSimulationScreen extends StatelessWidget {
  const ExecutionSimulationScreen({
    super.key,
    required this.result,
    required this.patientCode,
    this.isDemo = false,
  });

  final TriageResult result;
  final String patientCode;
  final bool isDemo;

  static const List<Map<String, String>> _logs = [
    {'time': '09:00:01', 'status': 'success',  'title': 'Recheck vitals',           'message': 'Vitals confirmed and recorded.'},
    {'time': '09:00:03', 'status': 'failed',   'title': 'Alert emergency doctor',    'message': 'API timeout — doctor unreachable.'},
    {'time': '09:00:05', 'status': 'retry',    'title': 'Alert emergency doctor',    'message': 'Retrying doctor alert...'},
    {'time': '09:00:07', 'status': 'failed',   'title': 'Alert emergency doctor',    'message': 'Retry failed — still unreachable.'},
    {'time': '09:00:08', 'status': 'fallback', 'title': 'Fallback: urgent queue',    'message': 'Added to local urgent queue.'},
    {'time': '09:00:10', 'status': 'success',  'title': 'Reserve oxygen and ECG',    'message': 'Resources reserved successfully.'},
    {'time': '09:00:12', 'status': 'success',  'title': 'Schedule reassessment',     'message': 'Timer set for 5 minutes.'},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'success':  return const Color(0xFF2E7D32);
      case 'failed':   return const Color(0xFFC62828);
      case 'retry':    return const Color(0xFFE65100);
      case 'fallback': return const Color(0xFF1565C0);
      default:         return const Color(0xFF718096);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'success':  return Icons.check_circle;
      case 'failed':   return Icons.error;
      case 'retry':    return Icons.refresh;
      case 'fallback': return Icons.alt_route;
      default:         return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final successCount = _logs.where((l) => l['status'] == 'success').length;
    final failCount = _logs.where((l) => l['status'] == 'failed').length;

    return Scaffold(
      appBar: AppBar(title: Text('Execution — $patientCode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTheme.buildSafetyBanner(),
          const SizedBox(height: 16),

          // Summary card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D9E0)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.terminal,
                    size: 20, color: Color(0xFF4A5568)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Simulation Results',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1A2B3C))),
                      const SizedBox(height: 2),
                      Text('Case ${result.caseId} · ${_logs.length} events',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A5568))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$successCount OK',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$failCount Fail',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Log steps
          ...List.generate(_logs.length, (i) {
            final log = _logs[i];
            final color = _statusColor(log['status']!);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 4, color: color),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                              color: Color(0xFFD1D9E0), width: 1),
                          right: BorderSide(
                              color: Color(0xFFD1D9E0), width: 1),
                          bottom: BorderSide(
                              color: Color(0xFFD1D9E0), width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_statusIcon(log['status']!),
                              color: color, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(log['time']!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF718096))),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                          log['status']!.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: color,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(log['title']!,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A2B3C))),
                                const SizedBox(height: 4),
                                Text(log['message']!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF4A5568))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QueueDashboardScreen(
                    highlightCaseId: result.caseId,
                  ),
                ),
              ),
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text('View Outcome Dashboard',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Note: Real execution comes from POST '
              '/api/actions/execute in Phase 6B.',
              style: TextStyle(fontSize: 11, color: Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}