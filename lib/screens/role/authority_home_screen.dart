
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../routes/app_routes.dart';

class AuthorityHomeScreen extends StatefulWidget {
  const AuthorityHomeScreen({super.key});

  @override
  State<AuthorityHomeScreen> createState() =>
      _AuthorityHomeScreenState();
}

class _AuthorityHomeScreenState extends State<AuthorityHomeScreen> {
  static const Color navy = Color(0xFF102A43);
  static const Color blue = Color(0xFF1769AA);
  static const Color background = Color(0xFFF3F6FB);
  static const Color muted = Color(0xFF64748B);

  // Keep this URL consistent with login_screen.dart.
  static const String baseUrl = 'http://192.168.31.105:8081';

  static const List<String> availableStatuses = [
    'REPORTED',
    'IN_PROGRESS',
    'RESOLVED',
  ];

  List<Map<String, dynamic>> incidents = [];
  final Map<String, String> selectedStatuses = {};
  final Set<String> updatingIncidentIds = {};

  bool isLoading = true;
  String? errorMessage;

  int get totalIncidents => incidents.length;

  int get pendingIncidents => incidents.where((incident) {
        return _statusOf(incident) == 'REPORTED';
      }).length;

  int get activeIncidents => incidents.where((incident) {
        final status = _statusOf(incident);
        return status != 'RESOLVED' &&
            status != 'CLOSED' &&
            status != 'CANCELLED';
      }).length;

  String _statusOf(Map<String, dynamic> incident) {
    return (incident['status'] ?? 'REPORTED')
        .toString()
        .toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    fetchIncidents();
  }

