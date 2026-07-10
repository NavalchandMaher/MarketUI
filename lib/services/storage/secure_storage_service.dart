import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ===============================================================
/// Secure Storage Service
/// Wrapper around flutter_secure_storage for token management
/// Falls back to SharedPreferences for Flutter Web
/// ===============================================================

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> initialize() async {
    // On Web, use SharedPreferences instead of flutter_secure_storage
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
      _log("[STORAGE] Initialized with SharedPreferences (Web platform)");
    } else {
      _log("[STORAGE] Initialized with FlutterSecureStorage (Native platform)");
    }
  }

  // Platform detection
  bool get _isWeb => kIsWeb;

  // Platform-specific storage getter
  Future<String?> _read(String key) async {
    if (_isWeb && _prefs != null) {
      return _prefs!.getString(key);
    } else {
      return await _storage.read(key: key);
    }
  }

  // Platform-specific storage setter
  Future<void> _write(String key, String value) async {
    if (_isWeb && _prefs != null) {
      await _prefs!.setString(key, value);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  // Platform-specific storage delete
  Future<void> _delete(String key) async {
    if (_isWeb && _prefs != null) {
      await _prefs!.remove(key);
    } else {
      await _storage.delete(key: key);
    }
  }

  // Access Token
  Future<String?> getAccessToken() async {
    try {
      _log(
        "[STORAGE] Reading AccessToken from ${_isWeb ? 'SharedPreferences' : 'SecureStorage'}...",
      );
      final token = await _read(_accessTokenKey);
      if (token != null) {
        _log("[STORAGE] ✓ AccessToken loaded: ${_tokenPreview(token)}");
      } else {
        _log("[STORAGE] ✗ AccessToken is NULL");
      }
      return token;
    } catch (e) {
      _log("[STORAGE] ✗ CRITICAL Error reading access token: $e");
      return null;
    }
  }

  Future<void> saveAccessToken(String token) async {
    try {
      _log("[STORAGE] Saving AccessToken: ${_tokenPreview(token)}");
      await _write(_accessTokenKey, token);
      _log("[STORAGE] ✓ Successfully saved AccessToken");
    } catch (e) {
      _log("[STORAGE] ✗ CRITICAL Error saving access token: $e");
    }
  }

  // Refresh Token
  Future<String?> getRefreshToken() async {
    try {
      _log(
        "[STORAGE] Reading RefreshToken from ${_isWeb ? 'SharedPreferences' : 'SecureStorage'}...",
      );
      final token = await _read(_refreshTokenKey);
      if (token != null) {
        _log("[STORAGE] ✓ RefreshToken loaded: ${_tokenPreview(token)}");
      } else {
        _log("[STORAGE] ✗ RefreshToken is NULL");
      }
      return token;
    } catch (e) {
      _log("[STORAGE] ✗ CRITICAL Error reading refresh token: $e");
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      _log("[STORAGE] Saving RefreshToken: ${_tokenPreview(token)}");
      await _write(_refreshTokenKey, token);
      _log("[STORAGE] ✓ Successfully saved RefreshToken");
    } catch (e) {
      _log("[STORAGE] ✗ CRITICAL Error saving refresh token: $e");
    }
  }

  // Helper: Token preview (first 20 chars + "...")
  String _tokenPreview(String? token) {
    if (token == null) return "NULL";
    if (token.length <= 20) return token;
    return "${token.substring(0, 20)}...";
  }

  // Helper: Logging with timestamp
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().split('T')[1];
    print("$timestamp $message");
  }

  // Clear all tokens
  Future<void> clearTokens() async {
    try {
      _log("[STORAGE] Clearing all tokens...");
      await Future.wait([_delete(_accessTokenKey), _delete(_refreshTokenKey)]);
      _log("[STORAGE] ✓ Successfully cleared all tokens");
    } catch (e) {
      _log('[STORAGE] ✗ Error clearing tokens: $e');
    }
  }

  // Generic get/set for future extensibility
  Future<String?> read(String key) async {
    try {
      _log("[STORAGE] Reading key: $key");
      final value = await _read(key);
      if (value != null) {
        _log("[STORAGE] ✓ Read $key: ${_tokenPreview(value)}");
      } else {
        _log("[STORAGE] ✗ Key $key is NULL");
      }
      return value;
    } catch (e) {
      _log('[STORAGE] ✗ Error reading $key: $e');
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    try {
      _log("[STORAGE] Writing key: $key with value: ${_tokenPreview(value)}");
      await _write(key, value);
      _log("[STORAGE] ✓ Successfully wrote $key");
    } catch (e) {
      _log('[STORAGE] ✗ Error writing $key: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      _log("[STORAGE] Deleting key: $key");
      await _delete(key);
      _log("[STORAGE] ✓ Successfully deleted $key");
    } catch (e) {
      _log('[STORAGE] ✗ Error deleting $key: $e');
    }
  }
}
