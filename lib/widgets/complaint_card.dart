import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import 'status_badge.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;
  final bool showFarmerName;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
    this.showFarmerName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor, width: 0.8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: ID and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${complaint.complaintId}',
                      style: const TextStyle(
                        color: AppColors.forestGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  StatusBadge(status: complaint.status),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                complaint.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Category Chip & Location
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 14, color: AppColors.freshLeafGreen),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      complaint.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.forestGreen,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.earthBrown),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      complaint.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Farmer name if Admin view
              if (showFarmerName) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Farmer: ${complaint.userName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],

              // Admin remarks highlight if present
              if (complaint.adminRemarks != null && complaint.adminRemarks!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.freshLeafGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.admin_panel_settings_outlined, size: 14, color: AppColors.forestGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Admin remark: ${complaint.adminRemarks}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.forestGreen,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 16, thickness: 0.7),

              // Footer: Date and Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.timeAgo(complaint.createdAt),
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        'Track Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.forestGreen),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
