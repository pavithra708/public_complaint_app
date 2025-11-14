import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/complaint_model.dart';
import '../services/auth_service.dart';
import '../services/complaint_service.dart';
import 'complaint_details_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ComplaintService _complaintService = ComplaintService();
  String _categoryFilter = 'All';
  String _statusFilter = 'All';

  List<String> get _categoryOptions =>
      ['All', ...ComplaintCategories.categories];

  List<String> get _statusOptions => ['All', ...ComplaintStatus.allStatuses];

  Future<void> _updateStatus(Complaint complaint, String newStatus) async {
    if (complaint.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update this complaint (missing id).'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await _complaintService.updateComplaintStatus(complaint.id!, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated status to $newStatus'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Complaint>>(
        stream: _complaintService.getAllComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Failed to load complaints: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final complaints = snapshot.data ?? [];
          final filteredComplaints = complaints.where((complaint) {
            final categoryMatches = _categoryFilter == 'All' ||
                complaint.category == _categoryFilter;
            final statusMatches =
                _statusFilter == 'All' || complaint.status == _statusFilter;
            return categoryMatches && statusMatches;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStats(complaints),
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredComplaints.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredComplaints.length,
                          itemBuilder: (context, index) {
                            final complaint = filteredComplaints[index];
                            return _buildComplaintAdminCard(complaint);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(List<Complaint> complaints) {
    final total = complaints.length;
    final pending =
        complaints.where((c) => c.status == ComplaintStatus.pending).length;
    final inProgress =
        complaints.where((c) => c.status == ComplaintStatus.inProgress).length;
    final resolved =
        complaints.where((c) => c.status == ComplaintStatus.resolved).length;

    final cards = [
      _StatCardData(
        title: 'Total',
        value: total.toString(),
        color: Colors.blue,
        icon: Icons.dashboard,
      ),
      _StatCardData(
        title: 'Pending',
        value: pending.toString(),
        color: Colors.orange,
        icon: Icons.access_time,
      ),
      _StatCardData(
        title: 'In Progress',
        value: inProgress.toString(),
        color: Colors.indigo,
        icon: Icons.build,
      ),
      _StatCardData(
        title: 'Resolved',
        value: resolved.toString(),
        color: Colors.green,
        icon: Icons.check_circle,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final cardWidth = isWide ? 200.0 : (constraints.maxWidth / 2) - 12;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth.clamp(160, 220),
                  child: _StatCard(data: card),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            value: _categoryFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Category',
              border: OutlineInputBorder(),
            ),
            items: _categoryOptions
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _categoryFilter = value;
                });
              }
            },
          ),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            value: _statusFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: _statusOptions
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _statusFilter = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintAdminCard(Complaint complaint) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ComplaintCategories.getCategoryColor(complaint.category)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    ComplaintCategories.getCategoryIcon(complaint.category),
                    color: ComplaintCategories.getCategoryColor(complaint.category),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${complaint.category} • ${complaint.timeAgo}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Filed by: ${complaint.userName ?? complaint.userEmail}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailsScreen(
                          complaint: complaint,
                        ),
                      ),
                    );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Text('View details'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              complaint.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            _StatusControls(
              complaint: complaint,
              onStatusChanged: (value) => _updateStatus(complaint, value),
              onMarkResolved: () =>
                  _updateStatus(complaint, ComplaintStatus.resolved),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No complaints match the current filter.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: color),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 24,
              color: color.darken(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusControls extends StatelessWidget {
  final Complaint complaint;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onMarkResolved;

  const _StatusControls({
    required this.complaint,
    required this.onStatusChanged,
    required this.onMarkResolved,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final dropdownWidth = (maxWidth > 600) ? 220.0 : maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              avatar: Icon(
                ComplaintStatus.getStatusIcon(complaint.status),
                size: 16,
                color: Colors.white,
              ),
              label: Text(complaint.status),
              backgroundColor: ComplaintStatus.getStatusColor(complaint.status),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: dropdownWidth,
              child: DropdownButtonFormField<String>(
                value: complaint.status,
                decoration: const InputDecoration(
                  labelText: 'Update status',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ComplaintStatus.allStatuses
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null && value != complaint.status) {
                    onStatusChanged(value);
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: complaint.status == ComplaintStatus.resolved
                  ? null
                  : onMarkResolved,
              child: const Text('Mark Resolved'),
            ),
          ],
        );
      },
    );
  }
}

extension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

