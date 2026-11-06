class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userRole;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userRole,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Community Member',
      userRole: json['userRole'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CommunityPostModel {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String userLocation;
  final String? userAvatar;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final int likes;
  final List<String> likedUserIds;
  final List<CommentModel> comments;
  final DateTime createdAt;

  const CommunityPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userLocation,
    this.userAvatar,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.likes = 0,
    this.likedUserIds = const [],
    this.comments = const [],
    required this.createdAt,
  });

  bool isLikedBy(String userId) => likedUserIds.contains(userId);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'userLocation': userLocation,
      'userAvatar': userAvatar,
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'likes': likes,
      'likedUserIds': likedUserIds,
      'comments': comments.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    var rawComments = json['comments'] as List<dynamic>? ?? [];
    List<CommentModel> commentsList = rawComments
        .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
        .toList();

    var rawLiked = json['likedUserIds'] as List<dynamic>? ?? [];
    List<String> likesList = rawLiked.map((e) => e.toString()).toList();

    return CommunityPostModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Farmer',
      userRole: json['userRole'] as String? ?? 'Farmer',
      userLocation: json['userLocation'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'Crop Management',
      imageUrl: json['imageUrl'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      likedUserIds: likesList,
      comments: commentsList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CommunityPostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? userLocation,
    String? userAvatar,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    int? likes,
    List<String>? likedUserIds,
    List<CommentModel>? comments,
    DateTime? createdAt,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userLocation: userLocation ?? this.userLocation,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
