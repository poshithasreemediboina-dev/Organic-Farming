import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showContactDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.contact_phone_rounded, color: AppColors.forestGreen),
            SizedBox(width: 8),
            Text('Contact Seller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Farmer: ${product.sellerName}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppColors.forestGreen),
                const SizedBox(width: 6),
                Text('Phone: ${product.sellerPhone}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.earthBrown),
                const SizedBox(width: 6),
                Text('Location: ${product.sellerLocation}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Listed Price: ₹${product.price.toStringAsFixed(0)} per ${product.unit}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dialing ${product.sellerPhone} for ${product.name}...'),
                  backgroundColor: AppColors.forestGreen,
                ),
              );
            },
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final products = productProv.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Organic Marketplace'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Category Filters
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search vegetables, seeds, organic fertilizers...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.forestGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                productProv.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => productProv.setSearchQuery(val),
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AppStrings.productCategories.map((cat) {
                        final isSelected = productProv.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.forestGreen,
                            backgroundColor: AppColors.mintGreen.withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              productProv.setSelectedCategory(cat);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: products.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.storefront_outlined,
                      title: 'No Products In This Category',
                      subtitle: 'List your certified organic harvest or farm-made natural inputs for local buyers.',
                      buttonText: 'List Farm Product',
                      onButtonPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.addProduct);
                      },
                    )
                  : RefreshIndicator(
                      color: AppColors.forestGreen,
                      onRefresh: () => productProv.loadProducts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final canDelete = auth.isAdmin || product.sellerId == auth.currentUser?.id;

                          return ProductCard(
                            product: product,
                            canDelete: canDelete,
                            onContact: () => _showContactDialog(context, product),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Product Listing?'),
                                  content: const Text('Are you sure you want to remove this item from the market?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await productProv.deleteProduct(product.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product removed from marketplace.')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.addProduct);
        },
        backgroundColor: AppColors.forestGreen,
        icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.white),
        label: const Text(
          'Sell Produce',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
