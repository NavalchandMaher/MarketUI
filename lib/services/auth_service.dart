import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

/// ===============================================================
/// Auth Service - Handles JWT Authentication
/// ===============================================================
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user';

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

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null;

  // ============================================================
  // Initialize - Load tokens from secure storage
  // ============================================================

  Future<void> initialize() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);

    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      _currentUser = jsonDecode(userJson);
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
      final uri = Uri.parse("${AppConfig.baseUrl}/auth/login");

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(AppConfig.apiTimeout);

      final result = _handleResponse(response);

      // Store tokens and user
      _accessToken = result["access_token"];
      _refreshToken = result["refresh_token"];
      _currentUser = result["user"];

      await _storage.write(key: _accessTokenKey, value: _accessToken!);
      await _storage.write(key: _refreshTokenKey, value: _refreshToken!);
      await _storage.write(key: _userKey, value: jsonEncode(_currentUser));

      return result;
    } catch (e) {
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
      await _storage.write(key: _accessTokenKey, value: _accessToken!);

      return result;
    } catch (e) {
      throw Exception("Token Refresh Failed: $e");
    }
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  // ============================================================
  // Get Current User
  // ============================================================

  Future<Map<String, dynamic>> getCurrentUser() async {
    if (_accessToken == null) {
      throw Exception("Not authenticated");
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/users/me");

      final response = await _client
          .get(uri, headers: _authHeaders)
          .timeout(AppConfig.apiTimeout);

      _currentUser = _handleResponse(response);
      await _storage.write(key: _userKey, value: jsonEncode(_currentUser));

      return _currentUser!;
    } catch (e) {
      throw Exception("Failed to fetch current user: $e");
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

  Map<String, dynamic> _handleResponse(http.Response response) {
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

  void dispose() {
    _client.close();
  }
}
