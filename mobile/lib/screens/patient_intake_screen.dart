import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/vitals_input_card.dart';
import '../widgets/symptom_chip_selector.dart';
import 'triage_result_screen.dart';

class PatientIntakeScreen extends StatefulWidget {
  const PatientIntakeScreen({
    super.key,
    this.isDemoMode = false,
    this.demoCase,
  });

  final bool isDemoMode;
  final PatientCase? demoCase;

  @override
  State<PatientIntakeScreen> createState() => _PatientIntakeScreenState();
}

class _PatientIntakeScreenState extends State<PatientIntakeScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _patientCodeCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _complaintCtrl = TextEditingController();
  final _nurseNoteCtrl = TextEditingController();
  String _sex = 'Unknown';
  bool _pregnant = false;
  int _painScore = 0;
  List<String> _symptoms = [];
  Vitals? _vitals;

  @override
  void initState() {
    super.initState();
    if (widget.isDemoMode && widget.demoCase != null) {
      _prefillFromDemo(widget.demoCase!);
    }
  }

  void _prefillFromDemo(PatientCase c) {
    _patientCodeCtrl.text = c.patientCode;
    _ageCtrl.text = c.age.toString();
    _durationCtrl.text = (c.durationMinutes ?? 0).toString();
    _complaintCtrl.text = c.chiefComplaint;
    _nurseNoteCtrl.text = c.nurseNote;
    _sex = _capitalise(c.sex);
    _pregnant = c.pregnant ?? false;
    _painScore = c.painScore ?? 0;
    _symptoms = List<String>.from(c.symptoms);
    _vitals = c.vitals;
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  void dispose() {
    _patientCodeCtrl.dispose();
    _ageCtrl.dispose();
    _durationCtrl.dispose();
    _complaintCtrl.dispose();
    _nurseNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isDemoMode) return;
    if (!_formKey.currentState!.validate()) return;
    if (_symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final pc = PatientCase(
        caseId: 'CASE-NEW-${DateTime.now().millisecondsSinceEpoch}',
        patientCode: _patientCodeCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        sex: _sex.toLowerCase(),
        pregnant: _sex == 'Female' ? _pregnant : null,
        chiefComplaint: _complaintCtrl.text.trim(),
        symptoms: _symptoms,
        durationMinutes: int.tryParse(_durationCtrl.text.trim()),
        painScore: _painScore,
        vitals: _vitals,
        nurseNote: _nurseNoteCtrl.text.trim(),
        arrivalTime: DateTime.now().toIso8601String(),
        currentWaitMinutes: 0,
      );

      final result = await _api.evaluateTriage(pc);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TriageResultScreen(
              result: result,
              patientCode: pc.patientCode,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Patient')),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Evaluating patient…',
                      style: TextStyle(fontSize: 15,
                          color: Color(0xFF1A2B3C))),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Demo mode banner
                  if (widget.isDemoMode)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      color: const Color(0xFF1565C0),
                      child: const Row(
                        children: [
                          Icon(Icons.play_circle_outline,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo mode — CASE-001 pre-filled. '
                              'Auto-advancing in 3 seconds...',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Safety banner
                        AppTheme.buildSafetyBanner(),
                        const SizedBox(height: 16),

                        // Patient code
                        const _Label('Patient Code *'),
                        TextFormField(
                          controller: _patientCodeCtrl,
                          enabled: !widget.isDemoMode,
                          decoration: const InputDecoration(
                              hintText: 'e.g. PT-0042'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Patient code is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Age
                        const _Label('Age *'),
                        TextFormField(
                          controller: _ageCtrl,
                          enabled: !widget.isDemoMode,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(hintText: 'e.g. 45'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Age is required';
                            }
                            final age = int.tryParse(v.trim());
                            if (age == null || age < 0 || age > 120) {
                              return 'Age must be 0–120';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sex
                        const _Label('Sex'),
                        DropdownButtonFormField<String>(
                          initialValue: _sex,
                          items: const [
                            DropdownMenuItem(
                                value: 'Female', child: Text('Female')),
                            DropdownMenuItem(
                                value: 'Male', child: Text('Male')),
                            DropdownMenuItem(
                                value: 'Other', child: Text('Other')),
                            DropdownMenuItem(
                                value: 'Unknown', child: Text('Unknown')),
                          ],
                          onChanged: widget.isDemoMode
                              ? null
                              : (v) => setState(() {
                                    _sex = v ?? 'Unknown';
                                    if (_sex != 'Female') _pregnant = false;
                                  }),
                        ),
                        const SizedBox(height: 16),

                        // Pregnant
                        if (_sex == 'Female') ...[
                          SwitchListTile(
                            title: const Text('Pregnant',
                                style: TextStyle(
                                    color: Color(0xFF1A2B3C))),
                            value: _pregnant,
                            onChanged: widget.isDemoMode
                                ? null
                                : (v) => setState(() => _pregnant = v),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Chief Complaint
                        const _Label('Chief Complaint *'),
                        TextFormField(
                          controller: _complaintCtrl,
                          enabled: !widget.isDemoMode,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Severe chest pain'),
                          validator: (v) =>
                              (v == null || v.trim().length < 3)
                                  ? 'Minimum 3 characters'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // Duration
                        const _Label('Duration (minutes) *'),
                        TextFormField(
                          controller: _durationCtrl,
                          enabled: !widget.isDemoMode,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(hintText: 'e.g. 30'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Duration is required';
                            }
                            final m = int.tryParse(v.trim());
                            if (m == null || m < 0) {
                              return 'Enter a valid duration';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Pain score
                        _Label('Pain Score *  ($_painScore/10)'),
                        AbsorbPointer(
                          absorbing: widget.isDemoMode,
                          child: Slider(
                            value: _painScore.toDouble(),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            label: _painScore.toString(),
                            onChanged: (v) =>
                                setState(() => _painScore = v.round()),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Symptoms
                        const _Label('Symptoms * (select at least one)'),
                        const SizedBox(height: 8),
                        AbsorbPointer(
                          absorbing: widget.isDemoMode,
                          child: SymptomChipSelector(
                            selected: _symptoms,
                            onChanged: (s) =>
                                setState(() => _symptoms = s),
                          ),
                        ),
                        if (_symptoms.isEmpty && !widget.isDemoMode)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text('At least one symptom required',
                                style: TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontSize: 12)),
                          ),
                        const SizedBox(height: 24),

                        // Vitals
                        AbsorbPointer(
                          absorbing: widget.isDemoMode,
                          child: VitalsInputCard(
                            onChanged: (v) => setState(() {
                              _vitals = Vitals(
                                heartRate: v['heart_rate'] as int?,
                                systolicBp: v['systolic_bp'] as int?,
                                diastolicBp: v['diastolic_bp'] as int?,
                                respiratoryRate:
                                    v['respiratory_rate'] as int?,
                                spo2: v['spo2'] as int?,
                                temperatureC: (v['temperature_c'] as num?)
                                    ?.toDouble(),
                                consciousness:
                                    v['consciousness'] as String?,
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nurse note
                        const _Label('Nurse Note (optional)'),
                        TextFormField(
                          controller: _nurseNoteCtrl,
                          enabled: !widget.isDemoMode,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              hintText: 'Additional observations…'),
                        ),
                        const SizedBox(height: 32),

                        // Submit button — hidden in demo mode
                        if (!widget.isDemoMode)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.send),
                              label: const Text('Evaluate Triage',
                                  style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryAction,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2B3C))),
    );
  }
}