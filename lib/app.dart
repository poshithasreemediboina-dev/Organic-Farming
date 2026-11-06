import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/community_provider.dart';
import 'providers/product_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/farmer/farmer_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/community/create_post_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/products/add_product_screen.dart';
import 'screens/complaints/create_complaint_screen.dart';
import 'screens/complaints/my_complaints_screen.dart';
import 'screens/complaints/complaint_detail_screen.dart';
import 'screens/complaints/admin_complaints_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';

class GreenConnectApp extends StatelessWidget {
  const GreenConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ComplaintProvider>(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
        ChangeNotifierProvider<CommunityProvider>(create: (_) => CommunityProvider()),
        ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
        ChangeNotifierProvider<WeatherProvider>(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case AppRoutes.register:
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case AppRoutes.forgotPassword:
              return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
            case AppRoutes.farmerDashboard:
              return MaterialPageRoute(builder: (_) => const FarmerDashboardScreen());
            case AppRoutes.adminDashboard:
              return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
            case AppRoutes.userManagement:
              return MaterialPageRoute(builder: (_) => const UserManagementScreen());
            case AppRoutes.community:
              return MaterialPageRoute(builder: (_) => const CommunityScreen());
            case AppRoutes.createPost:
              return MaterialPageRoute(builder: (_) => const CreatePostScreen());
            case AppRoutes.products:
              return MaterialPageRoute(builder: (_) => const ProductsScreen());
            case AppRoutes.addProduct:
              return MaterialPageRoute(builder: (_) => const AddProductScreen());
            case AppRoutes.createComplaint:
              return MaterialPageRoute(builder: (_) => const CreateComplaintScreen());
            case AppRoutes.myComplaints:
              return MaterialPageRoute(builder: (_) => const MyComplaintsScreen());
            case AppRoutes.complaintDetails:
              final complaintId = settings.arguments as String? ?? '';
              return MaterialPageRoute(
                builder: (_) => ComplaintDetailScreen(complaintId: complaintId),
              );
            case AppRoutes.adminComplaints:
              return MaterialPageRoute(builder: (_) => const AdminComplaintsScreen());
            case AppRoutes.notifications:
              return MaterialPageRoute(builder: (_) => const NotificationsScreen());
            case AppRoutes.profile:
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case AppRoutes.settings:
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },
      ),
    );
  }
}
