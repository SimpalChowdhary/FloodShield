import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../database/database_helper.dart';

class ReportFloodScreen extends StatefulWidget {
  const ReportFloodScreen({super.key});

  @override
  State<ReportFloodScreen> createState() =>
      _ReportFloodScreenState();
}

class _ReportFloodScreenState
    extends State<ReportFloodScreen> {
  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final DatabaseHelper _databaseHelper =
      DatabaseHelper.instance;

  String? _selectedSeverity;

  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  double? _currentLatitude;
  double? _currentLongitude;

  final List<String> _severityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled.',
        );
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission denied.',
        );
      }

      if (permission ==
          LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied.',
        );
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

      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;

      final Geocoding geocoding = Geocoding();

      final List<Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = '';

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final List<String?> parts = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ];

        address = parts
            .where(
              (part) =>
                  part != null &&
                  part.trim().isNotEmpty,
            )
            .map((part) => part!.trim())
            .toSet()
            .join(', ');
      }

      if (!mounted) return;

      setState(() {
        _locationController.text = address.isEmpty
            ? '${position.latitude}, ${position.longitude}'
            : address;

        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to get location: $e',
          ),
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please get your current location.',
          ),
        ),
      );
      return;
    }

    if (_selectedSeverity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select the flood severity.',
          ),
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a description.',
          ),
        ),
      );
      return;
    }

    if (_currentLatitude == null ||
        _currentLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please get your current GPS location before submitting.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String reportId =
          DateTime.now().microsecondsSinceEpoch.toString();

      final Map<String, dynamic> incident = {
        'id': reportId,
        'user_id': 'local-user',
        'lat': _currentLatitude,
        'lng': _currentLongitude,
        'severity': _selectedSeverity,
        'description':
            _descriptionController.text.trim(),
        'photo': null,
        'timestamp':
            DateTime.now().toIso8601String(),
        'sync_status': 'Pending Sync',
        'zone_id': null,
      };

      await _databaseHelper.insertIncident(
        incident,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Flood report saved locally. Pending Sync.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save report: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Flood'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Report a Flood Incident',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Provide the details below to report a flood incident.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _locationController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Current Location',
                hintText:
                    'Tap the button to get your location',
                border: const OutlineInputBorder(),
                prefixIcon:
                    const Icon(Icons.location_on),
                suffixIcon: _isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        onPressed:
                            _getCurrentLocation,
                        icon: const Icon(
                          Icons.my_location,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _selectedSeverity,
              decoration: const InputDecoration(
                labelText: 'Flood Severity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.warning_amber_rounded,
                ),
              ),
              items: _severityLevels
                  .map(
                    (severity) =>
                        DropdownMenuItem<String>(
                      value: severity,
                      child: Text(severity),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeverity = value;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Describe the flood situation...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    _isSubmitting
                        ? null
                        : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting
                      ? 'Saving...'
                      : 'Submit Flood Report',
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange[200]!,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Reports are stored locally first and will be synced when the backend is available.',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}