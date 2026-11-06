import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/constants/app_colors.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onContact;
  final VoidCallback? onDelete;
  final bool canDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onContact,
    this.onDelete,
    this.canDelete = false,
  });

  IconData _getCategoryIcon() {
    switch (product.category.toLowerCase()) {
      case 'organic vegetables':
        return Icons.eco_rounded;
      case 'fruits':
        return Icons.apple_rounded;
      case 'seeds':
        return Icons.grain_rounded;
      case 'natural fertilizers':
        return Icons.compost_rounded;
      case 'organic pesticides':
        return Icons.pest_control_rounded;
      case 'farming equipment':
        return Icons.precision_manufacturing_rounded;
      default:
        return Icons.local_florist_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Icon Container
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.freshLeafGreen.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(),
                      size: 28,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.freshLeafGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDelete && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.coral),
                    onPressed: onDelete,
                    tooltip: 'Delete Product',
                  ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              product.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Price and Seller Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warmCream.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.sunriseOrange.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Direct Farm Price',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      Text(
                        '₹${product.price.toStringAsFixed(0)} / ${product.unit}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            product.sellerName,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.earthBrown),
                          const SizedBox(width: 3),
                          Text(
                            product.sellerLocation,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Contact Seller Action
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                label: const Text(
                  'Contact Farmer / Seller',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
