import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'patient_intake_screen.dart';
import 'triage_result_screen.dart';
import 'action_chain_screen.dart';
import 'execution_simulation_screen.dart';
import 'queue_dashboard_screen.dart';
import 'logs_screen.dart';

/// Landing screen with three primary actions and a safety disclaimer.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  bool _demoLoading = false;

  Future<void> _runDemo() async {
    setState(() => _demoLoading = true);
    try {
      final cases = await _api.getDemoCases();
      if (cases.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No demo cases found.')),
          );
        }
        return;
      }
      // Use CASE-001 (first case)
      final demoCase = cases.first;
      final result = await _api.evaluateTriage(demoCase);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Running full demo — auto-navigating through all screens...')),
        );

        // Step 1 — Intake screen pre-filled
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PatientIntakeScreen(
            isDemoMode: true,
            demoCase: demoCase,
          ),
        ));
        await Future.delayed(const Duration(seconds: 4));

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TriageResultScreen(
              result: result,
              patientCode: demoCase.patientCode,
              isDemo: true,
            ),
          ),
        );
      }
      
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActionChainScreen(
            result: result,
            patientCode: demoCase.patientCode,
            isDemo: true,
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExecutionSimulationScreen(
            result: result,
            patientCode: demoCase.patientCode,
            isDemo: true,
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QueueDashboardScreen(
            highlightCaseId: result.caseId,
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LogsScreen(
            result: result,
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _demoLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TriageFlow AI')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // App icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.health_and_safety,
                      size: 40, color: AppTheme.blue),
                ),
                const SizedBox(height: 20),
                Text(
                  'TriageFlow AI',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Clinical Decision Support Prototype',
                  style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 16),
                // Safety disclaimer
                AppTheme.buildSafetyBanner(),
                const SizedBox(height: 24),
                // Action buttons
                _ActionButton(
                  icon: Icons.play_circle_outline,
                  label: 'Run Demo',
                  subtitle: 'Evaluate CASE-001 end-to-end',
                  color: AppTheme.primaryAction,
                  loading: _demoLoading,
                  onTap: _demoLoading ? null : _runDemo,
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.person_add_outlined,
                  label: 'New Patient',
                  subtitle: 'Enter patient data for triage',
                  color: AppTheme.primaryAction,
                  onTap: () => Navigator.pushNamed(context, '/intake'),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.dashboard_outlined,
                  label: 'Queue Dashboard',
                  subtitle: 'View live priority queue',
                  color: AppTheme.primaryAction,
                  isOutlined: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const QueueDashboardScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Synthetic data only · Hackathon prototype',
                  style: TextStyle(fontSize: 11, color: AppTheme.captionText),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.loading = false,
    this.isOutlined = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: BorderSide(color: color),
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _buildContent(color, color, AppTheme.secondaryText),
      );
    } else {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _buildContent(Colors.white, Colors.white, Colors.white70),
      );
    }
  }

  Widget _buildContent(Color iconColor, Color titleColor, Color subtitleColor) {
    return Row(
      children: [
        loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: iconColor),
              )
            : Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16, color: titleColor)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      TextStyle(fontSize: 13, color: subtitleColor)),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: iconColor.withValues(alpha: 0.5)),
      ],
    );
  }
}
