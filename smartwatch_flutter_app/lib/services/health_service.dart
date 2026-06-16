import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

enum HealthStatus { normal, warning, danger }

class HealthRecord {
  final int heartRate;
  final int spo2;
  final int systolic;
  final int diastolic;
  final bool fallDetected;
  final DateTime timestamp;

  HealthRecord({
    required this.heartRate,
    required this.spo2,
    required this.systolic,
    required this.diastolic,
    required this.fallDetected,
    required this.timestamp,
  });
}

class HealthService extends ChangeNotifier {
  final DatabaseReference _ref = FirebaseDatabase.instance
      .ref('users/${FirebaseAuth.instance.currentUser!.uid}');

  int _heartRate = 0;
  int _spo2 = 0;
  int _systolic = 0;
  int _diastolic = 0;
  bool _isFallDetected = false;
  int _batteryLevel = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _lastUpdated = '';
  final List<HealthRecord> _history = [];

  int get heartRate => _heartRate;
  int get spo2 => _spo2;
  int get systolic => _systolic;
  int get diastolic => _diastolic;
  bool get isFallDetected => _isFallDetected;
  int get batteryLevel => _batteryLevel;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get lastUpdated => _lastUpdated;
  List<HealthRecord> get history => _history;

  static HealthStatus getHeartRateStatus(int value) {
    if (value <= 0) return HealthStatus.normal;
    if (value < 50 || value > 120) return HealthStatus.danger;
    if (value < 60 || value > 100) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  static HealthStatus getSpo2Status(int value) {
    if (value <= 0 || value > 100) return HealthStatus.danger;
    if (value < 90) return HealthStatus.danger;
    if (value < 95) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  static HealthStatus getSystolicStatus(int value) {
    if (value <= 0) return HealthStatus.normal;
    if (value > 160 || value < 80) return HealthStatus.danger;
    if (value > 140 || value < 90) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  static HealthStatus getDiastolicStatus(int value) {
    if (value <= 0) return HealthStatus.normal;
    if (value > 100 || value < 50) return HealthStatus.danger;
    if (value > 90 || value < 60) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  HealthService() {
    _listenToFirebase();
  }

  void _updateTimestamp() {
    _lastUpdated = DateFormat('M/d/yyyy h:mm a').format(DateTime.now());
  }

  void _listenToFirebase() {
    _ref.onValue.listen((event) {
      try {
        final raw = event.snapshot.value;
        if (raw == null) return;

        final data = Map<String, dynamic>.from(raw as Map);

        _heartRate = int.tryParse(data['heartRate']?.toString() ?? '0') ?? 0;
        _spo2 = int.tryParse(
                data['spo2']?.toString().replaceAll('%', '') ?? '0') ?? 0;

        // ✅ Blood Pressure من nested object
        final bp = data['bloodPressure'] != null
            ? Map<String, dynamic>.from(data['bloodPressure'] as Map)
            : null;
        _systolic = int.tryParse(bp?['systolic']?.toString() ?? '0') ?? 0;
        _diastolic = int.tryParse(bp?['diastolic']?.toString() ?? '0') ?? 0;

        _batteryLevel = int.tryParse(data['battery']?.toString() ?? '0') ?? 0;

        // ✅ Location من nested object
        final location = data['location'] != null
            ? Map<String, dynamic>.from(data['location'] as Map)
            : null;
        _latitude = double.tryParse(
                location?['latitude']?.toString() ?? '0') ?? 0.0;
        _longitude = double.tryParse(
                location?['longitude']?.toString() ?? '0') ?? 0.0;

        // ✅ Fall Detection - بس لو اتغير من false لـ true
        final newFall = data['fallDetected'] == true;
        if (newFall && !_isFallDetected) {
          _isFallDetected = newFall;
          NotificationService.checkAndNotify(
            heartRate: _heartRate,
            spo2: _spo2,
            systolic: _systolic,
            diastolic: _diastolic,
            fallDetected: true,
          );
        } else {
          _isFallDetected = newFall;
        }

        _updateTimestamp();

        if (_heartRate > 0) {
          _history.insert(
              0,
              HealthRecord(
                heartRate: _heartRate,
                spo2: _spo2,
                systolic: _systolic,
                diastolic: _diastolic,
                fallDetected: _isFallDetected,
                timestamp: DateTime.now(),
              ));
          if (_history.length > 5) {
            _history.removeRange(5, _history.length);
          }
        }

        notifyListeners();

        // ✅ Health notifications بدون الـ fall
        NotificationService.checkAndNotify(
          heartRate: _heartRate,
          spo2: _spo2,
          systolic: _systolic,
          diastolic: _diastolic,
          fallDetected: false,
        );
      } catch (e) {
        debugPrint('Firebase error: $e');
      }
    });
  }

  void acknowledgeFall() {
    _ref.update({"fallDetected": false});
    _isFallDetected = false;
    notifyListeners();
  }

  void refreshData() {
    _listenToFirebase();
  }
}