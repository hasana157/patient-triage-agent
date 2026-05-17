import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
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
  final _api = ApiService();
  List<ActionStep>? _steps;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final steps = await _api.getActionPlan(widget.result);
      if (mounted) {
        setState(() {
          _steps = steps;
          _loading = false;
        });
      }
    } catch (e) {
      // Fallback to local generation if backend fails
      final localSteps = _buildLocalSteps(widget.result.priorityLevel);
      if (mounted) {
        setState(() {
          _steps = localSteps;
          _loading = false;
        });
      }
    }
  }

  List<ActionStep> _buildLocalSteps(String priorityLevel) {
    final normalized = priorityLevel.toUpperCase();
    final caseId = widget.result.caseId;
    if (normalized == 'RED' || normalized == 'ORANGE') {
      return [
        ActionStep(
          actionId: 'ACT-$caseId-1',
          caseId: caseId,
          sequence: 1,
          actionType: 'clinical_reassessment',
          title: 'Recheck vitals',
          description: 'Repeat vital signs measurement and compare with baseline.',
          targetRole: 'triage_nurse',
          deadlineMinutes: 5,
          clinicianConfirmationRequired: true,
        ),
        ActionStep(
          actionId: 'ACT-$caseId-2',
          caseId: caseId,
          sequence: 2,
          actionType: 'alert_specialist',
          title: 'Alert emergency doctor',
          description: 'Page the on-call emergency physician for urgent review.',
          targetRole: 'emergency_physician',
          deadlineMinutes: 10,
          clinicianConfirmationRequired: false,
        ),
        ActionStep(
          actionId: 'ACT-$caseId-3',
          caseId: caseId,
          sequence: 3,
          actionType: 'reserve_resource',
          title: 'Move patient to resus area',
          description: 'Transfer patient to resuscitation area for close monitoring.',
          targetRole: 'resource_coordinator',
          deadlineMinutes: 15,
          clinicianConfirmationRequired: false,
        ),
        ActionStep(
          actionId: 'ACT-$caseId-4',
          caseId: caseId,
          sequence: 4,
          actionType: 'reserve_resource',
          title: 'Reserve oxygen and ECG',
          description: 'Reserve oxygen and ECG equipment for this patient.',
          targetRole: 'resource_coordinator',
          deadlineMinutes: 20,
          clinicianConfirmationRequired: false,
        ),
        ActionStep(
          actionId: 'ACT-$caseId-5',
          caseId: caseId,
          sequence: 5,
          actionType: 'schedule_followup',
          title: 'Schedule reassessment in 5 min',
          description: 'Set a reassessment reminder for five minutes.',
          targetRole: 'triage_nurse',
          deadlineMinutes: 25,
          clinicianConfirmationRequired: false,
        ),
      ];
    }
    if (normalized == 'YELLOW') {
      return [
        ActionStep(
          actionId: 'ACT-$caseId-1',
          caseId: caseId,
          sequence: 1,
          actionType: 'alert_specialist',
          title: 'Notify attending nurse',
          description: 'Inform the attending nurse of the patient status.',
          targetRole: 'triage_nurse',
          deadlineMinutes: 5,
          clinicianConfirmationRequired: true,
        ),
        ActionStep(
          actionId: 'ACT-$caseId-2',
          caseId: caseId,
          sequence: 2,
          actionType: 'administer_protocol',
          title: 'Move to urgent queue',
          description: 'Transfer the patient into the urgent care queue.',
          targetRole: 'triage_nurse',
          deadlineMinutes: 10,
          clinicianConfirmationRequired: false,
        ),
        ActionStep(
          actionId: 'ACT-$caseId-3',
          caseId: caseId,
          sequence: 3,
          actionType: 'schedule_followup',
          title: 'Schedule reassessment in 15 min',
          description: 'Set a follow-up check in fifteen minutes.',
          targetRole: 'triage_nurse',
          deadlineMinutes: 15,
          clinicianConfirmationRequired: false,
        ),
      ];
    }
    return [
      ActionStep(
        actionId: 'ACT-$caseId-1',
        caseId: caseId,
        sequence: 1,
        actionType: 'administer_protocol',
        title: 'Register in standard queue',
        description: 'Place the patient in the standard queue for routine processing.',
        targetRole: 'triage_nurse',
        deadlineMinutes: 30,
        clinicianConfirmationRequired: false,
      ),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                  children: List.generate(_steps!.length, (i) {
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

                // Step cards — rendered dynamically from _steps
                ...List.generate(_steps!.length, (i) {
                  final step = _steps![i];
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
                                        step.title,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A2B3C)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        step.description,
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