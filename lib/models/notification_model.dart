class NotificationModel {
  final String notificationId;
  final String userId;
  final String? complaintId;
  final String title;
  final String message;
  final String type; // 'complaint_submitted', 'complaint_in_progress', 'complaint_resolved', 'admin_response', 'community'
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    this.complaintId,
    required this.title,
    required this.message,
    this.type = 'complaint_status',
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'complaintId': complaintId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      complaintId: json['complaintId'] as String?,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'complaint_status',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? complaintId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      complaintId: complaintId ?? this.complaintId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
