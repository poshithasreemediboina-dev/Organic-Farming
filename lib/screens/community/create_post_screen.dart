import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Crop Management';
  bool _imageAttached = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final communityProv = Provider.of<CommunityProvider>(context, listen: false);

    final user = auth.currentUser;
    await communityProv.createPost(
      userId: user?.id ?? 'usr_guest',
      userName: user?.name ?? 'Organic Farmer',
      userRole: user?.role ?? 'Farmer',
      userLocation: user != null ? '${user.city}, ${user.state}' : 'Maharashtra',
      title: _titleController.text,
      content: _contentController.text,
      category: _selectedCategory,
      imageUrl: _imageAttached ? 'post_image_mock' : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your organic farming experience has been published!'),
        backgroundColor: AppColors.statusResolved,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppStrings.communityCategories.where((c) => c != 'All Posts').toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Share Farming Experience'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inspire fellow growers with your field experiments, recipes, and bio-control methods.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                // Category Dropdown
                const Text(
                  'Topic Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorder, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.forestGreen),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Post Title
                CustomTextField(
                  controller: _titleController,
                  label: 'Post Title / Question',
                  hint: 'e.g. Natural aphid control using garlic-chilli extract',
                  prefixIcon: Icons.title_rounded,
                  validator: (val) => Validators.validateRequired(val, 'Post Title'),
                ),
                const SizedBox(height: 16),

                // Post Content
                CustomTextField(
                  controller: _contentController,
                  label: 'Detailed Experience & Steps',
                  hint: 'Explain your preparation ratio, dosage, observed results, and tips for best efficacy...',
                  maxLines: 6,
                  validator: (val) => Validators.validateRequired(val, 'Content'),
                ),
                const SizedBox(height: 16),

                // Image Upload Toggle Simulation
                InkWell(
                  onTap: () {
                    setState(() {
                      _imageAttached = !_imageAttached;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _imageAttached ? AppColors.mintGreen.withOpacity(0.2) : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _imageAttached ? AppColors.forestGreen : AppColors.inputBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _imageAttached ? Icons.check_circle_rounded : Icons.add_photo_alternate_outlined,
                          color: _imageAttached ? AppColors.forestGreen : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _imageAttached ? 'Field Photo Attached (Sample)' : 'Attach Field Photo (Optional)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: _imageAttached ? AppColors.forestGreen : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _imageAttached ? 'Tap to remove' : 'Share clear photos of your crops or formulation',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                CustomButton(
                  text: 'Publish to Community',
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                  icon: Icons.send_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
