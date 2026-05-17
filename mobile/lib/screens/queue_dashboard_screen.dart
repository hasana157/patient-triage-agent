import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/outcome_metric_card.dart';

class QueueDashboardScreen extends StatefulWidget {
  const QueueDashboardScreen({super.key, this.highlightCaseId});
  final String? highlightCaseId;

  @override
  State<QueueDashboardScreen> createState() => _QueueDashboardScreenState();
}

class _QueueDashboardScreenState extends State<QueueDashboardScreen> {
  final _api = ApiService();
  List<TriageResult>? _queue;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final q = await _api.getQueue();
      if (mounted) setState(() {
        _queue = q;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: const TextStyle(
                              color: Color(0xFF1A2B3C))),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadQueue,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadQueue,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AppTheme.buildSafetyBanner(),
                      const SizedBox(height: 16),

                      // Outcome metrics
                      const Text('Outcome Metrics',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2B3C))),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: const [
                          OutcomeMetricCard(
                            label: 'Queue Position',
                            before: '12',
                            after: '2',
                            lowerIsBetter: true,
                          ),
                          OutcomeMetricCard(
                            label: 'Wait Time (min)',
                            before: '45',
                            after: '8',
                            lowerIsBetter: true,
                          ),
                          OutcomeMetricCard(
                            label: 'Risk Score',
                            before: '0.45',
                            after: '0.82',
                            lowerIsBetter: false,
                          ),
                          OutcomeMetricCard(
                            label: 'Alerts Sent',
                            before: '0',
                            after: '3',
                            lowerIsBetter: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Live queue header
                      Row(
                        children: [
                          const Text('Live Queue',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A2B3C))),
                          const Spacer(),
                          Text('${_queue?.length ?? 0} patients',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4A5568))),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Patient cards
                      if (_queue != null)
                        ...List.generate(_queue!.length, (i) {
                          final r = _queue![i];
                          final isHighlighted =
                              r.caseId == widget.highlightCaseId;
                          final priorityColor =
                              AppTheme.priorityColor(r.priorityLevel);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Left accent bar
                                Container(
                                    width: 4,
                                    color: priorityColor),
                                // Card content
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0xFFD1D9E0),
                                            width: 1),
                                        right: BorderSide(
                                            color: Color(0xFFD1D9E0),
                                            width: 1),
                                        bottom: BorderSide(
                                            color: Color(0xFFD1D9E0),
                                            width: 1),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              r.caseId,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFF1A2B3C)),
                                            ),
                                            if (isHighlighted) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.star,
                                                  color: Color(
                                                      0xFF1565C0),
                                                  size: 16),
                                            ],
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: priorityColor
                                                    .withValues(
                                                        alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(12),
                                              ),
                                              child: Text(
                                                r.priorityLevel
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    fontSize: 10,
                                                    color:
                                                        priorityColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Risk: ${(r.riskScore * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF4A5568)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          r.reasoning.isNotEmpty
                                              ? r.reasoning.first
                                              : 'No details available',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF718096)),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                          icon: const Icon(Icons.home_outlined),
                          label: const Text('Back to Home',
                              style: TextStyle(fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryAction,
                            side: const BorderSide(
                                color: AppTheme.primaryAction),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}