import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/empty_state_widget.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<ComplaintProvider>(context, listen: false).loadComplaints(userId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final complaintProv = Provider.of<ComplaintProvider>(context);
    final userComplaints = complaintProv.userComplaints;

    final filteredList = userComplaints.where((c) {
      if (_selectedFilter == 'All') return true;
      return c.status == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Grievances & Complaints'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Tab Filters
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected'].map((status) {
                    final isSelected = _selectedFilter == status;
                    Color activeColor = AppColors.forestGreen;
                    if (status == 'Pending') activeColor = AppColors.statusPending;
                    if (status == 'In Progress') activeColor = AppColors.statusInProgress;
                    if (status == 'Resolved') activeColor = AppColors.statusResolved;
                    if (status == 'Rejected') activeColor = AppColors.statusRejected;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: activeColor,
                        backgroundColor: activeColor.withOpacity(0.12),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = status;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Complaints List
            Expanded(
              child: complaintProv.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
                  : filteredList.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.assignment_outlined,
                          title: 'No Grievances in this Category',
                          subtitle: 'You have not submitted any complaints under "$_selectedFilter" status.',
                          buttonText: 'Submit Grievance',
                          onButtonPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.createComplaint);
                          },
                        )
                      : RefreshIndicator(
                          color: AppColors.forestGreen,
                          onRefresh: () async {
                            final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
                            if (user != null) {
                              await complaintProv.loadComplaints(userId: user.id);
                            }
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final complaint = filteredList[index];
                              return ComplaintCard(
                                complaint: complaint,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.complaintDetails,
                                    arguments: complaint.complaintId,
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.createComplaint);
        },
        backgroundColor: AppColors.statusPending,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('New Complaint', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
