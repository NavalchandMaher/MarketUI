import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../config.dart';
import '../storage/secure_storage_service.dart';

/// ===============================================================
/// Auth Service - Handles JWT Authentication
/// ===============================================================
class AuthService {
  static AuthService? _instance;

  // Support both singleton and dependency injection patterns
  factory AuthService({SecureStorageService? storage}) {
    // CRITICAL: Always return the singleton if it exists
    if (_instance != null) {
      return _instance!;
    }

    // Create the singleton on first call
    final effectiveStorage = storage ?? SecureStorageService();
    _instance = AuthService._(effectiveStorage);
    return _instance!;
  }

  AuthService._(this._storageService);

  final SecureStorageService _storageService;
  final http.Client _client = http.Client();
  bool _isInitialized = false;

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Map<String, String> get _authHeaders => {
    ..._headers,
    if (_accessToken != null) "Authorization": "Bearer $_accessToken",
  };

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _currentUser;

  // ============================================================
  // Getters
  // ============================================================

  String? get accessToken {
    final token = _accessToken;
    _log(
      "[DEBUG] accessToken getter called - isInitialized: $_isInitialized, token: ${token != null ? token.substring(0, min(20, token.length)) + '...' : 'NULL'}",
    );
    return token;
  }

  String? get refreshToken {
    final token = _refreshToken;
    _log(
      "[DEBUG] refreshToken getter called - token: ${token != null ? token.substring(0, min(20, token.length)) + '...' : 'NULL'}",
    );
    return token;
  }

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get hasRefreshToken =>
      _refreshToken != null && _refreshToken!.isNotEmpty;
  bool get isInitialized => _isInitialized;

  // ============================================================
  // Ensure authentication before protected requests
  // ============================================================

  Future<bool> ensureAuthenticated({bool allowRefresh = true}) async {
    if (isAuthenticated) {
      return true;
    }

    if (!allowRefresh || !hasRefreshToken) {
      _log(
        "[AUTH] Unable to restore authenticated session: no access token and no refresh token available.",
      );
      return false;
    }

    _log(
      "[AUTH] No access token in memory; attempting session restore with refresh token...",
    );
    try {
      await refreshAccessToken();
      if (isAuthenticated) {
        _log("[AUTH] Session restored successfully from refresh token.");
        return true;
      }
      _log("[AUTH] Session restore completed but access token still missing.");
      return false;
    } catch (e) {
      _log("[AUTH] Session restore failed: $e");
      return false;
    }
  }

  // ============================================================
  // Initialize - Load tokens from secure storage
  // ============================================================

  Future<void> initialize() async {
    _log("=== AuthService.initialize() START ===");
    _log("[DEBUG] Ensuring storage is initialized...");

    try {
      await _storageService.initialize();

      _log("[DEBUG] Calling secureStorage.getAccessToken()...");
      _accessToken = await _storageService.getAccessToken();
      _log(
        "[DEBUG] getAccessToken() returned: ${_accessToken != null ? _accessToken!.substring(0, min(20, _accessToken!.length)) + '...' : 'NULL'}",
      );

      _log("[DEBUG] Calling secureStorage.getRefreshToken()...");
      _refreshToken = await _storageService.getRefreshToken();
      _log(
        "[DEBUG] getRefreshToken() returned: ${_refreshToken != null ? _refreshToken!.substring(0, min(20, _refreshToken!.length)) + '...' : 'NULL'}",
      );

      if (_accessToken == null && _refreshToken != null) {
        _log(
          "[DEBUG] AccessToken missing but RefreshToken exists. Attempting silent refresh...",
        );
        try {
          await refreshAccessToken();
        } catch (e) {
          _log("[DEBUG] Silent refresh failed: $e");
        }
      }

      _isInitialized = true;

      _log(
        "✓ AccessToken loaded: ${_accessToken != null ? _accessToken!.substring(0, min(20, _accessToken!.length)) + '...' : 'NULL'}",
      );
      _log(
        "✓ RefreshToken loaded: ${_refreshToken != null ? _refreshToken!.substring(0, min(20, _refreshToken!.length)) + '...' : 'NULL'}",
      );
      _log("=== AuthService.initialize() COMPLETE ===");
    } catch (e) {
      _log("✗ ERROR during initialize: $e");
      _isInitialized = false;
    }
  }

