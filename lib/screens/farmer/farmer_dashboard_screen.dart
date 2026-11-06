import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/community_post_card.dart';
import '../../widgets/product_card.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _organicTips = [
    {
      'title': 'Neem Oil Foliar Spray',
      'category': 'Pest Defense',
      'tip': 'Mix 5ml pure cold-pressed neem oil with 2ml organic liquid soap per litre of water. Apply at sunset to repel whiteflies and aphids.',
      'icon': 'yard_rounded',
    },
    {
      'title': 'Trichoderma Seed Treatment',
      'category': 'Fungal Shield',
      'tip': 'Coat seeds with Trichoderma viride @ 10g/kg before sowing to prevent root rot and damping-off disease naturally.',
      'icon': 'grain_rounded',
    },
    {
      'title': 'Panchagavya Growth Tonic',
      'category': 'Bio-Fertilizer',
      'tip': 'Apply 3% Panchagavya spray at 15-day intervals during vegetative stage for vibrant chlorophyll synthesis and thicker stem caliber.',
      'icon': 'local_florist_rounded',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.currentUser?.id;

      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints(userId: userId);
      Provider.of<CommunityProvider>(context, listen: false).loadPosts();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather();

      if (userId != null) {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final complaintProv = Provider.of<ComplaintProvider>(context);
    final notifProv = Provider.of<NotificationProvider>(context);
    final weatherProv = Provider.of<WeatherProvider>(context);
    final communityProv = Provider.of<CommunityProvider>(context);
    final productProv = Provider.of<ProductProvider>(context);

    final unreadNotifs = user != null ? notifProv.unreadCount : 0;
    final userComplaints = complaintProv.userComplaints;

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
              child: const Icon(Icons.eco_rounded, color: AppColors.freshLeafGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GreenConnect',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  user?.city.isNotEmpty == true ? '${user!.city}, ${user.state}' : 'Organic Hub',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification Icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.white),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.notifications);
                },
                tooltip: 'Notifications',
              ),
              if (unreadNotifs > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.statusPending,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadNotifs',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.profile);
              },
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.mintGreen,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'F',
                  style: const TextStyle(
                    color: AppColors.forestGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: () async {
            if (user != null) {
              await Future.wait([
                complaintProv.loadComplaints(userId: user.id),
                communityProv.loadPosts(),
                productProv.loadProducts(),
                weatherProv.fetchWeather(forceRefresh: true),
                notifProv.loadNotifications(user.id),
              ]);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome Card Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forestGreen.withOpacity(0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Namaste, ${user?.name ?? 'Organic Farmer'}! 🌱',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Certified Organic Member • ${user?.city ?? "Maharashtra"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.white.withOpacity(0.88),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: AppColors.mintGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 3. Search Bar
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search pests, tips, organic inputs, seeds...',
                            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.freshLeafGreen),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (query) {
                            if (query.isNotEmpty) {
                              Navigator.of(context).pushNamed(AppRoutes.community);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 11. Quick Action Buttons
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.report_problem_rounded,
                        label: 'Register\nComplaint',
                        color: AppColors.statusPending,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.createComplaint);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.track_changes_rounded,
                        label: 'Track My\nComplaints',
                        color: AppColors.skyBlue,
                        badgeText: '${userComplaints.length}',
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.myComplaints);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.post_add_rounded,
                        label: 'Share\nExperience',
                        color: AppColors.freshLeafGreen,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.createPost);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.storefront_rounded,
                        label: 'Organic\nMarket',
                        color: AppColors.earthBrown,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.products);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. REST API Weather Information Card
                _buildWeatherCard(weatherProv),

                const SizedBox(height: 20),

                // 8 & 9. My Complaints Summary & Status
                _buildComplaintsSummary(userComplaints),

                const SizedBox(height: 20),

                // 5. Organic Farming Tips Section
                _buildOrganicTipsSection(),

                const SizedBox(height: 20),

                // 6. Latest Community Posts Preview
                _buildCommunityPreview(communityProv),

                const SizedBox(height: 20),

                // 7. Available Organic Products Preview
                _buildProductsPreview(productProv),

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
              break; // Already on dashboard
            case 1:
              Navigator.of(context).pushNamed(AppRoutes.community);
              break;
            case 2:
              Navigator.of(context).pushNamed(AppRoutes.products);
              break;
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.myComplaints);
              break;
            case 4:
              Navigator.of(context).pushNamed(AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket_rounded),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (badgeText != null && badgeText != '0')
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherProvider weatherProv) {
    if (weatherProv.isLoading) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.skyBlue)),
            ),
            SizedBox(width: 12),
            Text('Fetching live agricultural weather forecast...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (weatherProv.hasError || weatherProv.weather == null) {
      return Container(
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
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.sunriseOrange, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Weather Service Offline',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.earthBrown),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => weatherProv.retry(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              weatherProv.errorMessage ?? 'Unable to connect to Open-Meteo REST API.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final weather = weatherProv.weather!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF67B26F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Location, Live Tag, Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.white),
                  const SizedBox(width: 4),
                  Text(
                    weather.cityName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Live Open-Meteo',
                      style: TextStyle(color: AppColors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.white),
                onPressed: () => weatherProv.retry(),
                tooltip: 'Refresh Weather',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Weather Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.conditionText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Humidity: ${weather.humidity.toStringAsFixed(0)}%  •  Wind: ${weather.windSpeed.toStringAsFixed(1)} km/h',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Smart Agronomic Recommendation
          if (weather.recommendations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.white.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.warmCream),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Organic Advisory: ${weather.recommendations.first}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplaintsSummary(List userComplaints) {
    final pendingCount = userComplaints.where((c) => c.status == 'Pending').length;
    final inProgressCount = userComplaints.where((c) => c.status == 'In Progress').length;
    final resolvedCount = userComplaints.where((c) => c.status == 'Resolved').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Complaints Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.myComplaints);
              },
              child: const Text('View All', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Pending',
                value: '$pendingCount',
                icon: Icons.hourglass_top_rounded,
                color: AppColors.statusPending,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.myComplaints),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DashboardCard(
                title: 'In Progress',
                value: '$inProgressCount',
                icon: Icons.engineering_rounded,
                color: AppColors.statusInProgress,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.myComplaints),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DashboardCard(
                title: 'Resolved',
                value: '$resolvedCount',
                icon: Icons.verified_rounded,
                color: AppColors.statusResolved,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.myComplaints),
              ),
            ),
          ],
        ),

        // Recent complaint tracker preview
        if (userComplaints.isNotEmpty) ...[
          const SizedBox(height: 12),
          ComplaintCard(
            complaint: userComplaints.first,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.complaintDetails,
                arguments: userComplaints.first.complaintId,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOrganicTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Organic Farming Tips',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Daily Best Practices',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _organicTips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tip = _organicTips[index];
              return Container(
                width: 260,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.freshLeafGreen.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.freshLeafGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tip['category']!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tip['title']!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        tip['tip']!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityPreview(CommunityProvider communityProv) {
    final posts = communityProv.posts;
    final previewPosts = posts.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Community Discussions',
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
              child: const Text('View All', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (previewPosts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No community posts yet. Be the first to share!'),
          )
        else
          ...previewPosts.map((post) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final currentUserId = auth.currentUser?.id ?? '';
            return CommunityPostCard(
              post: post,
              currentUserId: currentUserId,
              isAdmin: auth.isAdmin,
              onLike: () => communityProv.toggleLike(post.id, currentUserId),
              onComment: () => Navigator.of(context).pushNamed(AppRoutes.community),
              onDelete: null,
            );
          }),
      ],
    );
  }

  Widget _buildProductsPreview(ProductProvider productProv) {
    final products = productProv.products;
    final previewProducts = products.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Organic Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.products);
              },
              child: const Text('Marketplace', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (previewProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No products listed yet.'),
          )
        else
          ...previewProducts.map((p) {
            return ProductCard(
              product: p,
              onContact: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contacting seller ${p.sellerName} at ${p.sellerPhone}...'),
                    backgroundColor: AppColors.forestGreen,
                  ),
                );
              },
            );
          }),
      ],
    );
  }
}
