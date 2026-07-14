import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Public API Service - Caches public data (symbols, timeframes)
/// ===============================================================
class PublicApiService {
  late final V3ApiService _api;

  List<dynamic> _cachedSymbols = [];
  List<dynamic> _cachedTimeframes = [];
  DateTime? _symbolsCachedAt;
  DateTime? _timeframesCachedAt;

  PublicApiService() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Get Symbols (1 hour TTL)
  // ============================================================

  Future<List<dynamic>> getSymbols({bool forceRefresh = false}) async {
    // Check if cache is still valid (1 hour = 3600 seconds)
    if (!forceRefresh &&
        _cachedSymbols.isNotEmpty &&
        _symbolsCachedAt != null) {
      final age = DateTime.now().difference(_symbolsCachedAt!).inSeconds;
      if (age < 3600) {
        print('[PUBLIC_API] Returning cached symbols (age: $age s)');
        return _cachedSymbols;
      }
    }

    try {
      print('[PUBLIC_API] Fetching fresh symbols...');
      _cachedSymbols =
          await _api.getRequest(
                '/public/symbols',
                cacheTtl: 3600,
                requireAuth: false,
              )
              as List<dynamic>? ??
          [];
      _symbolsCachedAt = DateTime.now();
      print('[PUBLIC_API] Cached ${_cachedSymbols.length} symbols');
      return _cachedSymbols;
    } catch (e) {
      print('[PUBLIC_API] Error fetching symbols: $e');
      // Return cached data as fallback even if expired
      return _cachedSymbols;
    }
  }

  // ============================================================
  // Get Timeframes (1 hour TTL)
  // ============================================================

  Future<List<dynamic>> getTimeframes({bool forceRefresh = false}) async {
    // Check if cache is still valid (1 hour = 3600 seconds)
    if (!forceRefresh &&
        _cachedTimeframes.isNotEmpty &&
        _timeframesCachedAt != null) {
      final age = DateTime.now().difference(_timeframesCachedAt!).inSeconds;
      if (age < 3600) {
        print('[PUBLIC_API] Returning cached timeframes (age: $age s)');
        return _cachedTimeframes;
      }
    }

    try {
      print('[PUBLIC_API] Fetching fresh timeframes...');
      _cachedTimeframes =
          await _api.getRequest(
                '/public/timeframes',
                cacheTtl: 3600,
                requireAuth: false,
              )
              as List<dynamic>? ??
          [];
      _timeframesCachedAt = DateTime.now();
      print('[PUBLIC_API] Cached ${_cachedTimeframes.length} timeframes');
      return _cachedTimeframes;
    } catch (e) {
      print('[PUBLIC_API] Error fetching timeframes: $e');
      // Return cached data as fallback even if expired
      return _cachedTimeframes;
    }
  }

  // ============================================================
  // Get Market Info (Combined symbols and timeframes)
  // ============================================================

  Future<Map<String, dynamic>> getMarketInfo({
    bool forceRefresh = false,
  }) async {
    try {
      final results = await Future.wait([
        getSymbols(forceRefresh: forceRefresh),
        getTimeframes(forceRefresh: forceRefresh),
      ]);

      return {
        'symbols': results[0] as List<dynamic>,
        'timeframes': results[1] as List<dynamic>,
      };
    } catch (e) {
      print('[PUBLIC_API] Error fetching market info: $e');
      return {'symbols': _cachedSymbols, 'timeframes': _cachedTimeframes};
    }
  }

  // ============================================================
  // Clear Cache
  // ============================================================

  void clearCache() {
    _cachedSymbols = [];
    _cachedTimeframes = [];
    _symbolsCachedAt = null;
    _timeframesCachedAt = null;
    print('[PUBLIC_API] Cache cleared');
  }

  // ============================================================
  // Cache Stats
  // ============================================================

  Map<String, dynamic> getCacheStats() {
    return {
      'symbols_cached': _cachedSymbols.length,
      'timeframes_cached': _cachedTimeframes.length,
      'symbols_age_seconds': _symbolsCachedAt != null
          ? DateTime.now().difference(_symbolsCachedAt!).inSeconds
          : null,
      'timeframes_age_seconds': _timeframesCachedAt != null
          ? DateTime.now().difference(_timeframesCachedAt!).inSeconds
          : null,
    };
  }
}
