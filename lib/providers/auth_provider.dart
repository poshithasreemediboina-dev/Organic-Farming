import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isAuthenticated => _currentUser != null;
  bool get isFarmer => _currentUser?.isFarmer ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isCommunityMember => _currentUser?.isCommunityMember ?? false;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    try {
      final savedUser = await _authService.loadSavedUser();
      _currentUser = savedUser;
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String city,
    required String state,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
        city: city,
        state: state,
        profileImageUrl: profileImageUrl,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to register account: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Helper to instantly switch or log in with demo accounts for quick testing
  Future<bool> quickDemoLogin({required bool asAdmin}) async {
    if (asAdmin) {
      return await login(
        email: AppConstants.demoAdminEmail,
        password: AppConstants.demoAdminPassword,
      );
    } else {
      return await login(
        email: AppConstants.demoFarmerEmail,
        password: AppConstants.demoFarmerPassword,
      );
    }
  }
}
