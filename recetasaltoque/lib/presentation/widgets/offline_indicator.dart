import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    setState(() {
      _isOffline = result == ConnectivityResult.none;
    });

    connectivity.onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOffline = result == ConnectivityResult.none;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade700,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Sin conexion - Mostrando datos cacheados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
