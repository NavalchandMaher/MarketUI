import 'package:get_it/get_it.dart';

import 'services/api/auth_service.dart';
import 'services/api/v3_api_service.dart';
import 'services/storage/secure_storage_service.dart';
import 'services/network/connectivity_service.dart';
import 'services/storage/cache_service.dart';
import 'services/public_api_service.dart';
import 'state/account_provider.dart';
import 'state/settings_provider.dart';
import 'state/strategies_provider.dart';
import 'state/paper_trading_provider.dart';
import 'state/reports_provider.dart';
import 'state/backtesting_provider.dart';
import 'state/learning_logs_provider.dart';
import 'state/backtest_provider.dart';
import 'state/scheduler_provider.dart';

/// ===============================================================
/// Service Locator - Dependency Injection Setup
/// ===============================================================

final getIt = GetIt.instance;

/// Initialize all services
Future<void> setupServiceLocator() async {
  // Storage Services
  final secureStorage = SecureStorageService();
  await secureStorage.initialize();
  getIt.registerSingleton<SecureStorageService>(secureStorage);

  final cacheService = CacheService();
  await cacheService.initialize();
  getIt.registerSingleton<CacheService>(cacheService);

  // Network Services
  final connectivityService = ConnectivityService();
  getIt.registerSingleton<ConnectivityService>(connectivityService);

  // API Services
  final authService = AuthService(storage: secureStorage);
  await authService.initialize();
  getIt.registerSingleton<AuthService>(authService);

  final v3ApiService = V3ApiService(
    authService: authService,
    cacheService: cacheService,
    connectivityService: connectivityService,
  );
  getIt.registerSingleton<V3ApiService>(v3ApiService);

  final publicApiService = PublicApiService();
  getIt.registerSingleton<PublicApiService>(publicApiService);

  // State Providers
  getIt.registerSingleton<AccountProvider>(AccountProvider());
  getIt.registerSingleton<SettingsProvider>(SettingsProvider());
  getIt.registerSingleton<StrategiesProvider>(StrategiesProvider());
  getIt.registerSingleton<PaperTradingProvider>(PaperTradingProvider());
  getIt.registerSingleton<ReportsProvider>(ReportsProvider());
  getIt.registerSingleton<BacktestingProvider>(BacktestingProvider());
  getIt.registerSingleton<LearningLogsProvider>(LearningLogsProvider());
  getIt.registerSingleton<BacktestProvider>(BacktestProvider());
  getIt.registerSingleton<SchedulerProvider>(SchedulerProvider());
}

/// Reset service locator (useful for testing)
void resetServiceLocator() {
  getIt.reset();
}
