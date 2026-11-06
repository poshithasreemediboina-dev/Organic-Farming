import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCategory = AppStrings.complaintCategories.first;
  bool _imageAttached = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        if (_locationController.text.isEmpty && user.city.isNotEmpty) {
          _locationController.text = '${user.city}, ${user.state}';
        }
        if (_phoneController.text.isEmpty && user.phone.isNotEmpty) {
          _phoneController.text = user.phone;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cropNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final complaintProv = Provider.of<ComplaintProvider>(context, listen: false);
    final user = auth.currentUser;

    final createdComplaint = await complaintProv.submitComplaint(
      userId: user?.id ?? 'usr_farmer_guest',
      userName: user?.name ?? 'Organic Farmer',
      userPhone: _phoneController.text.trim(),
      title: _titleController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      location: _locationController.text,
      cropName: _cropNameController.text.trim().isNotEmpty ? _cropNameController.text.trim() : null,
      imageUrl: _imageAttached ? 'sample_complaint_image' : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (createdComplaint != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.statusResolved, size: 28),
              SizedBox(width: 10),
              Text('Grievance Registered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your complaint has been logged with ID #${createdComplaint.complaintId}.',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Our agricultural officer has been notified. You can track real-time resolution updates in My Complaints.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.complaintDetails,
                  arguments: createdComplaint.complaintId,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
              child: const Text('Track Complaint Now'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(complaintProv.errorMessage ?? 'Failed to submit grievance.'),
          backgroundColor: AppColors.coral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Farmer Grievance Registration'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.freshLeafGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: AppColors.forestGreen, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Direct Agricultural Support: Official administration officers review all grievances and provide field interventions.',
                          style: TextStyle(fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Complaint Category Dropdown
                const Text(
                  'Complaint Category *',
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
                      items: AppStrings.complaintCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Complaint Title
                CustomTextField(
                  controller: _titleController,
                  label: 'Complaint Title *',
                  hint: 'e.g. Sub-canal water valve locked in Block 4',
                  prefixIcon: Icons.title_rounded,
                  validator: (val) => Validators.validateRequired(val, 'Complaint Title'),
                ),
                const SizedBox(height: 16),

                // Affected Crop Name (Optional)
                CustomTextField(
                  controller: _cropNameController,
                  label: 'Affected Crop (Optional)',
                  hint: 'e.g. Organic Soybean, Sweet Corn, Pomegranate',
                  prefixIcon: Icons.grass_rounded,
                ),
                const SizedBox(height: 16),

                // Location / Village
                CustomTextField(
                  controller: _locationController,
                  label: 'Farm Location / Village / Survey No. *',
                  hint: 'e.g. Plot 12, East Canal Bank, Baramati',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) => Validators.validateRequired(val, 'Location'),
                ),
                const SizedBox(height: 16),

                // Contact Number
                CustomTextField(
                  controller: _phoneController,
                  label: 'Contact Number for Field Officer *',
                  hint: '10-digit mobile number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),

                // Detailed Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Detailed Description of Issue *',
                  hint: 'Describe how long the issue has persisted, acreage affected, and any emergency actions taken...',
                  maxLines: 5,
                  validator: (val) => Validators.validateRequired(val, 'Description'),
                ),
                const SizedBox(height: 16),

                // Image Upload Toggle / Attachment Simulation
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
                          _imageAttached ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                          color: _imageAttached ? AppColors.forestGreen : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _imageAttached ? 'Field Damage Evidence Attached' : 'Attach Field Photo Evidence (Optional)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: _imageAttached ? AppColors.forestGreen : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _imageAttached ? 'Tap to remove attachment' : 'Photos help officers prioritize urgent crop risks',
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
                  text: 'Submit Official Grievance',
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                  icon: Icons.send_rounded,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
