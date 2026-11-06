import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = AppStrings.roleFarmer;
  bool _profileImagePicked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      role: _selectedRole,
      city: _cityController.text,
      state: _stateController.text,
      profileImageUrl: _profileImagePicked ? 'profile_avatar_mock' : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Welcome to GreenConnect.'),
          backgroundColor: AppColors.statusResolved,
        ),
      );
      if (auth.isAdmin) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.farmerDashboard);
      }
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.coral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  AppStrings.registerTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.registerSubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Optional Profile Image Picker
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.mintGreen,
                        child: Icon(
                          _profileImagePicked ? Icons.check_circle_rounded : Icons.person_rounded,
                          size: 48,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _profileImagePicked = !_profileImagePicked;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_profileImagePicked
                                    ? 'Default farming avatar selected.'
                                    : 'Profile photo removed.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.forestGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _profileImagePicked ? 'Avatar Selected' : 'Tap to add profile photo (Optional)',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 20),

                // Role Selection
                const Text(
                  AppStrings.roleLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = AppStrings.roleFarmer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == AppStrings.roleFarmer
                                ? AppColors.forestGreen
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == AppStrings.roleFarmer
                                  ? AppColors.forestGreen
                                  : AppColors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.agriculture_rounded,
                                color: _selectedRole == AppStrings.roleFarmer
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.roleFarmer,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == AppStrings.roleFarmer
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = AppStrings.roleCommunityMember),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == AppStrings.roleCommunityMember
                                ? AppColors.forestGreen
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == AppStrings.roleCommunityMember
                                  ? AppColors.forestGreen
                                  : AppColors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.groups_rounded,
                                color: _selectedRole == AppStrings.roleCommunityMember
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Community',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == AppStrings.roleCommunityMember
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Full Name
                CustomTextField(
                  controller: _nameController,
                  label: AppStrings.fullNameLabel,
                  hint: 'e.g. Ramesh Patil',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (val) => Validators.validateRequired(val, 'Full Name'),
                ),
                const SizedBox(height: 14),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  hint: 'e.g. ramesh@farm.org',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 14),

                // Phone
                CustomTextField(
                  controller: _phoneController,
                  label: AppStrings.phoneLabel,
                  hint: '10-digit mobile number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 14),

                // City / Village & State (Responsive 2-column or 1-column)
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _cityController,
                        label: AppStrings.cityVillageLabel,
                        hint: 'e.g. Baramati',
                        prefixIcon: Icons.location_city_outlined,
                        validator: (val) => Validators.validateRequired(val, 'Village/City'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _stateController,
                        label: AppStrings.stateLabel,
                        hint: 'e.g. Maharashtra',
                        prefixIcon: Icons.map_outlined,
                        validator: (val) => Validators.validateRequired(val, 'State'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: AppStrings.passwordLabel,
                  hint: 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 14),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPasswordLabel,
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (val) => Validators.validateConfirmPassword(val, _passwordController.text),
                ),
                const SizedBox(height: 24),

                // Register Button
                CustomButton(
                  text: 'Create Account',
                  isLoading: auth.isLoading,
                  onPressed: _handleRegister,
                  icon: Icons.person_add_rounded,
                ),
                const SizedBox(height: 18),

                // Back to Login
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
