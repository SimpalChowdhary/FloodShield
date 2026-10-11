
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Keep this consistent with the Authority dashboard.
  static const String baseUrl = 'http://192.168.31.105:8081';

  List<Map<String, dynamic>> assignments = [];

  bool isLoading = true;
  String? errorMessage;
  int? updatingAssignmentId;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadAssignments() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Your login token was not found. Please log in again.',
        );
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/field-team/assignments'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! List) {
          throw Exception('Unexpected assignments response.');
        }

        final loaded = decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        if (!mounted) return;

        setState(() {
          assignments = loaded;
          isLoading = false;
          errorMessage = null;
        });
      } else if (response.statusCode == 401 ||
          response.statusCode == 403) {
        throw Exception(
          'Access denied (${response.statusCode}). '
          'Please check your login and Field Team role.',
        );
      } else {
        throw Exception(
          'Could not load assignments '
          '(${response.statusCode}).',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Failed host lookup')) {
      return 'Cannot reach the backend. Check that the server '
          'is running and the IP address is correct.';
    }

    if (message.contains('TimeoutException')) {
      return 'The server took too long to respond. Please retry.';
    }

    return message.replaceFirst('Exception: ', '');
  }

  Future<void> _updateAssignmentStatus(
    Map<String, dynamic> assignment,
    String newStatus,
  ) async {
    final rawId = assignment['assignmentId'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');

    if (id == null) {
      _showMessage('Update failed', 'This assignment has no valid ID.');
      return;
    }

    if (updatingAssignmentId != null) return;

    final oldStatus = _status(assignment['status']);

    if (oldStatus == newStatus) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => updatingAssignmentId = id);

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please log in again to update this task.');
      }

      final response = await http
          .patch(
            Uri.parse(
              '$baseUrl/api/field-team/assignments/$id/status',
            ),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'status': newStatus}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map) {
          throw Exception('Unexpected response from the server.');
        }

        final updated = Map<String, dynamic>.from(decoded);

        if (!mounted) return;

        setState(() {
          final index = assignments.indexWhere(
            (item) => item['assignmentId'].toString() == id.toString(),
          );

          if (index != -1) {
            assignments[index] = {
              ...assignments[index],
              ...updated,
            };
          }

          updatingAssignmentId = null;
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to ${_label(newStatus)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        String details = '';

        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            details = '\n${decoded['message']}';
          }
        } catch (_) {
          // The server may return a non-JSON error response.
        }

        throw Exception(
          'Status update failed (${response.statusCode}).$details',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => updatingAssignmentId = null);

      _showMessage('Update failed', _friendlyError(e));
    }
  }

  String _status(dynamic value) {
    final status = (value ?? 'ASSIGNED')
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_');

    const allowed = {
      'ASSIGNED',
      'ACCEPTED',
      'IN_PROGRESS',
      'COMPLETED',
      'UNABLE_TO_RESPOND',
    };

    return allowed.contains(status) ? status : 'ASSIGNED';
  }

  String _label(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'UNABLE_TO_RESPOND':
        return 'Unable to Respond';
      case 'ASSIGNED':
        return 'Assigned';
      case 'ACCEPTED':
        return 'Accepted';
      case 'COMPLETED':
        return 'Completed';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return blue;
      case 'IN_PROGRESS':
        return const Color(0xFFD97706);
      case 'COMPLETED':
        return const Color(0xFF059669);
      case 'UNABLE_TO_RESPOND':
        return const Color(0xFFDC2626);
      default:
        return muted;
    }
  }

  int _count(String status) {
    return assignments.where(
      (item) => _status(item['status']) == status,
    ).length;
  }

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

  void _showStatusOptions(Map<String, dynamic> assignment) {
    final currentStatus = _status(assignment['status']);
    final id = assignment['assignmentId'];
    final numericId = id is num ? id.toInt() : int.tryParse('$id');

    if (numericId != null && updatingAssignmentId == numericId) {
      return;
    }

    // ASSIGNED is set by Authority. Field Team cannot set it.
    const statuses = [
      'ACCEPTED',
      'IN_PROGRESS',
      'COMPLETED',
      'UNABLE_TO_RESPOND',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
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
              Text(
                'Assignment #${assignment['assignmentId'] ?? '—'}',
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ...statuses.map(
                (status) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    currentStatus == status
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: currentStatus == status
                        ? blue
                        : muted,
                  ),
                  title: Text(_label(status)),
                  onTap: () => _updateAssignmentStatus(
                    assignment,
                    status,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Changes are saved to the backend.',
                style: TextStyle(color: muted, fontSize: 12),
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
            tooltip: 'Refresh assignments',
            onPressed: isLoading ? null : _loadAssignments,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Team information',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showMessage(
              'Field Team',
              'Review your assigned rescue operations and update '
                  'each task as work progresses. Changes are sent '
                  'to the FloodShield backend.',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAssignments,
          child: ListView(
            padding: const EdgeInsets.all(16),
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
              _buildHeading('Team Overview', 'Live assignment counts'),
              const SizedBox(height: 13),
              _buildOverview(),
              const SizedBox(height: 26),
              _buildHeading('My Operations', 'Your assigned field activities'),
              const SizedBox(height: 13),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (errorMessage != null)
                _buildError()
              else if (assignments.isEmpty)
                _buildEmptyState()
              else
                ...assignments.map(_buildAssignmentCard),
              const SizedBox(height: 14),
              _buildActionTile(
                icon: Icons.assignment_rounded,
                color: blue,
                title: 'My Tasks',
                subtitle: 'View your assignments on this dashboard',
                onTap: () {
                  if (assignments.isEmpty && !isLoading) {
                    _loadAssignments();
                  } else {
                    _showMessage(
                      'My Tasks',
                      'You currently have ${assignments.length} '
                          'assignment(s) loaded.',
                    );
                  }
                },
              ),
              _buildActionTile(
                icon: Icons.update_rounded,
                color: const Color(0xFF059669),
                title: 'Update Task Status',
                subtitle: 'Select a status on any assignment card',
                onTap: () {
                  if (assignments.isEmpty) {
                    _showMessage(
                      'No assignments',
                      'There are no assignments available to update.',
                    );
                  } else {
                    _showStatusOptions(assignments.first);
                  }
                },
              ),
              _buildActionTile(
                icon: Icons.location_on_rounded,
                color: const Color(0xFFDC2626),
                title: 'Emergency Locations',
                subtitle: 'View locations listed in your assignments',
                onTap: () {
                  final locations = assignments
                      .map((item) =>
                          (item['incidentLocation'] ?? '').toString())
                      .where((location) => location.trim().isNotEmpty)
                      .toSet()
                      .toList();

                  _showMessage(
                    'Emergency Locations',
                    locations.isEmpty
                        ? 'No incident locations are available in your '
                            'current assignments.'
                        : locations.map((location) => '• $location')
                            .join('\n'),
                  );
                },
              ),
              _buildActionTile(
                icon: Icons.home_work_rounded,
                color: const Color(0xFF7C3AED),
                title: 'Shelter Information',
                subtitle: 'Shelter availability is not connected here yet',
                onTap: () => _showMessage(
                  'Shelter Information',
                  'This dashboard does not yet load shelter availability. '
                      'We can connect it to your existing shelter API next.',
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
                'My assignments:',
                style: TextStyle(color: Colors.white, fontSize: 12),
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
                    isLoading ? 'Loading…' : '${assignments.length} total',
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
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOverview() {
    final items = [
      _TeamMetric(
        title: 'Assigned',
        value: '${_count('ASSIGNED')}',
        icon: Icons.assignment_outlined,
        color: blue,
      ),
      _TeamMetric(
        title: 'In Progress',
        value: '${_count('IN_PROGRESS')}',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFD97706),
      ),
      _TeamMetric(
        title: 'Completed',
        value: '${_count('COMPLETED')}',
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF059669),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
            border: Border.all(color: const Color(0xFFE5EAF1)),
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
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final status = _status(assignment['status']);
    final color = _statusColor(status);
    final rawId = assignment['assignmentId'];
    final id = rawId ?? '—';
    final busy = updatingAssignmentId != null &&
        updatingAssignmentId.toString() == id.toString();

    final description =
        (assignment['incidentDescription'] ?? '').toString().trim();
    final location =
        (assignment['incidentLocation'] ?? '').toString().trim();
    final severity =
        (assignment['incidentSeverity'] ?? '').toString().trim();
    final resource =
        (assignment['requiredResource'] ?? '').toString().trim();
    final notes = (assignment['notes'] ?? '').toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
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
              Expanded(
                child: Text(
                  'Rescue Assignment #$id',
                  style: const TextStyle(
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
                  _label(status),
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
          _detailRow(
            Icons.warning_amber_rounded,
            'Incident #${assignment['incidentId'] ?? '—'}',
          ),
          if (severity.isNotEmpty)
            _detailRow(Icons.priority_high_rounded, 'Severity: $severity'),
          _detailRow(
            Icons.location_on_outlined,
            location.isEmpty ? 'Location not provided' : location,
          ),
          if (description.isNotEmpty)
            _detailRow(Icons.description_outlined, description),
          if (resource.isNotEmpty)
            _detailRow(Icons.inventory_2_outlined, 'Resource: $resource'),
          if (notes.isNotEmpty)
            _detailRow(Icons.notes_rounded, 'Notes: $notes'),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5EAF1)),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => _showStatusOptions(assignment),
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit_rounded, size: 17),
              label: Text(busy ? 'Updating…' : 'Update Task Status'),
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

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: muted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFDC2626),
            size: 38,
          ),
          const SizedBox(height: 10),
          const Text(
            'Could not load assignments',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'An unexpected error occurred.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadAssignments,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          Icon(Icons.assignment_outlined, color: muted, size: 42),
          SizedBox(height: 12),
          Text(
            'No assignments yet',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'When Authority assigns a rescue task to your account, '
            'it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
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
            style: const TextStyle(color: muted, fontSize: 11),
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
          Icon(Icons.info_outline_rounded, color: navy, size: 19),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Assignments and status updates are loaded from the '
              'backend. Shelter availability and map navigation '
              'are not connected on this screen yet.',
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