import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/community_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/community_post_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
      Provider.of<CommunityProvider>(context, listen: false).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final complaintProv = Provider.of<ComplaintProvider>(context);
    final communityProv = Provider.of<CommunityProvider>(context);

    // Dynamic real data from database
    final allUsers = _db.getUsers();
    final totalUsers = allUsers.length;
    final totalFarmers = allUsers.where((u) => u.isFarmer).length;

    final totalComplaints = complaintProv.totalComplaintsCount;
    final pendingComplaints = complaintProv.pendingComplaintsCount;
    final inProgressComplaints = complaintProv.inProgressComplaintsCount;
    final resolvedComplaints = complaintProv.resolvedComplaintsCount;
    final recentComplaints = complaintProv.allComplaints.take(3).toList();
    final recentPosts = communityProv.posts.take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Portal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'GreenConnect Governance Console',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mintGreen,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_rounded, color: AppColors.white),
            tooltip: 'User Directory',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.userManagement);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.white),
            tooltip: 'Sign Out',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: () async {
            await Future.wait([
              complaintProv.loadComplaints(),
              communityProv.loadPosts(),
            ]);
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Admin Welcome Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A2F), Color(0xFF2E6F52)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.white.withOpacity(0.2),
                        child: const Icon(Icons.verified_user_rounded, color: AppColors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.currentUser?.name ?? 'Admin Officer',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Agricultural Grievance Redressal & Community Oversight',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Statistics Grid: Real Data
                const Text(
                  'System Statistics & Grievances',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // Row 1: Users & Farmers
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Total Users',
                        value: '$totalUsers',
                        subtitle: 'Registered Accounts',
                        icon: Icons.people_outline_rounded,
                        color: AppColors.lavender,
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userManagement),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DashboardCard(
                        title: 'Total Farmers',
                        value: '$totalFarmers',
                        subtitle: 'Cultivators Enrolled',
                        icon: Icons.agriculture_rounded,
                        color: AppColors.forestGreen,
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userManagement),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 2: Total Complaints & Pending
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Total Complaints',
                        value: '$totalComplaints',
                        subtitle: 'All Recorded',
                        icon: Icons.folder_shared_outlined,
                        color: AppColors.earthBrown,
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminComplaints),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DashboardCard(
                        title: 'Pending Action',
                        value: '$pendingComplaints',
                        subtitle: 'Awaiting Review',
                        icon: Icons.hourglass_top_rounded,
                        color: AppColors.statusPending,
                        badgeCount: pendingComplaints,
                        onTap: () {
                          complaintProv.setStatusFilter('Pending');
                          Navigator.of(context).pushNamed(AppRoutes.adminComplaints);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 3: In Progress & Resolved
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'In Progress',
                        value: '$inProgressComplaints',
                        subtitle: 'Investigation Active',
                        icon: Icons.engineering_rounded,
                        color: AppColors.statusInProgress,
                        onTap: () {
                          complaintProv.setStatusFilter('In Progress');
                          Navigator.of(context).pushNamed(AppRoutes.adminComplaints);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DashboardCard(
                        title: 'Resolved',
                        value: '$resolvedComplaints',
                        subtitle: 'Successfully Closed',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.statusResolved,
                        onTap: () {
                          complaintProv.setStatusFilter('Resolved');
                          Navigator.of(context).pushNamed(AppRoutes.adminComplaints);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Interactive Chart: Complaint Distribution
                _buildComplaintStatusChart(
                  pending: pendingComplaints,
                  inProgress: inProgressComplaints,
                  resolved: resolvedComplaints,
                ),

                const SizedBox(height: 20),

                // Quick Navigation Management Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          complaintProv.clearFilters();
                          Navigator.of(context).pushNamed(AppRoutes.adminComplaints);
                        },
                        icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                        label: const Text('Manage Complaints', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.userManagement);
                        },
                        icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                        label: const Text('User Management', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.forestGreen,
                          side: const BorderSide(color: AppColors.forestGreen, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 7. Recent Complaints Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Farmer Complaints',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        complaintProv.clearFilters();
                        Navigator.of(context).pushNamed(AppRoutes.adminComplaints);
                      },
                      child: const Text('View All', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                if (recentComplaints.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No complaints submitted yet.'),
                  )
                else
                  ...recentComplaints.map((c) {
                    return ComplaintCard(
                      complaint: c,
                      showFarmerName: true,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.complaintDetails,
                          arguments: c.complaintId,
                        );
                      },
                    );
                  }),

                const SizedBox(height: 20),

                // 8. Recent Community Posts Section (Moderation)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Community Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.community);
                      },
                      child: const Text('Open Forum', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                if (recentPosts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No posts yet.'),
                  )
                else
                  ...recentPosts.map((post) {
                    return CommunityPostCard(
                      post: post,
                      currentUserId: auth.currentUser?.id ?? '',
                      isAdmin: true,
                      onLike: () => communityProv.toggleLike(post.id, auth.currentUser?.id ?? ''),
                      onComment: () => Navigator.of(context).pushNamed(AppRoutes.community),
                      onDelete: () async {
                        await communityProv.deletePost(post.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post moderated and removed by administrator.')),
                          );
                        }
                      },
                    );
                  }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.forestGreen,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Admin Home
            case 1:
              complaintProv.clearFilters();
              Navigator.of(context).pushNamed(AppRoutes.adminComplaints);
              break;
            case 2:
              Navigator.of(context).pushNamed(AppRoutes.userManagement);
              break;
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.community);
              break;
            case 4:
              Navigator.of(context).pushNamed(AppRoutes.products);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Grievances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_rounded),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Market',
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintStatusChart({
    required int pending,
    required int inProgress,
    required int resolved,
  }) {
    final total = pending + inProgress + resolved;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Complaint Status Breakdown',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$total Active Records',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No complaints in database yet.'),
                ),
              )
            else
              Row(
                children: [
                  // Pie Chart
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 28,
                        sections: [
                          if (pending > 0)
                            PieChartSectionData(
                              color: AppColors.statusPending,
                              value: pending.toDouble(),
                              title: '$pending',
                              radius: 26,
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.white),
                            ),
                          if (inProgress > 0)
                            PieChartSectionData(
                              color: AppColors.statusInProgress,
                              value: inProgress.toDouble(),
                              title: '$inProgress',
                              radius: 26,
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.white),
                            ),
                          if (resolved > 0)
                            PieChartSectionData(
                              color: AppColors.statusResolved,
                              value: resolved.toDouble(),
                              title: '$resolved',
                              radius: 26,
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Legends
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('Pending (${((pending / total) * 100).toStringAsFixed(0)}%)', AppColors.statusPending, pending),
                        const SizedBox(height: 8),
                        _buildLegendItem('In Progress (${((inProgress / total) * 100).toStringAsFixed(0)}%)', AppColors.statusInProgress, inProgress),
                        const SizedBox(height: 8),
                        _buildLegendItem('Resolved (${((resolved / total) * 100).toStringAsFixed(0)}%)', AppColors.statusResolved, resolved),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
