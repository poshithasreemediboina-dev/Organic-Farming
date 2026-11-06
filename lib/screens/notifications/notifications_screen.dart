import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_card.dart';
import '../../widgets/empty_state_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications(user.id);
      }
    });
  }

  void _handleNotificationTap(NotificationModel notif) {
    final notifProv = Provider.of<NotificationProvider>(context, listen: false);
    if (!notif.isRead) {
      notifProv.markAsRead(notif.notificationId);
    }

    if (notif.complaintId != null && notif.complaintId!.isNotEmpty) {
      Navigator.of(context).pushNamed(
        AppRoutes.complaintDetails,
        arguments: notif.complaintId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProv = Provider.of<NotificationProvider>(context);
    final user = auth.currentUser;
    final notifications = notifProv.notifications;
    final unreadCount = notifProv.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Notifications Center'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
        actions: [
          if (unreadCount > 0 && user != null)
            TextButton.icon(
              onPressed: () => notifProv.markAllAsRead(user.id),
              icon: const Icon(Icons.done_all_rounded, color: AppColors.white, size: 18),
              label: const Text(
                'Mark All Read',
                style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, size: 16, color: AppColors.forestGreen),
                      const SizedBox(width: 6),
                      Text(
                        unreadCount > 0 ? '$unreadCount Unread Alerts' : 'All Caught Up',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    user != null ? 'Alerts for ${user.name}' : '',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: notifications.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.notifications_none_rounded,
                      title: 'No Notifications Yet',
                      subtitle: 'You will receive real-time updates here whenever your complaints are reviewed or resolved by administration.',
                    )
                  : RefreshIndicator(
                      color: AppColors.forestGreen,
                      onRefresh: () async {
                        if (user != null) {
                          await notifProv.loadNotifications(user.id);
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return NotificationCard(
                            notification: notif,
                            onTap: () => _handleNotificationTap(notif),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
