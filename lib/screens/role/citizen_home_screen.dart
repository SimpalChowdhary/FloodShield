
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Home'),
        backgroundColor: Colors.blue,
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Report emergencies and find nearby support.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            _buildActionCard(
              context,
              icon: Icons.flood,
              title: 'Report Flood',
              subtitle: 'Report a flood incident with your location.',
              color: Colors.red,
              route: AppRoutes.reportFlood,
            ),

            _buildActionCard(
              context,
              icon: Icons.map,
              title: 'Flood Map',
              subtitle: 'View reported flood incidents on the map.',
              color: Colors.blue,
              route: AppRoutes.map,
            ),

            _buildActionCard(
              context,
              icon: Icons.home_work,
              title: 'Find Shelters',
              subtitle: 'View available emergency shelters.',
              color: Colors.green,
              route: AppRoutes.shelters,
            ),

            _buildActionCard(
              context,
              icon: Icons.history,
              title: 'My Reports',
              subtitle: 'View your submitted flood reports.',
              color: Colors.orange,
              route: AppRoutes.reportHistory,
            ),

            const SizedBox(height: 12),
            const Center(
              child: Text(
                'FloodShield • Stay safe',
                style: TextStyle(color: Colors.blueGrey),
              ),
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
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}