import 'package:flutter/material.dart';

class FieldTeamHomeScreen extends StatelessWidget {
  const FieldTeamHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Team Home'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Field Team Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View assigned tasks and update rescue operations.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.orange[50],
                      child: Icon(
                        Icons.assignment,
                        size: 30,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned Tasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0 active tasks',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: Colors.blue[700],
                  ),
                ),
                title: const Text(
                  'My Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'View your assigned rescue tasks.',
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: Colors.green[50],
                  child: Icon(
                    Icons.update,
                    color: Colors.green[700],
                  ),
                ),
                title: const Text(
                  'Update Task Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Update the progress of your rescue task.',
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: Colors.red[50],
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red[700],
                  ),
                ),
                title: const Text(
                  'Emergency Locations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'View locations requiring assistance.',
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}