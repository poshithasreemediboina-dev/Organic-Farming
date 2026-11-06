import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/community_model.dart';
import '../services/database_service.dart';

class CommunityProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<CommunityPostModel> _posts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All Posts';
  String _searchQuery = '';

  List<CommunityPostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<CommunityPostModel> get filteredPosts {
    return _posts.where((p) {
      final matchesCategory = _selectedCategory == 'All Posts' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.userName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    await _db.initialize();
    _posts = _db.getCommunityPosts();

    _isLoading = false;
    notifyListeners();
  }

  Future<CommunityPostModel> createPost({
    required String userId,
    required String userName,
    required String userRole,
    required String userLocation,
    required String title,
    required String content,
    required String category,
    String? imageUrl,
  }) async {
    final newPost = CommunityPostModel(
      id: 'post_${const Uuid().v4().substring(0, 8)}',
      userId: userId,
      userName: userName,
      userRole: userRole,
      userLocation: userLocation,
      title: title.trim(),
      content: content.trim(),
      category: category,
      imageUrl: imageUrl,
      likes: 0,
      likedUserIds: const [],
      comments: const [],
      createdAt: DateTime.now(),
    );

    final created = await _db.addCommunityPost(newPost);
    _posts.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<void> toggleLike(String postId, String userId) async {
    await _db.togglePostLike(postId, userId);
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _posts[idx];
      final liked = List<String>.from(p.likedUserIds);
      int likes = p.likes;
      if (liked.contains(userId)) {
        liked.remove(userId);
        likes = (likes > 0) ? likes - 1 : 0;
      } else {
        liked.add(userId);
        likes += 1;
      }
      _posts[idx] = p.copyWith(likes: likes, likedUserIds: liked);
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userRole,
    required String content,
  }) async {
    final comment = CommentModel(
      id: 'c_${const Uuid().v4().substring(0, 8)}',
      userId: userId,
      userName: userName,
      userRole: userRole,
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    await _db.addPostComment(postId, comment);
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _posts[idx];
      final comments = List<CommentModel>.from(p.comments)..add(comment);
      _posts[idx] = p.copyWith(comments: comments);
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    await _db.deleteCommunityPost(postId);
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}
