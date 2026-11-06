import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/community_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final complaintProv = Provider.of<ComplaintProvider>(context);
    final communityProv = Provider.of<CommunityProvider>(context);

    final userComplaintsCount = complaintProv.userComplaints.length;
    final resolvedCount = complaintProv.userComplaints.where((c) => c.status == 'Resolved').length;
    final userPostsCount = communityProv.posts.where((p) => p.userId == user?.id).length;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Farmer Profile'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.white,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'F',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Organic Farmer',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Role: ${user?.role ?? "Farmer"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mintGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Activity Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Grievances', '$userComplaintsCount', Icons.assignment_outlined, AppColors.statusPending),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard('Resolved', '$resolvedCount', Icons.check_circle_outlined, AppColors.statusResolved),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard('Forum Posts', '$userPostsCount', Icons.forum_outlined, AppColors.forestGreen),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileItem(Icons.phone_outlined, 'Phone', user?.phone ?? 'Not provided'),
                    const Divider(height: 16),
                    _buildProfileItem(Icons.location_on_outlined, 'Location', '${user?.city ?? ""}, ${user?.state ?? ""}'),
                    const Divider(height: 16),
                    _buildProfileItem(Icons.badge_outlined, 'Member ID', user?.id ?? ''),
                    const Divider(height: 16),
                    _buildProfileItem(
                      Icons.calendar_today_outlined,
                      'Member Since',
                      user != null ? DateFormatter.formatDate(user.createdAt) : '',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Quick Actions
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.track_changes_rounded,
                      title: 'My Grievances & Tracking',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.myComplaints),
                    ),
                    const Divider(height: 1),
                    _buildActionTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notification Center',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                    ),
                    const Divider(height: 1),
                    _buildActionTile(
                      icon: Icons.storefront_outlined,
                      title: 'Organic Marketplace',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.products),
                    ),
                    const Divider(height: 1),
                    _buildActionTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings & Theme Preferences',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.coral),
                  label: const Text(
                    'Sign Out of GreenConnect',
                    style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.coral, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.forestGreen),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.forestGreen, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
