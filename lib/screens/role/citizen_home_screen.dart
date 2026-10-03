import 'package:flutter/material.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Home'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Citizen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Report emergencies and find nearby support.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            _buildActionCard(
              context,
              icon: Icons.flood,
              title: 'Report Flood',
              subtitle: 'Report a flood incident with your location.',
              color: Colors.red,
            ),

            _buildActionCard(
              context,
              icon: Icons.map,
              title: 'Flood Map',
              subtitle: 'View reported flood incidents on the map.',
              color: Colors.blue,
            ),

            _buildActionCard(
              context,
              icon: Icons.home_work,
              title: 'Find Shelters',
              subtitle: 'View available emergency shelters.',
              color: Colors.green,
            ),

            _buildActionCard(
              context,
              icon: Icons.history,
              title: 'My Reports',
              subtitle: 'View your submitted flood reports.',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}