import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// ===============================================================
/// Auth State - Manages authentication state
/// ===============================================================
class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================
  // Getters
  // ============================================================

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get userName => _currentUser?['full_name'] ?? 'User';
  String get userEmail => _currentUser?['email'] ?? '';
  String get userRole => _currentUser?['role'] ?? 'Trader';

  // ============================================================
  // Initialize
  // ============================================================

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.initialize();

      if (isAuthenticated) {
        await _loadCurrentUser();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Current User
  // ============================================================

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // ============================================================
  // Register
  // ============================================================

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Login
  // ============================================================

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      await _loadCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Change Password
  // ============================================================

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Forgot Password
  // ============================================================

  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
