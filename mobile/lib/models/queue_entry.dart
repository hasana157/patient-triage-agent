class QueueEntry {
  final String caseId;
  final String patientCode;
  final String arrivalTime;
  final int currentWaitMinutes;
  final int currentQueuePosition;
  final String currentPriority;
  final String chiefComplaint;

  const QueueEntry({
    required this.caseId,
    required this.patientCode,
    required this.arrivalTime,
    required this.currentWaitMinutes,
    required this.currentQueuePosition,
    required this.currentPriority,
    required this.chiefComplaint,
  });
}
