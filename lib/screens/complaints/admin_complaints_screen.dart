import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/empty_state_widget.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStatusDialog(BuildContext context, ComplaintModel complaint) {
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
                  Text('Admin Action', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grievance #${complaint.complaintId} by ${complaint.userName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    const Text('Workflow Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                    const Text('Official Remarks / Resolution Details:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarksController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'e.g. Field inspection completed. Free bio-fertilizer voucher issued.',
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
                          content: Text(
                            'Status changed to $selectedStatus. Notification sent to ${complaint.userName}!',
                          ),
                          backgroundColor: AppColors.statusResolved,
                        ),
                      );
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
    final complaints = complaintProv.filteredAdminComplaints;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Admin Complaint Console'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Status Tabs Header
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by complaint ID (#GC1025), title, farmer, village...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.forestGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                complaintProv.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => complaintProv.setSearchQuery(val),
                  ),
                  const SizedBox(height: 10),

                  // Status filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected'].map((status) {
                        final isSelected = complaintProv.selectedStatus == status;
                        Color statusColor = AppColors.forestGreen;
                        if (status == 'Pending') statusColor = AppColors.statusPending;
                        if (status == 'In Progress') statusColor = AppColors.statusInProgress;
                        if (status == 'Resolved') statusColor = AppColors.statusResolved;
                        if (status == 'Rejected') statusColor = AppColors.statusRejected;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            selectedColor: statusColor,
                            backgroundColor: statusColor.withOpacity(0.12),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              complaintProv.setStatusFilter(status);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category filter dropdown
                  Row(
                    children: [
                      const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      const Text('Category:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: complaintProv.selectedCategory,
                            isDense: true,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                            items: ['All', ...AppStrings.complaintCategories].map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) complaintProv.setCategoryFilter(val);
                            },
                          ),
                        ),
                      ),
                      if (complaintProv.selectedCategory != 'All' || complaintProv.selectedStatus != 'All' || complaintProv.searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            complaintProv.clearFilters();
                          },
                          child: const Text('Reset', style: TextStyle(fontSize: 12, color: AppColors.coral)),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Complaints count indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${complaints.length} grievances',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    'Tap card to view / update',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Complaint Cards List
            Expanded(
              child: complaints.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.done_all_rounded,
                      title: 'No Matching Complaints',
                      subtitle: 'There are no farmer grievances matching the current filters.',
                      buttonText: 'Clear Filters',
                      onButtonPressed: () {
                        _searchController.clear();
                        complaintProv.clearFilters();
                      },
                    )
                  : RefreshIndicator(
                      color: AppColors.forestGreen,
                      onRefresh: () => complaintProv.loadComplaints(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: complaints.length,
                        itemBuilder: (context, index) {
                          final c = complaints[index];
                          return ComplaintCard(
                            complaint: c,
                            showFarmerName: true,
                            onTap: () {
                              _showStatusDialog(context, c);
                            },
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
}
