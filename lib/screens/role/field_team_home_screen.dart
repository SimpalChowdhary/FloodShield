
import 'package:flutter/material.dart';

class FieldTeamHomeScreen extends StatefulWidget {
  const FieldTeamHomeScreen({super.key});

  @override
  State<FieldTeamHomeScreen> createState() =>
      _FieldTeamHomeScreenState();
}

class _FieldTeamHomeScreenState extends State<FieldTeamHomeScreen> {
  static const Color navy = Color(0xFF102A43);
  static const Color blue = Color(0xFF1769AA);
  static const Color background = Color(0xFFF3F6FB);
  static const Color muted = Color(0xFF64748B);

  String taskStatus = 'Assigned';

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus() {
    const statuses = [
      'Assigned',
      'Accepted',
      'In Progress',
      'Completed',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Task Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a status for the sample task.',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...statuses.map(
                (status) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    status == taskStatus
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: status == taskStatus ? blue : muted,
                  ),
                  title: Text(status),
                  onTap: () {
                    setState(() => taskStatus = status);
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sample task status: $status'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This change is local to this screen and is not '
                'saved to the backend.',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.water_drop_rounded, size: 26),
            SizedBox(width: 10),
            Text(
              'FloodShield',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Team information',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showMessage(
              'Field Team',
              'Use this dashboard to review rescue tasks, '
              'check incident locations, and track operation progress.',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Field Team Dashboard',
                style: TextStyle(
                  color: navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Your mission overview and rescue operations.',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildBanner(),
              const SizedBox(height: 25),
              _buildHeading('Team Overview', 'Task indicators'),
              const SizedBox(height: 13),
              _buildOverview(),
              const SizedBox(height: 26),
              _buildHeading('My Operations', 'Manage field activities'),
              const SizedBox(height: 13),
              _buildSampleTask(),
              const SizedBox(height: 14),
              _buildActionTile(
                icon: Icons.assignment_rounded,
                color: const Color(0xFF1769AA),
                title: 'My Tasks',
                subtitle: 'Review assigned rescue tasks',
                onTap: () => _showMessage(
                  'My Tasks',
                  'No real task assignments have been loaded. '
                  'Connect the verified field-team assignment '
                  'endpoint to display actual tasks.',
                ),
              ),
              _buildActionTile(
                icon: Icons.update_rounded,
                color: const Color(0xFF059669),
                title: 'Update Task Status',
                subtitle: 'Change the sample task progress',
                onTap: _updateTaskStatus,
              ),
              _buildActionTile(
                icon: Icons.location_on_rounded,
                color: const Color(0xFFDC2626),
                title: 'Emergency Locations',
                subtitle: 'View locations requiring assistance',
                onTap: () => _showMessage(
                  'Emergency Locations',
                  'Incident coordinates and location details '
                  'will appear here after the incident map '
                  'and backend integration are verified.',
                ),
              ),
              _buildActionTile(
                icon: Icons.home_work_rounded,
                color: const Color(0xFF7C3AED),
                title: 'Shelter Information',
                subtitle: 'Review shelter availability',
                onTap: () => _showMessage(
                  'Shelter Information',
                  'Shelter information is not loaded on this '
                  'screen yet. The existing shelter screen '
                  'can be connected after its route is verified.',
                ),
              ),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF1769AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.14),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'FIELD OPERATIONS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Every Response Matters.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay prepared, track assignments, and coordinate '
            'flood rescue operations safely.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.assignment_turned_in_rounded,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sample task status:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    taskStatus,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOverview() {
    final items = [
      _TeamMetric(
        title: 'Assigned',
        value: '0',
        icon: Icons.assignment_outlined,
        color: const Color(0xFF1769AA),
      ),
      _TeamMetric(
        title: 'In Progress',
        value: '0',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFD97706),
      ),
      _TeamMetric(
        title: 'Completed',
        value: '0',
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF059669),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 125,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: const Color(0xFFE5EAF1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item.icon, color: item.color, size: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.value,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSampleTask() {
    final color = _statusColor(taskStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Sample Rescue Task',
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  taskStatus,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: muted,
                size: 18,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Incident location not assigned',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5EAF1)),
          const SizedBox(height: 5),
          const Text(
            'Demonstration only. No real rescue assignment '
            'has been received from the backend.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _updateTaskStatus,
              icon: const Icon(Icons.edit_rounded, size: 17),
              label: const Text('Change Sample Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                side: const BorderSide(color: blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return const Color(0xFF1769AA);
      case 'In Progress':
        return const Color(0xFFD97706);
      case 'Completed':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 9,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: muted,
          size: 15,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEF7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: navy,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Task counts and the sample task are demonstration '
              'data. Real assignments and status updates require '
              'verified backend integration.',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMetric {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TeamMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}