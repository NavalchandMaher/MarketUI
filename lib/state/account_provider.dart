import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Account Provider - Manages account state and operations
/// ===============================================================
class AccountProvider extends ChangeNotifier {
  late final V3ApiService _api;

  AccountModel? _account;
  bool _isLoading = false;
  String? _errorMessage;

  AccountProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  AccountModel? get account => _account;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get accountStatus => _account?.accountTier ?? 'unknown';

  // ============================================================
  // Load Account
  // ============================================================

  Future<void> loadAccount({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final json = await _api.getAccount();
      _account = AccountModel.fromJson(json);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[ACCOUNT] Error loading account: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Update Account
  // ============================================================

  Future<bool> updateAccount({
    String? fullName,
    String? phone,
    String? country,
    String? brokerName,
  }) async {
    if (_account == null) {
      _errorMessage = 'No account loaded';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updateData = {
        'full_name': fullName ?? _account!.fullName,
        'phone': phone ?? _account!.phone,
        'country': country ?? _account!.country,
        'broker_name': brokerName ?? _account!.brokerName,
      };

      final updated = await _api.putRequest('/v3/account', body: updateData);

      _account = AccountModel.fromJson(updated);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[ACCOUNT] Error updating account: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Update Broker Credentials
  // ============================================================

  Future<bool> updateBrokerCredentials({
    required String brokerName,
    required String apiKey,
    required String apiSecret,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updateData = {
        'broker_name': brokerName,
        'broker_api_key': apiKey,
        'broker_api_secret': apiSecret,
      };

      final updated = await _api.putRequest('/v3/account', body: updateData);

      _account = AccountModel.fromJson(updated);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[ACCOUNT] Error updating broker credentials: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Refresh Account
  // ============================================================

  Future<void> refresh() async {
    await loadAccount(forceRefresh: true);
  }

  // ============================================================
  // Clear
  // ============================================================

  void clear() {
    _account = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
