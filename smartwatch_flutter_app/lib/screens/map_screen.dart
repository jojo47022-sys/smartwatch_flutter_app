import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/health_service.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  Future<void> _callEmergency() async {
    final uri = Uri(scheme: 'tel', path: '123');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Location'),
        backgroundColor: const Color(0xFF1A2E3F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<HealthService>(context, listen: false).refreshData();
            },
          ),
        ],
      ),
      body: Consumer<HealthService>(
        builder: (context, healthService, child) {
          final lat = healthService.latitude;
          final lng = healthService.longitude;
          final hasLocation = lat != 0.0 && lng != 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map placeholder with real coordinates
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: hasLocation
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://static-maps.yandex.ru/1.x/?ll=$lng,$lat&z=15&l=map&size=600,300&pt=$lng,$lat,pm2rdm',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildMapFallback(lat, lng),
                          ),
                        )
                      : _buildNoLocation(),
                ),

                const SizedBox(height: 16),

                // Coordinates Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📍 GPS Coordinates',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            hasLocation
                                ? 'Lat: ${lat.toStringAsFixed(6)}'
                                : 'Latitude: --',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            hasLocation
                                ? 'Lng: ${lng.toStringAsFixed(6)}'
                                : 'Longitude: --',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Last Update: ${healthService.lastUpdated.isEmpty ? '--' : healthService.lastUpdated}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: hasLocation
                            ? () => _openInMaps(lat, lng)
                            : null,
                        icon: const Icon(Icons.map),
                        label: const Text('Open in Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A2E3F),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _callEmergency,
                        icon: const Icon(Icons.phone),
                        label: const Text('Call 123'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),

                // Fall Detected Banner
                if (healthService.isFallDetected) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red, size: 28),
                            SizedBox(width: 8),
                            Text(
                              '⚠️ Fall Detected!',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The patient may have fallen. Check immediately!',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _callEmergency,
                                icon: const Icon(Icons.phone),
                                label: const Text('Call 123'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    healthService.acknowledgeFall(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Acknowledge'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapFallback(double lat, double lng) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLocation() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, color: Colors.grey, size: 48),
          SizedBox(height: 8),
          Text('No location data yet',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}