  // ============================================================
  // Register
  // ============================================================

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? mobileNumber,
    String role = 'Trader',
  }) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/auth/register");

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              "email": email,
              "password": password,
              "full_name": fullName,
              "mobile_number": mobileNumber,
              "role": role,
            }),
          )
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Registration Failed: $e");
    }
  }

  // ============================================================
  // Login
  // ============================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      _log("[DEBUG] Starting login for: $email");
      final uri = Uri.parse("${AppConfig.baseUrl}/auth/login");
      _log("[DEBUG] Posting to: $uri");

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(AppConfig.apiTimeout);

      _log("[DEBUG] Login response status: ${response.statusCode}");
      final result = _handleResponse(response);
      _log("[DEBUG] Login response parsed successfully");

      // Store tokens
      _accessToken = result["access_token"];
      _refreshToken = result["refresh_token"];
      _currentUser = result.containsKey("user") ? result["user"] : null;
      _isInitialized = true;

      _log("=== LOGIN SUCCESSFUL ===");
      _log(
        "✓ AccessToken saved in memory: ${_accessToken != null ? _accessToken!.substring(0, min(20, _accessToken!.length)) + '...' : 'NULL'}",
      );
      _log(
        "✓ RefreshToken saved in memory: ${_refreshToken != null ? _refreshToken!.substring(0, min(20, _refreshToken!.length)) + '...' : 'NULL'}",
      );
      _log("✓ User: ${_currentUser?['email'] ?? 'Unknown'}");

      _log("[DEBUG] Persisting AccessToken to storage...");
      await _storageService.saveAccessToken(_accessToken!);
      _log("[DEBUG] Persisting RefreshToken to storage...");
      await _storageService.saveRefreshToken(_refreshToken!);
      _log("✓ Tokens persisted to SecureStorage");

      return result;
    } catch (e) {
      _log("✗ LOGIN FAILED: $e");
      throw Exception("Login Failed: $e");
    }
  }

  // ============================================================
  // Refresh Token
  // ============================================================

  Future<Map<String, dynamic>> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception("No refresh token available");
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/auth/refresh");

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({"refresh_token": _refreshToken}),
          )
          .timeout(AppConfig.apiTimeout);

      final result = _handleResponse(response);

      _accessToken = result["access_token"];
      _log("=== TOKEN REFRESHED ===");
      _log(
        "New AccessToken: ${_accessToken != null ? _accessToken!.substring(0, 20) + '...' : 'NULL'}",
      );
      await _storageService.saveAccessToken(_accessToken!);
      _log("New token persisted to SecureStorage");

      return result;
    } catch (e) {
      throw Exception("Token Refresh Failed: $e");
    }
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> logout() async {
    _log("=== LOGOUT ===");
    _log(
      "Clearing AccessToken: ${_accessToken != null ? _accessToken!.substring(0, 20) + '...' : 'NULL'}",
    );
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    _isInitialized = false;

    await _storageService.clearTokens();
    _log("Tokens cleared from SecureStorage");
  }

  // ============================================================
  // Get Current User
  // ============================================================

  Future<Map<String, dynamic>> getCurrentUser() async {
    if (_accessToken == null) {
      throw Exception("Not authenticated");
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}${AppConfig.currentUser}");

      final response = await _client
          .get(uri, headers: _authHeaders)
          .timeout(AppConfig.apiTimeout);

      _currentUser = _handleResponse(response);
      return _currentUser!;
    } catch (e) {
      throw Exception("Failed to fetch current user: $e");
    }
  }

  Future<List<dynamic>> getUsers() async {
    if (!isAuthenticated) {
      throw Exception("Not authenticated");
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}${AppConfig.users}");
      final response = await _client
          .get(uri, headers: _authHeaders)
          .timeout(AppConfig.apiTimeout);

      final body = _handleResponse(response);
      if (body is List<dynamic>) {
        return body;
      }
      throw Exception("Invalid users response");
    } catch (e) {
      throw Exception("Failed to fetch users: $e");
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    if (!isAuthenticated) {
      throw Exception("Not authenticated");
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}${AppConfig.users}/$userId");
      final response = await _client
          .put(uri, headers: _authHeaders, body: jsonEncode(payload))
          .timeout(AppConfig.apiTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Failed to update user: $e");
    }
  }

  // ============================================================
  // Forgot Password
  // ============================================================

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/auth/forgot-password");

      final response = await _client
          .post(uri, headers: _headers, body: jsonEncode({"email": email}))
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Forgot Password Failed: $e");
    }
  }

  // ============================================================
  // Reset Password
  // ============================================================

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/auth/reset-password");

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({"token": token, "password": password}),
          )
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Reset Password Failed: $e");
    }
  }

  // ============================================================
  // Change Password
  // ============================================================

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_accessToken == null) {
      throw Exception("Not authenticated");
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/auth/change-password");

      final response = await _client
          .post(
            uri,
            headers: _authHeaders,
            body: jsonEncode({
              "old_password": oldPassword,
              "new_password": newPassword,
            }),
          )
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Change Password Failed: $e");
    }
  }

  // ============================================================
  // Response Handler
  // ============================================================

  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception("Empty Response");
    }

    final json = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return json;

      case 400:
        throw Exception(json["detail"] ?? "Bad Request");

      case 401:
        throw Exception(json["detail"] ?? "Unauthorized");

      case 403:
        throw Exception(json["detail"] ?? "Forbidden");

      case 404:
        throw Exception(json["detail"] ?? "Not Found");

      case 422:
        throw Exception(json["detail"] ?? "Validation Error");

      case 500:
        throw Exception(json["detail"] ?? "Internal Server Error");

      default:
        throw Exception("HTTP ${response.statusCode}");
    }
  }

  // ============================================================
  // Dispose
  // ============================================================

  void _log(String message) {
    if (AppConfig.enableLogs) {
      debugPrint("[AUTH] $message");
    }
  }

  void dispose() {
    _client.close();
  }
}
