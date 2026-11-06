import 'dart:math';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/database_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<ComplaintModel> _allComplaints = [];
  List<ComplaintModel> _userComplaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  List<ComplaintModel> get allComplaints => _allComplaints;
  List<ComplaintModel> get userComplaints => _userComplaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;

  // Filtered complaints for admin view
  List<ComplaintModel> get filteredAdminComplaints {
    return _allComplaints.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.complaintId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesStatus = _selectedStatus == 'All' || c.status == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // Admin Dashboard Statistics
  int get totalComplaintsCount => _allComplaints.length;
  int get pendingComplaintsCount => _allComplaints.where((c) => c.status == 'Pending').length;
  int get inProgressComplaintsCount => _allComplaints.where((c) => c.status == 'In Progress').length;
  int get resolvedComplaintsCount => _allComplaints.where((c) => c.status == 'Resolved').length;
  int get rejectedComplaintsCount => _allComplaints.where((c) => c.status == 'Rejected').length;

  Map<String, int> get categoryDistribution {
    final map = <String, int>{};
    for (var c in _allComplaints) {
      map[c.category] = (map[c.category] ?? 0) + 1;
    }
    return map;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedStatus = 'All';
    notifyListeners();
  }

  Future<void> loadComplaints({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db.initialize();
      _allComplaints = _db.getAllComplaints();
      if (userId != null) {
        _userComplaints = _db.getComplaintsByUser(userId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load complaints: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ComplaintModel?> submitComplaint({
    required String userId,
    required String userName,
    required String userPhone,
    required String title,
    required String category,
    required String description,
    required String location,
    String? cropName,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Generate unique complaint ID like GC1028
      final randomNum = 1000 + Random().nextInt(9000);
      final complaintId = 'GC$randomNum';

      final complaint = ComplaintModel(
        complaintId: complaintId,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        title: title.trim(),
        category: category,
        description: description.trim(),
        location: location.trim(),
        cropName: cropName?.trim().isNotEmpty == true ? cropName!.trim() : null,
        imageUrl: imageUrl,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _db.addComplaint(complaint);
      _allComplaints.insert(0, created);
      _userComplaints.insert(0, created);

      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = 'Failed to submit complaint: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStatus({
    required String complaintId,
    required String newStatus,
    String? remarks,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _db.updateComplaintStatus(
        complaintId: complaintId,
        newStatus: newStatus,
        remarks: remarks,
      );

      final allIdx = _allComplaints.indexWhere((c) => c.complaintId == updated.complaintId);
      if (allIdx != -1) {
        _allComplaints[allIdx] = updated;
      }

      final userIdx = _userComplaints.indexWhere((c) => c.complaintId == updated.complaintId);
      if (userIdx != -1) {
        _userComplaints[userIdx] = updated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update complaint status: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  ComplaintModel? getComplaintById(String id) {
    try {
      return _allComplaints.firstWhere((c) => c.complaintId.toUpperCase() == id.trim().toUpperCase());
    } catch (_) {
      return _db.getComplaintById(id);
    }
  }
}
