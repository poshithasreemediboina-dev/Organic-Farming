import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case 'complaint_resolved':
        return Icons.verified_rounded;
      case 'complaint_in_progress':
        return Icons.engineering_rounded;
      case 'complaint_submitted':
        return Icons.assignment_turned_in_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case 'complaint_resolved':
        return AppColors.statusResolved;
      case 'complaint_in_progress':
        return AppColors.statusInProgress;
      case 'complaint_submitted':
        return AppColors.forestGreen;
      default:
        return AppColors.sunriseOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return Card(
      elevation: notification.isRead ? 0.5 : 2.0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: notification.isRead ? AppColors.white : AppColors.mintGreen.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: notification.isRead ? AppColors.dividerColor : color.withOpacity(0.4),
          width: notification.isRead ? 0.8 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.sunriseOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormatter.timeAgo(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
