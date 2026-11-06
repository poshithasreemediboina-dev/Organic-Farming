import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DatabaseService _db = DatabaseService();
  String _searchQuery = '';
  String _selectedRole = 'All';

  @override
  Widget build(BuildContext context) {
    final allUsers = _db.getUsers();

    final filteredUsers = allUsers.where((u) {
      final matchesSearch = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.phone.contains(_searchQuery) ||
          u.city.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole = _selectedRole == 'All' || u.role == _selectedRole;

      return matchesSearch && matchesRole;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filters Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.white,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by user name, email, phone, city...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.forestGreen),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Farmer', 'Community Member', 'Administrator'].map((role) {
                        final isSelected = _selectedRole == role;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(role),
                            selected: isSelected,
                            selectedColor: AppColors.forestGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            backgroundColor: AppColors.mintGreen.withOpacity(0.3),
                            onSelected: (selected) {
                              setState(() {
                                _selectedRole = role;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // User List
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                      child: Text(
                        'No registered users matching query.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    Color roleColor;
    IconData roleIcon;

    if (user.isAdmin) {
      roleColor = AppColors.lavender;
      roleIcon = Icons.admin_panel_settings_rounded;
    } else if (user.isFarmer) {
      roleColor = AppColors.forestGreen;
      roleIcon = Icons.agriculture_rounded;
    } else {
      roleColor = AppColors.skyBlue;
      roleIcon = Icons.groups_rounded;
    }

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: roleColor.withOpacity(0.2),
              child: Icon(roleIcon, color: roleColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: roleColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(user.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.earthBrown),
                      const SizedBox(width: 2),
                      Text('${user.city}, ${user.state}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enrolled: ${DateFormatter.formatDate(user.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
