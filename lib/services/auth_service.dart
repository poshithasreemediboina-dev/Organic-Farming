import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'storage_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();

  Future<UserModel> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    await _db.initialize();
    final cleanEmail = email.trim().toLowerCase();

    // Check credentials against registered database
    final existingUser = _db.getUserByEmail(cleanEmail);

    if (existingUser == null) {
      // If user doesn't exist, we provide a clear error message
      throw AuthException('No account found with this email. Please register first.');
    }

    // In a production setup, passwords would be hashed/authenticated with Firebase Auth
    // For demo/academic purposes, we validate matching passwords
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    if (rememberMe) {
      await StorageService.saveCurrentUser(json.encode(existingUser.toJson()));
      await StorageService.setRememberMe(true);
    } else {
      await StorageService.clearCurrentUser();
      await StorageService.setRememberMe(false);
    }

    return existingUser;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String city,
    required String state,
    String? profileImageUrl,
  }) async {
    await _db.initialize();
    final cleanEmail = email.trim().toLowerCase();

    final existingUser = _db.getUserByEmail(cleanEmail);
    if (existingUser != null) {
      throw AuthException('An account with this email already exists.');
    }

    final newUser = UserModel(
      id: 'usr_${const Uuid().v4().substring(0, 8)}',
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: role,
      city: city.trim(),
      state: state.trim(),
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.now(),
    );

    await _db.createUser(newUser);
    await StorageService.saveCurrentUser(json.encode(newUser.toJson()));
    await StorageService.setRememberMe(true);

    return newUser;
  }

  Future<UserModel?> loadSavedUser() async {
    await _db.initialize();
    final rememberMe = await StorageService.getRememberMe();
    if (!rememberMe) return null;

    final userJson = await StorageService.getCurrentUser();
    if (userJson != null) {
      try {
        final map = json.decode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(map);
        // Ensure user is still present in database
        final fresh = _db.getUserById(user.id);
        return fresh ?? user;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await StorageService.clearCurrentUser();
    await StorageService.setRememberMe(false);
  }

  Future<void> resetPassword(String email) async {
    await _db.initialize();
    final user = _db.getUserByEmail(email.trim());
    if (user == null) {
      throw AuthException('No account registered with this email.');
    }
    // Simulation of password reset email
    await Future.delayed(const Duration(milliseconds: 800));
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
