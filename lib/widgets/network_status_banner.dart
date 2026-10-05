import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkStatusBanner extends StatefulWidget {
  const NetworkStatusBanner({super.key});

  @override
  State<NetworkStatusBanner> createState() =>
      _NetworkStatusBannerState();
}

class _NetworkStatusBannerState
    extends State<NetworkStatusBanner> {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkInitialConnection() async {
    final List<ConnectivityResult> result =
        await _connectivity.checkConnectivity();

    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(
    List<ConnectivityResult> result,
  ) {
    final bool hasConnection = result.any(
      (item) => item != ConnectivityResult.none,
    );

    if (!mounted) return;

    setState(() {
      _isOffline = !hasConnection;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.orange[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.orange[800],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offline Mode',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Reports will be saved locally and synced later.',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_done,
            color: Colors.green[700],
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Network connection is available.',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}