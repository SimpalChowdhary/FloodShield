import 'package:flutter/material.dart';

class ShelterScreen extends StatelessWidget {
  const ShelterScreen({super.key});

  final List<Map<String, String>> shelters = const [
    {
      'name': 'Government High School',
      'location': 'Hyderabad',
      'capacity': '200 people',
      'status': 'Available',
    },
    {
      'name': 'Community Hall',
      'location': 'Secunderabad',
      'capacity': '150 people',
      'status': 'Available',
    },
    {
      'name': 'Municipal Relief Center',
      'location': 'Warangal',
      'capacity': '300 people',
      'status': 'Limited',
    },
  ];

  Color _getStatusColor(String status) {
    if (status == 'Available') {
      return Colors.green;
    }

    if (status == 'Limited') {
      return Colors.orange;
    }

    return Colors.red;
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shelters.length,
        itemBuilder: (context, index) {
          final shelter = shelters[index];

          final String name = shelter['name']!;
          final String location = shelter['location']!;
          final String capacity = shelter['capacity']!;
          final String status = shelter['status']!;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
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
                        'Capacity: $capacity',
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status)
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Opening route to $name',
                              ),
                            ),
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
    );
  }
}