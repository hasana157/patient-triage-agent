/// Dart data models mirroring backend Pydantic models.
/// These use the same field names as the API contract.

class Vitals {
  final int? heartRate;
  final int? systolicBp;
  final int? diastolicBp;
  final int? respiratoryRate;
  final int? spo2;
  final double? temperatureC;
  final String? consciousness;
  final String? recordedAt;

  const Vitals({
    this.heartRate,
    this.systolicBp,
    this.diastolicBp,
    this.respiratoryRate,
    this.spo2,
    this.temperatureC,
    this.consciousness,
    this.recordedAt,
  });

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      heartRate: json['heart_rate'] as int?,
      systolicBp: json['systolic_bp'] as int?,
      diastolicBp: json['diastolic_bp'] as int?,
      respiratoryRate: json['respiratory_rate'] as int?,
      spo2: json['spo2'] as int?,
      temperatureC: (json['temperature_c'] as num?)?.toDouble(),
      consciousness: json['consciousness'] as String?,
      recordedAt: json['recorded_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'heart_rate': heartRate,
        'systolic_bp': systolicBp,
        'diastolic_bp': diastolicBp,
        'respiratory_rate': respiratoryRate,
        'spo2': spo2,
        'temperature_c': temperatureC,
        'consciousness': consciousness,
        'recorded_at': recordedAt,
      };

  /// Returns a list of field names that are null (missing).
  List<String> get missingFields {
    final missing = <String>[];
    if (heartRate == null) missing.add('heart_rate');
    if (systolicBp == null) missing.add('systolic_bp');
    if (diastolicBp == null) missing.add('diastolic_bp');
    if (respiratoryRate == null) missing.add('respiratory_rate');
    if (spo2 == null) missing.add('spo2');
    if (temperatureC == null) missing.add('temperature_c');
    if (consciousness == null) missing.add('consciousness');
    return missing;
  }
}

class PatientCase {
  final String caseId;
  final String patientCode;
  final int age;
  final String sex;
  final bool? pregnant;
  final String chiefComplaint;
  final List<String> symptoms;
  final int? durationMinutes;
  final int? painScore;
  final Vitals? vitals;
  final List<Vitals> vitalsHistory;
  final String nurseNote;
  final String? arrivalTime;
  final int currentWaitMinutes;
  final String source;

  const PatientCase({
    required this.caseId,
    required this.patientCode,
    required this.age,
    this.sex = 'unknown',
    this.pregnant,
    required this.chiefComplaint,
    this.symptoms = const [],
    this.durationMinutes,
    this.painScore,
    this.vitals,
    this.vitalsHistory = const [],
    this.nurseNote = '',
    this.arrivalTime,
    this.currentWaitMinutes = 0,
    this.source = 'synthetic_demo',
  });

  factory PatientCase.fromJson(Map<String, dynamic> json) {
    return PatientCase(
      caseId: json['case_id'] as String,
      patientCode: json['patient_code'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String? ?? 'unknown',
      pregnant: json['pregnant'] as bool?,
      chiefComplaint: json['chief_complaint'] as String,
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      durationMinutes: json['duration_minutes'] as int?,
      painScore: json['pain_score'] as int?,
      vitals: json['vitals'] != null
          ? Vitals.fromJson(json['vitals'] as Map<String, dynamic>)
          : null,
      vitalsHistory: (json['vitals_history'] as List<dynamic>?)
              ?.map((e) => Vitals.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nurseNote: json['nurse_note'] as String? ?? '',
      arrivalTime: json['arrival_time'] as String?,
      currentWaitMinutes: json['current_wait_minutes'] as int? ?? 0,
      source: json['source'] as String? ?? 'synthetic_demo',
    );
  }
}
