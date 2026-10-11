import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AuthorityHomeScreen extends StatelessWidget {
  const AuthorityHomeScreen({super.key});

  static const Color navy = Color(0xFF102A43);
  static const Color blue = Color(0xFF1769AA);
  static const Color background = Color(0xFFF3F6FB);
  static const Color muted = Color(0xFF64748B);

  void _openScreen(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void _showFeatureMessage(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
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
            Icon(Icons.water_drop_rounded, size: 27),
            SizedBox(width: 10),
            Text(
              'FloodShield',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Dashboard information',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showFeatureMessage(
              context,
              'Authority Control Center',
              'Use this dashboard to review flood reports, '
                  'view locations, manage shelters and resources, '
                  'and coordinate field teams.',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Authority Dashboard',
                style: TextStyle(
                  color: navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Monitor incidents and coordinate emergency response.',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              _buildControlBanner(context),
              const SizedBox(height: 28),
              _buildSectionHeading(
                'Quick Actions',
                'Access the main response tools',
              ),
              const SizedBox(height: 14),
              _buildQuickActions(context),
              const SizedBox(height: 28),
              _buildSectionHeading(
                'Operations Center',
                'Manage emergency response activities',
              ),
              const SizedBox(height: 14),
              _buildOperationsGrid(context),
              const SizedBox(height: 24),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 7),
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'RESPONSE CONTROL CENTER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Stay Alert. Respond Faster.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review citizen reports, inspect flood locations, '
            'and coordinate response activities.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _openScreen(context, AppRoutes.map),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 19),
              label: const Text(
                'Open Flood Map',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
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

  Widget _buildQuickActions(BuildContext context) {
    final items = [
      _DashboardItem(
        title: 'Incident Reports',
        subtitle: 'Review submitted reports',
        icon: Icons.assignment_outlined,
        color: const Color(0xFF1769AA),
        onTap: () => _openScreen(
          context,
          AppRoutes.reportHistory,
        ),
      ),
      _DashboardItem(
        title: 'Flood Map',
        subtitle: 'View mapped locations',
        icon: Icons.map_outlined,
        color: const Color(0xFF0F766E),
        onTap: () => _openScreen(context, AppRoutes.map),
      ),
      _DashboardItem(
        title: 'Shelters',
        subtitle: 'View shelter information',
        icon: Icons.home_work_outlined,
        color: const Color(0xFF059669),
        onTap: () => _openScreen(context, AppRoutes.shelters),
      ),
      _DashboardItem(
        title: 'Resources',
        subtitle: 'View available resources',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFFD97706),
        onTap: () => _openScreen(context, AppRoutes.resources),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 130,
          ),
          itemBuilder: (context, index) {
            return _buildActionCard(items[index]);
          },
        );
      },
    );
  }

  Widget _buildOperationsGrid(BuildContext context) {
    final items = [
      _DashboardItem(
        title: 'Field Teams',
        subtitle: 'Open team dashboard',
        icon: Icons.groups_rounded,
        color: const Color(0xFF7C3AED),
        onTap: () => _openScreen(
          context,
          AppRoutes.fieldTeamHome,
        ),
      ),
      _DashboardItem(
        title: 'Incident History',
        subtitle: 'Review past reports',
        icon: Icons.history_rounded,
        color: const Color(0xFF0F766E),
        onTap: () => _openScreen(
          context,
          AppRoutes.reportHistory,
        ),
      ),
      _DashboardItem(
        title: 'Vulnerability & Simulation',
        subtitle: 'Flood risk analysis',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF4F46E5),
        onTap: () => _showFeatureMessage(
          context,
          'Vulnerability & Simulation',
          'This module still needs its risk calculation, '
              'simulation logic, and data sources implemented.',
        ),
      ),
      _DashboardItem(
        title: 'Assignments',
        subtitle: 'Coordinate rescue tasks',
        icon: Icons.assignment_ind_outlined,
        color: const Color(0xFFDB2777),
        onTap: () => _showFeatureMessage(
          context,
          'Rescue Assignments',
          'The assignment workflow needs to be connected to '
              'the backend so the Authority can assign incidents '
              'to field teams and track their progress.',
        ),
      ),
      _DashboardItem(
        title: 'Incident Timeline',
        subtitle: 'Response event history',
        icon: Icons.timeline_rounded,
        color: const Color(0xFF0284C7),
        onTap: () => _showFeatureMessage(
          context,
          'Incident Timeline',
          'A timeline needs backend event records to display '
              'the sequence of incident and response updates.',
        ),
      ),
      _DashboardItem(
        title: 'Reports & Analytics',
        subtitle: 'Response statistics',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFF9333EA),
        onTap: () => _showFeatureMessage(
          context,
          'Reports & Analytics',
          'Statistics and downloadable reports need to be '
              'connected to verified incident, shelter, and '
              'resource data.',
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 142,
          ),
          itemBuilder: (context, index) {
            return _buildActionCard(items[index]);
          },
        );
      },
    );
  }

  Widget _buildActionCard(_DashboardItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5EAF1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 23,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: muted,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
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
              'Use verified backend data for emergency decisions. '
              'Incident assignments, live statistics, and '
              'advanced analytics still require implementation.',
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

class _DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}