  Future<void> fetchIncidents() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/incidents'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Could not load incidents. HTTP ${response.statusCode}.',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'The server returned an unexpected response.',
        );
      }

      final loadedIncidents = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        incidents = loadedIncidents;
        isLoading = false;

        // Initialize each dropdown from its saved backend status.
        for (final incident in incidents) {
          final id = incident['incidentId']?.toString();
          if (id == null) continue;

          final status = _statusOf(incident);
          selectedStatuses[id] =
              availableStatuses.contains(status) ? status : 'REPORTED';
        }
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'The server took too long to respond. '
            'Check that the backend is running.';
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'The server response could not be read.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> updateIncidentStatus(
    Map<String, dynamic> incident,
  ) async {
    final id = incident['incidentId']?.toString();

    if (id == null || id.isEmpty) {
      _showSnackBar('This incident has no valid ID.');
      return;
    }

    final newStatus = selectedStatuses[id] ?? _statusOf(incident);

    if (newStatus == _statusOf(incident)) {
      _showSnackBar('Choose a different status first.');
      return;
    }

    if (!mounted) return;
    setState(() => updatingIncidentIds.add(id));

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/incidents/$id/status'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'status': newStatus}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (!mounted) return;

        _showSnackBar('Incident #$id updated to '
            '${newStatus.replaceAll('_', ' ')}.');

        await fetchIncidents();
      } else {
        String detail = '';
        try {
          if (response.body.isNotEmpty) {
            detail = ': ${response.body}';
          }
        } catch (_) {
          // Keep the HTTP status message if the body is unreadable.
        }

        throw Exception(
          'Status update failed (HTTP ${response.statusCode})$detail',
        );
      }
    } on TimeoutException {
      if (mounted) {
        _showSnackBar('The status update timed out. Try again.');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => updatingIncidentIds.remove(id));
      }
    }
  }

  void _navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
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
            tooltip: 'Refresh incidents',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: fetchIncidents,
          ),
          IconButton(
            tooltip: 'Dashboard information',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showMessage(
              'Authority Control Center',
              'Review flood reports and update their response '
                  'status. Coordinate emergency response teams.',
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchIncidents,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 20),
                _buildControlBanner(),
                const SizedBox(height: 26),
                _buildSectionHeading(
                  'Situation Overview',
                  'Live incident information from the backend',
                ),
                const SizedBox(height: 14),
                _buildOverviewGrid(),
                const SizedBox(height: 28),
                _buildSectionHeading(
                  'Recent Flood Incidents',
                  'Update the status of each reported incident',
                ),
                const SizedBox(height: 14),
                _buildIncidentSection(),
                const SizedBox(height: 28),
                _buildSectionHeading(
                  'Operations Center',
                  'Emergency management tools',
                ),
                const SizedBox(height: 14),
                _buildOperationsGrid(),
                const SizedBox(height: 22),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Authority Dashboard',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Monitor incidents and coordinate emergency response.',
          style: TextStyle(
            color: muted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildControlBanner() {
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
            color: navy.withValues(alpha: 0.16),
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
                Icon(Icons.shield_rounded,
                    size: 15, color: Colors.white),
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
            'Review incoming reports and support rescue teams '
            'across Telangana.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 43,
            child: ElevatedButton.icon(
              onPressed: () => _navigate(AppRoutes.map),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: navy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 19),
              label: const Text(
                'Open Incident Map',
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
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid() {
    final items = [
      _OverviewItem(
        title: 'Total Incidents',
        value: isLoading && incidents.isEmpty
            ? '...'
            : errorMessage != null && incidents.isEmpty
                ? 'N/A'
                : '$totalIncidents',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFD97706),
      ),
      _OverviewItem(
        title: 'Pending Review',
        value: isLoading && incidents.isEmpty
            ? '...'
            : errorMessage != null && incidents.isEmpty
                ? 'N/A'
                : '$pendingIncidents',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFF7C3AED),
      ),
      _OverviewItem(
        title: 'Active Incidents',
        value: isLoading && incidents.isEmpty
            ? '...'
            : errorMessage != null && incidents.isEmpty
                ? 'N/A'
                : '$activeIncidents',
        icon: Icons.warning_rounded,
        color: const Color(0xFF0284C7),
      ),
      const _OverviewItem(
        title: 'Active Teams',
        value: 'N/A',
        icon: Icons.groups_rounded,
        color: Color(0xFF64748B),
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
            mainAxisExtent: 135,
          ),
          itemBuilder: (context, index) =>
              _buildOverviewCard(items[index]),
        );
      },
    );
  }

  Widget _buildOverviewCard(_OverviewItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF1)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: const TextStyle(
                  color: navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentSection() {
    if (isLoading && incidents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: CircularProgressIndicator(color: blue),
        ),
      );
    }

    if (errorMessage != null && incidents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5EAF1)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFB45309),
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Could not load incidents',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: fetchIncidents,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (incidents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5EAF1)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 42,
              color: muted,
            ),
            SizedBox(height: 10),
            Text(
              'No flood incidents found',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'New reports will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final recentIncidents = [...incidents]
      ..sort((a, b) {
        final dateA = DateTime.tryParse('${a['timestamp'] ?? ''}');
        final dateB = DateTime.tryParse('${b['timestamp'] ?? ''}');

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

    return Column(
      children: [
        if (isLoading)
          const LinearProgressIndicator(minHeight: 2),
        ...recentIncidents.take(5).map(_buildIncidentCard),
        if (incidents.length > 5)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _navigate(AppRoutes.reportHistory),
              child: const Text('View All Incidents'),
            ),
          ),
      ],
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> incident) {
    final id = incident['incidentId']?.toString() ?? '';
    final severity = (incident['severity'] ?? 'Unknown').toString();
    final status = _statusOf(incident);
    final location =
        (incident['gpsLocation'] ?? 'Location unavailable').toString();
    final description =
        (incident['description'] ?? 'No description provided').toString();
    final timestamp = (incident['timestamp'] ?? '').toString();

    final normalizedSeverity = severity.toUpperCase();
    final severityColor = normalizedSeverity.contains('HIGH') ||
            normalizedSeverity.contains('CRITICAL') ||
            normalizedSeverity.contains('SEVERE')
        ? const Color(0xFFDC2626)
        : normalizedSeverity.contains('MEDIUM') ||
                normalizedSeverity.contains('MODERATE')
            ? const Color(0xFFD97706)
            : const Color(0xFF0284C7);

    

    final isUpdating = updatingIncidentIds.contains(id);
    final selectedStatus = selectedStatuses[id] ?? status;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
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
              Expanded(
                child: Text(
                  'Incident #$id',
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: muted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Current status: ${status.replaceAll('_', ' ')}',
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (timestamp.isNotEmpty)
                Flexible(
                  child: Text(
                    timestamp.replaceFirst('T', ' '),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Update incident status',
            style: TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ),
            items: availableStatuses.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: isUpdating
                ? null
                : (value) {
                    if (value == null || id.isEmpty) return;
                    setState(() => selectedStatuses[id] = value);
                  },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isUpdating || id.isEmpty
                  ? null
                  : () => updateIncidentStatus(incident),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.blueGrey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isUpdating
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(
                isUpdating ? 'Updating...' : 'Update Status',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsGrid() {
    final items = [
      _OperationItem(
        title: 'Incident Map',
        subtitle: 'View flood locations',
        icon: Icons.map_rounded,
        color: const Color(0xFF1769AA),
        route: AppRoutes.map,
      ),
      _OperationItem(
        title: 'Rescue Teams',
        subtitle: 'Coordinate field teams',
        icon: Icons.groups_rounded,
        color: const Color(0xFF7C3AED),
        route: AppRoutes.fieldTeamHome,
      ),
      _OperationItem(
        title: 'Resources',
        subtitle: 'Emergency supplies',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFD97706),
        route: AppRoutes.resources,
      ),
      _OperationItem(
        title: 'Shelter Management',
        subtitle: 'Review shelters',
        icon: Icons.home_work_rounded,
        color: const Color(0xFF059669),
        route: AppRoutes.shelters,
      ),
      _OperationItem(
        title: 'Incident History',
        subtitle: 'Review all reports',
        icon: Icons.history_rounded,
        color: const Color(0xFF0F766E),
        route: AppRoutes.reportHistory,
      ),
      _OperationItem(
        title: 'Incident Timeline',
        subtitle: 'Response activities',
        icon: Icons.timeline_rounded,
        color: const Color(0xFFDB2777),
      ),
      _OperationItem(
        title: 'Reports & Analytics',
        subtitle: 'Response summaries',
        icon: Icons.analytics_rounded,
        color: const Color(0xFF4F46E5),
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
            mainAxisExtent: 140,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (item.route != null) {
                    _navigate(item.route!);
                  } else {
                    _showMessage(
                      item.title,
                      'This feature needs its own implementation '
                          'and backend integration.',
                    );
                  }
                },
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
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
              'Incident data and status updates use the backend. '
              'Team counts and advanced analytics are not yet '
              'connected. Verify reports before acting.',
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

class _OverviewItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _OperationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? route;

  const _OperationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.route,
  });
}