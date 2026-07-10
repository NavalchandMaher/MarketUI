import 'package:hive_flutter/hive_flutter.dart';

/// ===============================================================
/// Cache Service
/// Hive-based local caching for API responses
/// ===============================================================

class CacheService {
  static const String _cacheBoxName = 'api_cache';

  late Box<dynamic> _cacheBox;

  bool get isInitialized => _cacheBox.isOpen;

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox<dynamic>(_cacheBoxName);
      print('[CACHE] Cache service initialized');
    } catch (e) {
      print('[CACHE] Error initializing cache: $e');
    }
  }

  /// Get cached value with TTL check
  /// Returns null if expired or not found
  T? get<T>(String key, {int ttlSeconds = 300}) {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return null;

      // Check if data has metadata (TTL)
      if (cached is Map &&
          cached.containsKey('data') &&
          cached.containsKey('timestamp')) {
        final timestamp = cached['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        final ageSeconds = (now - timestamp) ~/ 1000;

        if (ageSeconds > ttlSeconds) {
          // Expired, remove it (fire and forget)
          _cacheBox.delete(key).ignore();
          return null;
        }

        return cached['data'] as T?;
      }

      return cached as T?;
    } catch (e) {
      print('[CACHE] Error getting $key: $e');
      return null;
    }
  }

  /// Set cached value with TTL
  Future<void> set<T>(String key, T value, {int ttlSeconds = 300}) async {
    try {
      final data = {
        'data': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _cacheBox.put(key, data);
      print('[CACHE] Cached $key (TTL: ${ttlSeconds}s)');
    } catch (e) {
      print('[CACHE] Error setting $key: $e');
    }
  }

  /// Set raw value without TTL tracking
  Future<void> setRaw<T>(String key, T value) async {
    try {
      await _cacheBox.put(key, value);
      print('[CACHE] Cached $key (raw)');
    } catch (e) {
      print('[CACHE] Error setting $key: $e');
    }
  }

  /// Check if key exists and is not expired
  bool has(String key, {int ttlSeconds = 300}) {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return false;

      if (cached is Map && cached.containsKey('timestamp')) {
        final timestamp = cached['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        final ageSeconds = (now - timestamp) ~/ 1000;
        return ageSeconds <= ttlSeconds;
      }

      return true;
    } catch (e) {
      print('[CACHE] Error checking $key: $e');
      return false;
    }
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    try {
      await _cacheBox.delete(key);
      print('[CACHE] Cleared $key');
    } catch (e) {
      print('[CACHE] Error deleting $key: $e');
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    try {
      await _cacheBox.clear();
      print('[CACHE] All cache cleared');
    } catch (e) {
      print('[CACHE] Error clearing cache: $e');
    }
  }

  /// Close cache
  Future<void> close() async {
    try {
      await _cacheBox.close();
      print('[CACHE] Cache closed');
    } catch (e) {
      print('[CACHE] Error closing cache: $e');
    }
  }

  /// Get cache stats
  Map<String, dynamic> getStats() {
    return {'totalKeys': _cacheBox.length, 'isOpen': _cacheBox.isOpen};
  }
}
