import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Grouped numeric input fields for patient vital signs.
///
/// Fields: HR, Systolic BP, Diastolic BP, RR, SpO2, Temp (°C).
/// Consciousness: dropdown (Alert / Voice / Pain / Unresponsive / Confused).
/// All fields are optional — shows a yellow warning icon if left empty.
class VitalsInputCard extends StatefulWidget {
  const VitalsInputCard({
    super.key,
    required this.onChanged,
    this.initialVitals,
  });

  /// Called whenever any vital sign value changes.
  final void Function(Map<String, dynamic>) onChanged;

  /// Optional initial values to pre-populate.
  final Vitals? initialVitals;

  @override
  State<VitalsInputCard> createState() => _VitalsInputCardState();
}

class _VitalsInputCardState extends State<VitalsInputCard> {
  late final TextEditingController _hrCtrl;
  late final TextEditingController _sbpCtrl;
  late final TextEditingController _dbpCtrl;
  late final TextEditingController _rrCtrl;
  late final TextEditingController _spo2Ctrl;
  late final TextEditingController _tempCtrl;
  String? _consciousness;

  static const _consciousnessOptions = [
    'Alert',
    'Voice',
    'Pain',
    'Unresponsive',
    'Confused',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.initialVitals;
    _hrCtrl = TextEditingController(text: v?.heartRate?.toString() ?? '');
    _sbpCtrl = TextEditingController(text: v?.systolicBp?.toString() ?? '');
    _dbpCtrl = TextEditingController(text: v?.diastolicBp?.toString() ?? '');
    _rrCtrl = TextEditingController(text: v?.respiratoryRate?.toString() ?? '');
    _spo2Ctrl = TextEditingController(text: v?.spo2?.toString() ?? '');
    _tempCtrl = TextEditingController(text: v?.temperatureC?.toString() ?? '');
    _consciousness = v?.consciousness;
  }

  @override
  void dispose() {
    _hrCtrl.dispose();
    _sbpCtrl.dispose();
    _dbpCtrl.dispose();
    _rrCtrl.dispose();
    _spo2Ctrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildVitals() {
    final heartRate = int.tryParse(_hrCtrl.text);
    final systolicBp = int.tryParse(_sbpCtrl.text);
    final diastolicBp = int.tryParse(_dbpCtrl.text);
    final respiratoryRate = int.tryParse(_rrCtrl.text);
    final spo2 = int.tryParse(_spo2Ctrl.text);
    final temperatureC = double.tryParse(_tempCtrl.text);

    return {
      'heart_rate': heartRate,
      'systolic_bp': systolicBp,
      'diastolic_bp': diastolicBp,
      'respiratory_rate': respiratoryRate,
      'spo2': spo2,
      'temperature_c': temperatureC,
      'consciousness': _consciousness,
    };
  }

  void _onFieldChanged([String? _]) {
    widget.onChanged(_buildVitals());
  }

  Widget _numericField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    final isEmpty = controller.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            if (isEmpty) ...[
              const SizedBox(width: 4),
              const Icon(Icons.warning_amber_rounded, color: AppTheme.yellow, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: _onFieldChanged,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Vital Signs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 1: HR, RR
          Row(
            children: [
              Expanded(
                child: _numericField(
                  label: 'Heart Rate (bpm)',
                  hint: 'e.g. 80',
                  controller: _hrCtrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numericField(
                  label: 'Resp. Rate (/min)',
                  hint: 'e.g. 18',
                  controller: _rrCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: SBP, DBP
          Row(
            children: [
              Expanded(
                child: _numericField(
                  label: 'Systolic BP (mmHg)',
                  hint: 'e.g. 120',
                  controller: _sbpCtrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numericField(
                  label: 'Diastolic BP (mmHg)',
                  hint: 'e.g. 80',
                  controller: _dbpCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: SpO2, Temp
          Row(
            children: [
              Expanded(
                child: _numericField(
                  label: 'SpO2 (%)',
                  hint: 'e.g. 98',
                  controller: _spo2Ctrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numericField(
                  label: 'Temp (°C)',
                  hint: 'e.g. 37.0',
                  controller: _tempCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Consciousness dropdown
          Row(
            children: [
              const Text(
                'Consciousness',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              if (_consciousness == null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.warning_amber_rounded, color: AppTheme.yellow, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: DropdownButtonFormField<String>(
              initialValue: _consciousness,
              isExpanded: true,
              hint: const Text('Select level'),
              items: _consciousnessOptions
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) {
                setState(() => _consciousness = val);
                _onFieldChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}
