import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';

class NotificationProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    await _db.initialize();
    _notifications = _db.getNotificationsForUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.markNotificationAsRead(notificationId);
    final idx = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await _db.markAllNotificationsAsRead(userId);
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void refreshFromDatabase(String userId) {
    _notifications = _db.getNotificationsForUser(userId);
    notifyListeners();
  }
}
