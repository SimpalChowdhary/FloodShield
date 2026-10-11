import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../database/database_helper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final DatabaseHelper _databaseHelper =
      DatabaseHelper.instance;

  LatLng? _currentLocation;
  List<Map<String, dynamic>> _reports = [];

  bool _isLoading = true;

  // Default location: Telangana/Hyderabad region.
  static const LatLng _defaultLocation =
      LatLng(17.3850, 78.4867);

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await _getCurrentLocation();
    await _loadReports();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        return;
      }

      final LocationSettings locationSettings =
          AndroidSettings(
        accuracy:
            LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        forceLocationManager: false,
      );

      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(
            position.latitude,
            position.longitude,
          );
        });
      }
    } catch (_) {
      // Map will use the default location if GPS is unavailable.
    }
  }

  Future<void> _loadReports() async {
    try {
      final List<Map<String, dynamic>> loadedReports =
          await _databaseHelper.getIncidents();

      if (mounted) {
        setState(() {
          _reports = loadedReports;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load flood reports: $e',
          ),
        ),
      );
    }
  }

  LatLng _getMapCenter() {
    if (_currentLocation != null) {
      return _currentLocation!;
    }

    if (_reports.isNotEmpty) {
      final double? latitude =
          (_reports.first['lat'] as num?)?.toDouble();

      final double? longitude =
          (_reports.first['lng'] as num?)?.toDouble();

      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }

    return _defaultLocation;
  }

  List<Marker> _buildReportMarkers() {
    final List<Marker> markers = [];

    for (final Map<String, dynamic> report
        in _reports) {
      final double? latitude =
          (report['lat'] as num?)?.toDouble();

      final double? longitude =
          (report['lng'] as num?)?.toDouble();

      if (latitude == null || longitude == null) {
        continue;
      }

      final String severity =
          report['severity']?.toString() ?? 'Unknown';

      final String description =
          report['description']?.toString() ?? '';

      final String location =
          report['location']?.toString() ??
              'Lat: $latitude, Lng: $longitude';

      markers.add(
        Marker(
          point: LatLng(
            latitude,
            longitude,
          ),
          width: 55,
          height: 65,
          child: GestureDetector(
            onTap: () {
              _showReportDetails(
                location: location,
                severity: severity,
                description: description,
              );
            },
            child: Icon(
              Icons.location_on,
              size: 48,
              color: _severityColor(severity),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  void _showReportDetails({
    required String location,
    required String severity,
    required String description,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flood Incident',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Severity: $severity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _moveToCurrentLocation() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Current location is not available.',
          ),
        ),
      );
      return;
    }

    _mapController.move(
      _currentLocation!,
      15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _getMapCenter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Map'),
        actions: [
          IconButton(
            onPressed: _loadMapData,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 10,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.floodshield_test',
                    ),

                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 55,
                            height: 55,
                            child: const Icon(
                              Icons.my_location,
                              size: 36,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: _buildReportMarkers(),
                    ),
                  ],
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flood,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_reports.length} flood report'
                              '${_reports.length == 1 ? '' : 's'} found',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 16,
                  bottom: 24,
                  child: FloatingActionButton(
                    onPressed:
                        _moveToCurrentLocation,
                    tooltip: 'My location',
                    child: const Icon(
                      Icons.my_location,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}