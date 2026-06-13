import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/health_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  String _lastAlertKey = '';
  int _badgeCount = 0; // ✅ عداد الـ badge

  @override
  void initState() {
    super.initState();
    // ✅ لما الـ unreadCount يتغير، حدّث الـ badge
    NotificationService.onCountChanged = () {
      if (mounted) {
        setState(() {
          _badgeCount = NotificationService.unreadCount;
        });
      }
    };
  }

  @override
  void dispose() {
    NotificationService.onCountChanged = null;
    super.dispose();
  }

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.danger:
        return Colors.red;
      case HealthStatus.warning:
        return Colors.orange;
      case HealthStatus.normal:
        return Colors.green;
    }
  }

  String _getStatusText(HealthStatus status) {
    switch (status) {
      case HealthStatus.danger:
        return '🔴 Critical';
      case HealthStatus.warning:
        return '🟡 Warning';
      case HealthStatus.normal:
        return '🟢 Normal';
    }
  }

  void _checkAndShowAlerts(HealthService healthService) {
    final alerts = <String>[];

    if (healthService.isFallDetected) {
      alerts.add('⚠️ FALL DETECTED! Check immediately!');
    }

    final spo2Status = HealthService.getSpo2Status(healthService.spo2);
    if (spo2Status == HealthStatus.danger) {
      alerts.add('🔴 SpO2 Critical: ${healthService.spo2}%');
    } else if (spo2Status == HealthStatus.warning) {
      alerts.add('🟡 SpO2 Low: ${healthService.spo2}%');
    }

    final hrStatus = HealthService.getHeartRateStatus(healthService.heartRate);
    if (hrStatus == HealthStatus.danger) {
      alerts.add('🔴 Heart Rate Critical: ${healthService.heartRate} bpm');
    } else if (hrStatus == HealthStatus.warning) {
      alerts.add('🟡 Heart Rate Abnormal: ${healthService.heartRate} bpm');
    }

    final bpStatus = HealthService.getSystolicStatus(healthService.systolic);
    if (bpStatus == HealthStatus.danger) {
      alerts.add('🔴 BP Systolic Critical: ${healthService.systolic} mmHg');
    } else if (bpStatus == HealthStatus.warning) {
      alerts.add('🟡 BP Systolic Abnormal: ${healthService.systolic} mmHg');
    }

    final diaStatus = HealthService.getDiastolicStatus(healthService.diastolic);
    if (diaStatus == HealthStatus.danger) {
      alerts.add('🔴 BP Diastolic Critical: ${healthService.diastolic} mmHg');
    } else if (diaStatus == HealthStatus.warning) {
      alerts.add('🟡 BP Diastolic Abnormal: ${healthService.diastolic} mmHg');
    }

    if (alerts.isEmpty) {
      _lastAlertKey = '';
      return;
    }

    final alertKey = alerts.join('|');
    if (alertKey == _lastAlertKey) return;
    _lastAlertKey = alertKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Health Alert!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 12),
                ...alerts.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(a, style: const TextStyle(fontSize: 14)),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showNotifications(BuildContext context) {
    final healthService = Provider.of<HealthService>(context, listen: false);
    final hrStatus = HealthService.getHeartRateStatus(healthService.heartRate);
    final spo2Status = HealthService.getSpo2Status(healthService.spo2);
    final bpStatus = HealthService.getSystolicStatus(healthService.systolic);
    final diaStatus = HealthService.getDiastolicStatus(healthService.diastolic);

    // ✅ امسح الـ badge لما يفتح الـ dialog
    NotificationService.clearUnread();
    setState(() => _badgeCount = 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('❤️ Heart Rate: ${healthService.heartRate} bpm - ${_getStatusText(hrStatus)}'),
            const SizedBox(height: 8),
            Text('🫁 SpO2: ${healthService.spo2}% - ${_getStatusText(spo2Status)}'),
            const SizedBox(height: 8),
            Text('🩺 Systolic: ${healthService.systolic} mmHg - ${_getStatusText(bpStatus)}'),
            const SizedBox(height: 8),
            Text('🩺 Diastolic: ${healthService.diastolic} mmHg - ${_getStatusText(diaStatus)}'),
            if (healthService.isFallDetected) ...[
              const SizedBox(height: 8),
              const Text('⚠️ Fall Detected!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Health Watch'),
        backgroundColor: const Color(0xFF1A2E3F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // ✅ زر الجرس مع الـ badge
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showNotifications(context),
                ),
                if (_badgeCount > 0)
                  Positioned(
                    right: 4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        _badgeCount > 99 ? '99+' : '$_badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<HealthService>(context, listen: false).refreshData();
            },
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.logout),
            onSelected: (value) async {
              if (value == 'logout') {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<HealthService>(
        builder: (context, healthService, child) {
          _checkAndShowAlerts(healthService);

          final hrStatus = HealthService.getHeartRateStatus(healthService.heartRate);
          final spo2Status = HealthService.getSpo2Status(healthService.spo2);
          final bpStatus = HealthService.getSystolicStatus(healthService.systolic);
          final diaStatus = HealthService.getDiastolicStatus(healthService.diastolic);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Data',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2E3F)),
                ),
                const SizedBox(height: 16),

                // Heart Rate Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Heart Rate',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                            Text(_getStatusText(hrStatus),
                                style: TextStyle(fontSize: 12, color: _getStatusColor(hrStatus))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${healthService.heartRate}',
                                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: _getStatusColor(hrStatus))),
                            const SizedBox(width: 4),
                            const Text('bpm', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                        const Text('Normal: 60-100 bpm', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // SpO2 Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('SpO2 Level',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                            Text(_getStatusText(spo2Status),
                                style: TextStyle(fontSize: 12, color: _getStatusColor(spo2Status))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${healthService.spo2}',
                                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: _getStatusColor(spo2Status))),
                            const SizedBox(width: 4),
                            const Text('%', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                        const Text('Normal: 95-100%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Blood Pressure Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Blood Pressure',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                            Text(
                              _getStatusText(bpStatus.index >= diaStatus.index ? bpStatus : diaStatus),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(bpStatus.index >= diaStatus.index ? bpStatus : diaStatus),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Systolic', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text('${healthService.systolic}',
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _getStatusColor(bpStatus))),
                                  const Text('mmHg', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Diastolic', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text('${healthService.diastolic}',
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _getStatusColor(diaStatus))),
                                  const Text('mmHg', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Normal: 90-140 / 60-90 mmHg', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Fall Alert
                if (healthService.isFallDetected)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fall Detected!',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                              const Text('Check Immediately!',
                                  style: TextStyle(fontSize: 14, color: Colors.red)),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: healthService.acknowledgeFall,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: const Text('Acknowledge'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Location Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Lat: ${healthService.latitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Lng: ${healthService.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Last update: ${healthService.lastUpdated}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}