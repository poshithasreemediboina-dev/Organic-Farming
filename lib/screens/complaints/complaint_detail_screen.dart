import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/status_badge.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  void _openAdminUpdateModal(BuildContext context, ComplaintModel complaint) {
    final complaintProv = Provider.of<ComplaintProvider>(context, listen: false);
    String selectedStatus = complaint.status;
    final remarksController = TextEditingController(text: complaint.adminRemarks ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: const [
                  Icon(Icons.edit_note_rounded, color: AppColors.forestGreen),
                  SizedBox(width: 8),
                  Text('Update Complaint', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Complaint #${complaint.complaintId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    const Text('Change Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: ['Pending', 'In Progress', 'Resolved', 'Rejected'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedStatus = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Official Admin Remarks / Resolution Details:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarksController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter field inspection findings or remedial action taken...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final success = await complaintProv.updateStatus(
                      complaintId: complaint.complaintId,
                      newStatus: selectedStatus,
                      remarks: remarksController.text.trim(),
                    );
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Status updated to $selectedStatus. Farmer notified!'),
                          backgroundColor: AppColors.statusResolved,
                        ),
                      );
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
                  child: const Text('Save & Notify Farmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaintProv = Provider.of<ComplaintProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final complaint = complaintProv.getComplaintById(widget.complaintId);

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Tracking')),
        body: const Center(child: Text('Complaint not found or has been removed.')),
      );
    }

    final isAdmin = auth.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Tracking #${complaint.complaintId}'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, size: 26),
              tooltip: 'Update Status',
              onPressed: () => _openAdminUpdateModal(context, complaint),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${complaint.complaintId}',
                            style: const TextStyle(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        StatusBadge(status: complaint.status, fontSize: 13),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      complaint.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.freshLeafGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        complaint.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Resolution Progress Timeline
              const Text(
                'Resolution Workflow Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTimeline(complaint),

              const SizedBox(height: 20),

              // Detailed Description Card
              _buildSectionCard(
                title: 'Problem Description',
                icon: Icons.description_outlined,
                content: Text(
                  complaint.description,
                  style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.45),
                ),
              ),

              const SizedBox(height: 14),

              // Grievance Details Grid
              _buildSectionCard(
                title: 'Location & Crop Information',
                icon: Icons.agriculture_outlined,
                content: Column(
                  children: [
                    _buildInfoRow('Location / Village', complaint.location, Icons.location_on_outlined),
                    const Divider(height: 16),
                    _buildInfoRow('Affected Crop', complaint.cropName ?? 'Not specified', Icons.grass_rounded),
                    const Divider(height: 16),
                    _buildInfoRow('Submitted By', complaint.userName, Icons.person_outline_rounded),
                    const Divider(height: 16),
                    _buildInfoRow('Contact Phone', complaint.userPhone, Icons.phone_outlined),
                    const Divider(height: 16),
                    _buildInfoRow('Submission Date', DateFormatter.formatDateTime(complaint.createdAt), Icons.calendar_today_outlined),
                    if (complaint.resolvedAt != null) ...[
                      const Divider(height: 16),
                      _buildInfoRow('Resolved Date', DateFormatter.formatDateTime(complaint.resolvedAt!), Icons.verified_outlined, valueColor: AppColors.statusResolved),
                    ],
                  ],
                ),
              ),

              // Admin Remarks Highlight Card
              if (complaint.adminRemarks != null && complaint.adminRemarks!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warmCream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sunriseOrange.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.admin_panel_settings_rounded, color: AppColors.forestGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Official Administration Remarks',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        complaint.adminRemarks!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Last updated: ${DateFormatter.formatDateTime(complaint.updatedAt)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],

              // Admin Action Button if logged in as Admin
              if (isAdmin) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAdminUpdateModal(context, complaint),
                    icon: const Icon(Icons.security_update_good_rounded),
                    label: const Text('Update Complaint Status & Remark', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(ComplaintModel complaint) {
    final isPending = complaint.status == 'Pending';
    final isInProgress = complaint.status == 'In Progress';
    final isResolved = complaint.status == 'Resolved';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        children: [
          // Step 1: Grievance Submitted
          _buildTimelineStep(
            title: 'Grievance Submitted',
            subtitle: 'Logged by ${complaint.userName} on ${DateFormatter.formatDate(complaint.createdAt)}',
            isCompleted: true,
            isActive: isPending,
            stepColor: AppColors.statusPending,
            showLine: true,
          ),
          // Step 2: Under Review / In Progress
          _buildTimelineStep(
            title: 'Under Review & Investigation',
            subtitle: isInProgress || isResolved
                ? 'Assigned to agricultural field officer'
                : 'Pending administrative triage',
            isCompleted: isInProgress || isResolved,
            isActive: isInProgress,
            stepColor: AppColors.statusInProgress,
            showLine: true,
          ),
          // Step 3: Resolved
          _buildTimelineStep(
            title: 'Resolution Completed',
            subtitle: isResolved
                ? 'Closed on ${DateFormatter.formatDate(complaint.resolvedAt ?? complaint.updatedAt)}'
                : 'Awaiting corrective action',
            isCompleted: isResolved,
            isActive: isResolved,
            stepColor: AppColors.statusResolved,
            showLine: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required Color stepColor,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? stepColor : AppColors.dividerColor,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: AppColors.white,
                size: 16,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 42,
                color: isCompleted ? stepColor.withOpacity(0.5) : AppColors.dividerColor,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
                  color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.forestGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
