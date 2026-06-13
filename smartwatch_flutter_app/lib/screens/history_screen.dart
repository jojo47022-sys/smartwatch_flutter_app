import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/health_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // ✅ يتحقق إن القراءة منطقية فسيولوجيًا
  bool _isReadingValid({
    required int heartRate,
    required int spo2,
    required int systolic,
    required int diastolic,
  }) {
    if (heartRate < 30 || heartRate > 220) return false;
    if (spo2 < 50 || spo2 > 100) return false;
    if (systolic < 60 || systolic > 250) return false;
    if (diastolic < 30 || diastolic > 150) return false;
    if (systolic <= diastolic) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health History'),
        backgroundColor: const Color(0xFF1A2E3F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<HealthService>(
        builder: (context, healthService, child) {
          final history = healthService.history;

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No history yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index];
              final timeStr = DateFormat('M/d/yyyy h:mm a').format(record.timestamp);

              final isValid = _isReadingValid(
                heartRate: record.heartRate,
                spo2: record.spo2,
                systolic: record.systolic,
                diastolic: record.diastolic,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (!isValid) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'Warning',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (record.fallDetected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red, size: 14),
                                  SizedBox(width: 4),
                                  Text('Fall', style: TextStyle(color: Colors.red, fontSize: 12)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricColumn('Heart Rate', '${record.heartRate}', 'bpm', Colors.red),
                          _buildMetricColumn('SpO2', '${record.spo2}', '%', Colors.blue),
                          _buildMetricColumn('BP', '${record.systolic}/${record.diastolic}', 'mmHg', Colors.purple),
                        ],
                      ),

                      if (record.fallDetected) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Fall Detected! Check Immediately!',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}