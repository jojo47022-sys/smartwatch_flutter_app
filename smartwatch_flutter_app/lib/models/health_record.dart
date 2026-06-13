class HealthRecord {
  final String date;
  final int heartRate;
  final int spo2;
  final int systolic;
  final int diastolic;
  final bool fallDetected;
  final String location;

  HealthRecord({
    required this.date,
    required this.heartRate,
    required this.spo2,
    required this.systolic,
    required this.diastolic,
    required this.fallDetected,
    required this.location,
  });
}
