import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Organic Vegetables';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final productProv = Provider.of<ProductProvider>(context, listen: false);

    final user = auth.currentUser;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    await productProv.addProduct(
      sellerId: user?.id ?? 'usr_guest',
      sellerName: user?.name ?? 'Organic Farmer',
      sellerPhone: user?.phone ?? '9876543210',
      sellerLocation: user != null ? '${user.city}, ${user.state}' : 'Maharashtra',
      name: _nameController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      price: price,
      unit: _unitController.text,
      imageUrl: null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product listed in the Organic Marketplace!'),
        backgroundColor: AppColors.statusResolved,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppStrings.productCategories.where((c) => c != 'All Categories').toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('List Farm Product'),
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
                  'Connect directly with buyers and fellow farmers without middleman commissions.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                const Text(
                  'Product Category',
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

                // Product Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Product Name / Produce Variety',
                  hint: 'e.g. Fresh Organic Shimla Mirch (Bell Pepper)',
                  prefixIcon: Icons.eco_rounded,
                  validator: (val) => Validators.validateRequired(val, 'Product Name'),
                ),
                const SizedBox(height: 16),

                // Price and Unit
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: _priceController,
                        label: 'Price in INR (₹)',
                        hint: 'e.g. 120',
                        prefixIcon: Icons.currency_rupee_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.validatePrice,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _unitController,
                        label: 'Unit / Measure',
                        hint: 'e.g. kg, 5 kg bag',
                        prefixIcon: Icons.scale_rounded,
                        validator: (val) => Validators.validateRequired(val, 'Unit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description & Organic Certification Details',
                  hint: 'Mention harvest date, soil origin, indigenous variety specs, or pesticide-free certification...',
                  maxLines: 4,
                  validator: (val) => Validators.validateRequired(val, 'Description'),
                ),
                const SizedBox(height: 28),

                // Submit Button
                CustomButton(
                  text: 'Publish Product Listing',
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                  icon: Icons.add_business_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
