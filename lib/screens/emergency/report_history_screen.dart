import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() =>
      _ReportHistoryScreenState();
}

class _ReportHistoryScreenState
    extends State<ReportHistoryScreen> {
  final DatabaseHelper _databaseHelper =
      DatabaseHelper.instance;

  List<Map<String, dynamic>> _reports = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> reports =
          await _databaseHelper.getIncidents();

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load reports: $e',
          ),
        ),
      );
    }
  }

  Future<void> _deleteReport(String id) async {
    try {
      await _databaseHelper.deleteIncident(id);

      await _loadReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete report: $e',
          ),
        ),
      );
    }
  }

  Future<void> _editReport(
    Map<String, dynamic> report,
  ) async {
    final TextEditingController descriptionController =
        TextEditingController(
      text: report['description']?.toString() ?? '',
    );

    String selectedSeverity =
        report['severity']?.toString() ?? 'Low';

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Edit Report'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedSeverity,
                      decoration:
                          const InputDecoration(
                        labelText: 'Flood Severity',
                        border:
                            OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Low',
                          child: Text('Low'),
                        ),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: 'High',
                          child: Text('High'),
                        ),
                        DropdownMenuItem(
                          value: 'Critical',
                          child: Text('Critical'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedSeverity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller:
                          descriptionController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText: 'Description',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      'save',
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != 'save') {
      descriptionController.dispose();
      return;
    }

    try {
      final Map<String, dynamic> updatedIncident =
          {
        'severity': selectedSeverity,
        'description':
            descriptionController.text.trim(),
        'sync_status': 'Pending Sync',
      };

      await _databaseHelper.updateIncident(
        report['id'].toString(),
        updatedIncident,
      );

      await _loadReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report updated and marked for sync.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update report: $e',
          ),
        ),
      );
    } finally {
      descriptionController.dispose();
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null ||
        timestamp.isEmpty) {
      return 'Unknown date';
    }

    try {
      final DateTime date =
          DateTime.parse(timestamp);

      final String day =
          date.day.toString().padLeft(2, '0');
      final String month =
          date.month.toString().padLeft(2, '0');
      final String year =
          date.year.toString();

      final String hour =
          date.hour.toString().padLeft(2, '0');
      final String minute =
          date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return timestamp;
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report History'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _reports.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final Map<String, dynamic>
                          report = _reports[index];

                      return _buildReportCard(
                        report,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Flood Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your submitted flood reports will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    Map<String, dynamic> report,
  ) {
    final String severity =
        report['severity']?.toString() ?? 'Unknown';

    final String description =
        report['description']?.toString() ?? '';

    final String location =
        'Lat: ${report['lat']}, Lng: ${report['lng']}';

    final String syncStatus =
        report['sync_status']?.toString() ??
            'Pending Sync';

    final bool isSynced =
        syncStatus.toLowerCase() == 'synced';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
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
                Expanded(
                  child: Text(
                    'Flood Incident',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _severityColor(
                      severity,
                    ).withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                      color:
                          _severityColor(severity),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(location),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(description),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(
                    report['timestamp']
                        ?.toString(),
                  ),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSynced
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: isSynced
                          ? Colors.green[200]!
                          : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        isSynced
                            ? Icons.cloud_done
                            : Icons.cloud_upload,
                        size: 16,
                        color: isSynced
                            ? Colors.green[700]
                            : Colors.orange[800],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isSynced
                            ? 'Synced'
                            : 'Pending Sync',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                          color: isSynced
                              ? Colors.green[700]
                              : Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () =>
                      _editReport(report),
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  tooltip: 'Edit',
                ),

                IconButton(
                  onPressed: () =>
                      _showDeleteConfirmation(
                    report['id'].toString(),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    String id,
  ) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text(
            'Are you sure you want to delete this flood report?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteReport(id);
    }
  }
}