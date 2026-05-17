import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'execution_simulation_screen.dart';

class ActionChainScreen extends StatefulWidget {
  const ActionChainScreen({
    super.key,
    required this.result,
    required this.patientCode,
    this.isDemo = false,
  });

  final TriageResult result;
  final String patientCode;
  final bool isDemo;

  @override
  State<ActionChainScreen> createState() => _ActionChainScreenState();
}

class _ActionChainScreenState extends State<ActionChainScreen> {
  late final List<Map<String, String>> _steps;

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps(widget.result.priorityLevel);
  }

  List<Map<String, String>> _buildSteps(String priorityLevel) {
    final normalized = priorityLevel.toUpperCase();
    if (normalized == 'RED' || normalized == 'ORANGE') {
      return [
        {'title': 'Recheck vitals', 'description': 'Repeat vital signs measurement and compare with baseline.'},
        {'title': 'Alert emergency doctor', 'description': 'Page the on-call emergency physician for urgent review.'},
        {'title': 'Move patient to resus area', 'description': 'Transfer patient to resuscitation area for close monitoring.'},
        {'title': 'Reserve oxygen and ECG', 'description': 'Reserve oxygen and ECG equipment for this patient.'},
        {'title': 'Schedule reassessment in 5 min', 'description': 'Set a reassessment reminder for five minutes.'},
      ];
    }
    if (normalized == 'YELLOW') {
      return [
        {'title': 'Notify attending nurse', 'description': 'Inform the attending nurse of the patient status.'},
        {'title': 'Move to urgent queue', 'description': 'Transfer the patient into the urgent care queue.'},
        {'title': 'Schedule reassessment in 15 min', 'description': 'Set a follow-up check in fifteen minutes.'},
      ];
    }
    return [
      {'title': 'Register in standard queue', 'description': 'Place the patient in the standard queue for routine processing.'},
    ];
  }

  Color _feasibilityColor(int index) =>
      index < 3 ? AppTheme.success : AppTheme.warning;

  String _feasibilityLabel(int index) =>
      index < 3 ? 'Feasible' : 'Constrained';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Action Plan — ${widget.patientCode}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTheme.buildSafetyBanner(),
          const SizedBox(height: 16),

          // Feasibility badges
          const Text('Feasibility',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2B3C))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_steps.length, (i) {
              final color = _feasibilityColor(i);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Step ${i + 1}: ${_feasibilityLabel(i)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Step cards — rendered directly, no widget wrapper
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            final feasColor = _feasibilityColor(i);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left accent bar
                  Container(width: 4, color: feasColor),
                  // Card content
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
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step number circle
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAction
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Step text
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title']!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A2B3C)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step['description']!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4A5568)),
                                ),
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

          // Simulate Execution button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExecutionSimulationScreen(
                    result: widget.result,
                    patientCode: widget.patientCode,
                    isDemo: widget.isDemo,
                  ),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Simulate Execution',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAction,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Note: Real actions come from POST /api/actions/plan in Phase 6A.',
              style: TextStyle(
                  fontSize: 11, color: Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}