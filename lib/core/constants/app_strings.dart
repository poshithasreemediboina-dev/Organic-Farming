class AppStrings {
  static const String appName = 'GreenConnect';
  static const String appTagline = 'Growing Together, Naturally.';
  static const String appCategory = 'Organic Farming & Agriculture Community';

  // Auth
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to access your organic farming dashboard';
  static const String registerTitle = 'Join GreenConnect';
  static const String registerSubtitle = 'Connect with organic growers, experts & markets';
  static const String emailLabel = 'Email Address';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String fullNameLabel = 'Full Name';
  static const String phoneLabel = 'Phone Number';
  static const String cityVillageLabel = 'Village / City';
  static const String stateLabel = 'State';
  static const String roleLabel = 'I am registering as';

  // Roles
  static const String roleFarmer = 'Farmer';
  static const String roleCommunityMember = 'Community Member';
  static const String roleAdmin = 'Administrator';

  // Complaint Categories
  static const List<String> complaintCategories = [
    'Water Supply Problem',
    'Irrigation Issues',
    'Poor Quality Seeds',
    'Fertilizer Issues',
    'Crop Disease',
    'Pest Problems',
    'Organic Certification Issues',
    'Product Quality Issues',
    'Other Agricultural Problems',
  ];

  // Complaint Statuses
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved = 'Resolved';
  static const String statusRejected = 'Rejected';

  // Product Categories
  static const List<String> productCategories = [
    'All Categories',
    'Organic Vegetables',
    'Fruits',
    'Seeds',
    'Natural Fertilizers',
    'Organic Pesticides',
    'Farming Equipment',
  ];

  // Community Categories
  static const List<String> communityCategories = [
    'All Posts',
    'Organic Fertilizers',
    'Natural Pest Control',
    'Crop Management',
    'Soil Health',
    'Organic Vegetables',
    'Farming Success Stories',
  ];
}
