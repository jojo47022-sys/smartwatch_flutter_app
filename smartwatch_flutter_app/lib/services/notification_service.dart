import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ✅ عداد الـ alerts الغير مقروءة
  static int _unreadCount = 0;
  static int get unreadCount => _unreadCount;

  // ✅ callback لما العداد يتغير — بيخلي الـ UI يتحدث
  static void Function()? onCountChanged;

  static void clearUnread() {
    _unreadCount = 0;
    onCountChanged?.call();
  }

  static void _incrementUnread() {
    _unreadCount++;
    onCountChanged?.call();
  }

  static Future<void> initialize() async {
    await Permission.notification.request();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      debugPrint('Notification permission not granted');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'health_alerts_channel',
      'Health Alerts',
      channelDescription: 'Channel for Health Alert Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    // ✅ زود العداد بعد كل notification
    _incrementUnread();
  }

  static Future<void> showFallAlertNotification() async {
    await showNotification(
      id: 1,
      title: '⚠️ FALL DETECTED!',
      body: 'Emergency! User may have fallen. Check immediately.',
      payload: 'fall_alert',
    );
  }

  static Future<void> checkAndNotify({
    required int heartRate,
    required int spo2,
    required int systolic,
    required int diastolic,
    required bool fallDetected,
  }) async {
    if (fallDetected) {
      await showFallAlertNotification();
    }

    // Heart Rate
    if (heartRate > 0) {
      if (heartRate < 50 || heartRate > 120) {
        await showNotification(
          id: 2,
          title: '🔴 DANGER: Heart Rate Critical',
          body: 'Heart rate is $heartRate bpm! Normal: 60-100 bpm.',
          payload: 'heart_rate_danger',
        );
      } else if (heartRate < 60 || heartRate > 100) {
        await showNotification(
          id: 2,
          title: '🟡 WARNING: Heart Rate Abnormal',
          body: 'Heart rate is $heartRate bpm. Normal: 60-100 bpm.',
          payload: 'heart_rate_warning',
        );
      }
    }

    // SpO2
    if (spo2 > 0 && spo2 <= 100) {
      if (spo2 < 90) {
        await showNotification(
          id: 3,
          title: '🔴 DANGER: SpO2 Critical',
          body: 'SpO2 is $spo2%! Immediate attention needed. Normal: 95-100%.',
          payload: 'spo2_danger',
        );
      } else if (spo2 < 95) {
        await showNotification(
          id: 3,
          title: '🟡 WARNING: Low SpO2',
          body: 'SpO2 is $spo2%. Normal: 95-100%.',
          payload: 'spo2_warning',
        );
      }
    } else if (spo2 > 100) {
      // ✅ sensor error
      await showNotification(
        id: 3,
        title: '🔴 DANGER: SpO2 Sensor Error',
        body: 'SpO2 reading ($spo2%) is invalid. Check sensor placement.',
        payload: 'spo2_error',
      );
    }

    // Blood Pressure - Systolic
    if (systolic > 0) {
      if (systolic > 160 || systolic < 80) {
        await showNotification(
          id: 4,
          title: '🔴 DANGER: Blood Pressure Critical',
          body: 'BP is $systolic/$diastolic mmHg! Normal: 90-140/60-90.',
          payload: 'bp_danger',
        );
      } else if (systolic > 140 || systolic < 90) {
        await showNotification(
          id: 4,
          title: '🟡 WARNING: Blood Pressure Abnormal',
          body: 'BP is $systolic/$diastolic mmHg. Normal: 90-140/60-90.',
          payload: 'bp_warning',
        );
      }
    }

    // ✅ Diastolic - كان مش موجود
    if (diastolic > 0) {
      if (diastolic > 100 || diastolic < 50) {
        await showNotification(
          id: 5,
          title: '🔴 DANGER: Diastolic BP Critical',
          body: 'Diastolic BP is $diastolic mmHg! Normal: 60-90 mmHg.',
          payload: 'diastolic_danger',
        );
      } else if (diastolic > 90 || diastolic < 60) {
        await showNotification(
          id: 5,
          title: '🟡 WARNING: Diastolic BP Abnormal',
          body: 'Diastolic BP is $diastolic mmHg. Normal: 60-90 mmHg.',
          payload: 'diastolic_warning',
        );
      }
    }
  }
}