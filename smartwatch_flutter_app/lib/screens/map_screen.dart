import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/health_service.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

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
          return Column(
            children: [
              // Map placeholder with location marker
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Grid pattern for map look
                    CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: GridPainter(),
                    ),
                    // Location marker
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.watch,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Smart Watch',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Location details panel
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last known location: Cairo, Egypt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Coordinates
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildLocationRow(
                            Icons.pin_drop,
                            'Latitude: ${healthService.latitude.toStringAsFixed(6)}',
                          ),
                          const Divider(),
                          _buildLocationRow(
                            Icons.pin_drop,
                            'Longitude: ${healthService.longitude.toStringAsFixed(6)}',
                          ),
                          const Divider(),
                          _buildLocationRow(
                            Icons.access_time,
                            'Last Update: ${healthService.lastUpdated}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nearby places
                    const Text(
                      'Nearby Places',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildPlaceTile(
                        'Tahrir Square', '0.5 km away', Icons.location_on),
                    _buildPlaceTile(
                        'Egyptian Museum', '1.2 km away', Icons.museum),
                    _buildPlaceTile(
                        'Cairo Tower', '2.5 km away', Icons.location_city),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Route calculation started...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Show Route'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A2E3F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Device located at: ${healthService.latitude.toStringAsFixed(4)}, ${healthService.longitude.toStringAsFixed(4)}',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.location_searching),
                            label: const Text('Locate Device'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(String name, String distance, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(name),
      subtitle: Text(distance),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
    );
  }
}

// Custom painter for grid background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
