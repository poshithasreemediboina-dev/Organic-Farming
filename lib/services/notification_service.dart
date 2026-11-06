import '../models/notification_model.dart';
import 'database_service.dart';

class NotificationService {
  final DatabaseService _db = DatabaseService();

  List<NotificationModel> getNotificationsForUser(String userId) {
    return _db.getNotificationsForUser(userId);
  }

  int getUnreadCount(String userId) {
    return _db.getUnreadNotificationCount(userId);
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _db.markAllNotificationsAsRead(userId);
  }

  Future<void> sendComplaintStatusNotification({
    required String userId,
    required String complaintId,
    required String status,
    required String category,
    String? remarks,
  }) async {
    String title;
    String message;
    String type;

    if (status == 'Resolved') {
      title = 'Complaint Resolved!';
      message = 'Your complaint #$complaintId regarding $category has been successfully resolved by the administration.';
      type = 'complaint_resolved';
    } else if (status == 'In Progress') {
      title = 'Complaint In Progress';
      message = 'Your complaint #$complaintId is now under active investigation: ${remarks ?? "Action initiated."}';
      type = 'complaint_in_progress';
    } else {
      title = 'Complaint Update';
      message = 'Complaint #$complaintId has been updated: ${remarks ?? status}';
      type = 'complaint_status';
    }

    final notif = NotificationModel(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      complaintId: complaintId,
      title: title,
      message: message,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _db.addNotification(notif);
  }
}
