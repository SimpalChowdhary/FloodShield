import 'package:flutter/material.dart';

class AuthorityHomeScreen extends StatelessWidget {
  const AuthorityHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authority Home'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authority Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor incidents and coordinate emergency response.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Incidents',
                    '0',
                    Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Pending',
                    '0',
                    Icons.pending_actions,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildActionCard(
              icon: Icons.map,
              title: 'Incident Map',
              subtitle: 'View reported flood incidents and locations.',
            ),

            _buildActionCard(
              icon: Icons.groups,
              title: 'Rescue Teams',
              subtitle: 'Monitor and coordinate field teams.',
            ),

            _buildActionCard(
              icon: Icons.inventory_2,
              title: 'Resources',
              subtitle: 'Manage emergency supplies and resources.',
            ),

            _buildActionCard(
              icon: Icons.home_work,
              title: 'Shelters',
              subtitle: 'Monitor shelter capacity and availability.',
            ),

            _buildActionCard(
              icon: Icons.timeline,
              title: 'Incident Timeline',
              subtitle: 'Track emergency activities and updates.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(
            icon,
            color: Colors.blue[700],
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