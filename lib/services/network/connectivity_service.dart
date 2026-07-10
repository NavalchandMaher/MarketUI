import 'package:connectivity_plus/connectivity_plus.dart';

/// ===============================================================
/// Connectivity Service
/// Detects network availability and connection changes
/// ===============================================================

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  List<Function(bool)> _listeners = [];

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      // Notify listeners only if status changed
      if (wasOnline != _isOnline) {
        print(
          '[CONNECTIVITY] Status changed: ${_isOnline ? 'Online' : 'Offline'}',
        );
        _notifyListeners();
      }
    });
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      return _isOnline;
    } catch (e) {
      print('[CONNECTIVITY] Error checking connectivity: $e');
      return true; // Assume online if error
    }
  }

  /// Add listener for connectivity changes
  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_isOnline);
    }
  }

  /// Clear all listeners
  void clearListeners() {
    _listeners.clear();
  }

  /// Dispose (cleanup)
  void dispose() {
    clearListeners();
  }
}
