import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/health_service.dart';
import '../services/notification_service.dart';
import 'live_screen.dart';
import 'history_screen.dart';
import 'map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    LiveScreen(),
    HistoryScreen(),
    MapScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ لما يحصل fall هيظهر الـ popup في أي screen
    NotificationService.onFallDetected = () {
      if (mounted) {
        _showFallDialog();
      }
    };
  }

  @override
  void dispose() {
    NotificationService.onFallDetected = null;
    super.dispose();
  }

  Future<void> _callEmergency() async {
    final uri = Uri(scheme: 'tel', path: '123');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showFallDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.red.shade50,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Text(
              '⚠️ Fall Detected!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'The patient may have fallen!\nPlease check immediately.',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Provider.of<HealthService>(context, listen: false)
                  .acknowledgeFall();
              Navigator.of(context).pop();
            },
            child: const Text('Acknowledge'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _callEmergency();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call 123'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A2E3F),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}