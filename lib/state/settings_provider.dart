import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Settings Provider - Manages user settings
/// ===============================================================
class SettingsProvider extends ChangeNotifier {
  late final V3ApiService _api;

  SettingsModel? _settings;
  bool _isLoading = false;
  String? _errorMessage;

  SettingsProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  SettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get emailNotifications => _settings?.emailNotifications ?? true;
  bool get autoTradingEnabled => _settings?.autoTradingEnabled ?? false;
  String get theme => _settings?.theme ?? 'system';
  int get riskLevel => _settings?.riskLevel ?? 2;

  // ============================================================
  // Load Settings
  // ============================================================

  Future<void> loadSettings({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final json = await _api.getSettings();
      _settings = SettingsModel.fromJson(json);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[SETTINGS] Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Update Settings
  // ============================================================

  Future<bool> updateSettings({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? theme,
    String? language,
    int? riskLevel,
    double? maxPositionSize,
    double? maxDailyLoss,
    bool? autoTradingEnabled,
  }) async {
    if (_settings == null) {
      _errorMessage = 'No settings loaded';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updateData = <String, dynamic>{
        if (notificationsEnabled != null)
          'notifications_enabled': notificationsEnabled,
        if (emailNotifications != null)
          'email_notifications': emailNotifications,
        if (pushNotifications != null) 'push_notifications': pushNotifications,
        if (theme != null) 'theme': theme,
        if (language != null) 'language': language,
        if (riskLevel != null) 'risk_level': riskLevel,
        if (maxPositionSize != null) 'max_position_size': maxPositionSize,
        if (maxDailyLoss != null) 'max_daily_loss': maxDailyLoss,
        if (autoTradingEnabled != null)
          'auto_trading_enabled': autoTradingEnabled,
      };

      final updated = await _api.updateSettings(updateData);

      _settings = SettingsModel.fromJson(updated);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[SETTINGS] Error updating settings: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Update Notifications
  // ============================================================

  Future<bool> updateNotifications({
    required bool enabled,
    bool? emailEnabled,
    bool? pushEnabled,
  }) async {
    return updateSettings(
      notificationsEnabled: enabled,
      emailNotifications: emailEnabled,
      pushNotifications: pushEnabled,
    );
  }

  // ============================================================
  // Update Theme
  // ============================================================

  Future<bool> updateTheme(String newTheme) async {
    return updateSettings(theme: newTheme);
  }

  // ============================================================
  // Update Risk Level
  // ============================================================

  Future<bool> updateRiskLevel(int level) async {
    return updateSettings(riskLevel: level);
  }

  // ============================================================
  // Toggle Auto Trading
  // ============================================================

  Future<bool> toggleAutoTrading({required bool enabled}) async {
    return updateSettings(autoTradingEnabled: enabled);
  }

  // ============================================================
  // Refresh Settings
  // ============================================================

  Future<void> refresh() async {
    await loadSettings(forceRefresh: true);
  }

  // ============================================================
  // Clear
  // ============================================================

  void clear() {
    _settings = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
