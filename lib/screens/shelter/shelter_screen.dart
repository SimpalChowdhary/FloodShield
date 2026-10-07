import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShelterScreen extends StatefulWidget {
  const ShelterScreen({super.key});

  @override
  State<ShelterScreen> createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  List<dynamic> shelters = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = 'http://10.89.121.138:8081';

  @override
  void initState() {
    super.initState();
    _loadShelters();
  }

  Future<void> _loadShelters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('SHELTER TOKEN PRESENT: ${token != null}');

      final response = await http.get(
        Uri.parse('$baseUrl/api/shelters'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('SHELTER STATUS: ${response.statusCode}');
      print('SHELTER RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          shelters = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load shelters (${response.statusCode})';
        });
      }
    } catch (e) {
      print('SHELTER ERROR: $e');

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to connect to server';
      });
    }
  }

  Color _getStatusColor(int capacity, int occupancy) {
    if (occupancy >= capacity) {
      return Colors.red;
    }

    if (occupancy >= capacity * 0.8) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _getStatus(int capacity, int occupancy) {
    if (occupancy >= capacity) {
      return 'Full';
    }

    if (occupancy >= capacity * 0.8) {
      return 'Limited';
    }

    return 'Available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        title: const Text(
          'Shelters',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadShelters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadShelters,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : shelters.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadShelters,
                      child: ListView(
                        children: const [
                          SizedBox(height: 220),
                          Center(
                            child: Text(
                              'No shelters available',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadShelters,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: shelters.length,
                        itemBuilder: (context, index) {
                          final shelter = shelters[index];

                          final String name =
                              shelter['name']?.toString() ?? 'Unknown Shelter';

                          final String location =
                              shelter['location']?.toString() ?? 'Unknown';

                          final int capacity =
                              (shelter['capacity'] as num?)?.toInt() ?? 0;

                          final int occupancy =
                              (shelter['occupancy'] as num?)?.toInt() ?? 0;
                          
                          final double latitude =
    (shelter['latitude'] as num?)?.toDouble() ?? 0.0;

final double longitude =
    (shelter['longitude'] as num?)?.toDouble() ?? 0.0;

                          final String status =
                              _getStatus(capacity, occupancy);

                          final Color statusColor =
                              _getStatusColor(capacity, occupancy);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.home_work_outlined,
                                          color: Colors.blue[700],
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Occupancy: $occupancy / $capacity',
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
  Navigator.pushNamed(
    context,
    '/map',
    arguments: {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    },
  );
},
                                        icon: const Icon(
                                          Icons.directions,
                                        ),
                                        label: const Text('Directions'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}