import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../l10n/app_localizations.dart';  // For files in screens/
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import 'package:public_complaint_app/generated/app_localizations.dart';


class ComplaintDetailsScreen extends StatelessWidget {
  final Complaint complaint;


  const ComplaintDetailsScreen({Key? key, required this.complaint}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final complaintService = ComplaintService();


    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.complaintDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value, context, complaintService);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.editComplaint),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.deleteComplaint, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status
            _buildStatusHeader(context),
            
            const SizedBox(height: 20),
            
            // Complaint Details
            _buildComplaintDetails(),
            
            const SizedBox(height: 20),
            
            // Location Section
            if (complaint.hasLocation) _buildLocationSection(context),
            
            const SizedBox(height: 20),
            
            // Image Section
            if (complaint.hasImage) _buildImageSection(context),
            
            const SizedBox(height: 20),
            
            // Metadata
            _buildMetadataSection(context),
          ],
        ),
      ),
    );
  }


  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ComplaintStatus.getStatusColor(complaint.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ComplaintStatus.getStatusColor(complaint.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ComplaintStatus.getStatusIcon(complaint.status),
            color: ComplaintStatus.getStatusColor(complaint.status),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ComplaintStatus.getStatusColor(complaint.status),
                  ),
                ),
                Text(
                  ComplaintStatus.getStatusDescription(complaint.status),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildComplaintDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ComplaintCategories.getCategoryColor(complaint.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ComplaintCategories.getCategoryIcon(complaint.category),
                    color: ComplaintCategories.getCategoryColor(complaint.category),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  complaint.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              complaint.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              complaint.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLocationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l10n.location,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(complaint.location!),
            if (complaint.latitude != null && complaint.longitude != null)
              Text(
                'Coordinates: ${complaint.latitude!.toStringAsFixed(4)}, ${complaint.longitude!.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildImageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  l10n.attachedPhoto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  complaint.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(l10n.failedToLoadImage),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMetadataSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.complaintInformation,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.filedBy, complaint.userName ?? complaint.userEmail),
            _buildInfoRow(l10n.filedOn, _formatDate(complaint.createdAt)),
            if (complaint.updatedAt != null)
              _buildInfoRow(l10n.lastUpdated, _formatDate(complaint.updatedAt!)),
            _buildInfoRow(l10n.complaintId, complaint.id ?? 'N/A'),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }


  void _handleMenuAction(String value, BuildContext context, ComplaintService complaintService) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (value) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.comingSoon)),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, complaintService);
        break;
    }
  }


  void _showDeleteDialog(BuildContext context, ComplaintService complaintService) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteComplaint),
          content: Text(l10n.deleteComplaintConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // FIXED: Only pass complaint ID
                  await complaintService.deleteComplaint(complaint.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.complaintDeletedSuccess)),
                    );
                    Navigator.pop(context); // Go back to dashboard
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.failedToDelete}: $e')),
                    );
                  }
                }
              },
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
