class ComplaintModel {
  final String complaintId; // e.g. GC1025
  final String userId;
  final String userName;
  final String userPhone;
  final String title;
  final String category;
  final String description;
  final String location;
  final String? cropName;
  final String? imageUrl;
  final String status; // 'Pending', 'In Progress', 'Resolved', 'Rejected'
  final String? adminRemarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const ComplaintModel({
    required this.complaintId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    this.cropName,
    this.imageUrl,
    this.status = 'Pending',
    this.adminRemarks,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  bool get isPending => status == 'Pending';
  bool get isInProgress => status == 'In Progress';
  bool get isResolved => status == 'Resolved';
  bool get isRejected => status == 'Rejected';

  Map<String, dynamic> toJson() {
    return {
      'complaintId': complaintId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'cropName': cropName,
      'imageUrl': imageUrl,
      'status': status,
      'adminRemarks': adminRemarks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      complaintId: json['complaintId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Farmer',
      userPhone: json['userPhone'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Other Agricultural Problems',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      cropName: json['cropName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'Pending',
      adminRemarks: json['adminRemarks'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'] as String)
          : null,
    );
  }

  ComplaintModel copyWith({
    String? complaintId,
    String? userId,
    String? userName,
    String? userPhone,
    String? title,
    String? category,
    String? description,
    String? location,
    String? cropName,
    String? imageUrl,
    String? status,
    String? adminRemarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return ComplaintModel(
      complaintId: complaintId ?? this.complaintId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      cropName: cropName ?? this.cropName,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
