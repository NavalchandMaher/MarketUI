import 'dart:convert';

/// ===============================================================
/// Settings Model
/// Compatible with GET/PUT /v3/settings
/// ===============================================================

class SettingsModel {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String theme;
  final String language;
  final int riskLevel;
  final double maxPositionSize;
  final double maxDailyLoss;
  final bool autoTradingEnabled;
  final String paperTradingMode;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SettingsModel({
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.theme,
    required this.language,
    required this.riskLevel,
    required this.maxPositionSize,
    required this.maxDailyLoss,
    required this.autoTradingEnabled,
    required this.paperTradingMode,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SettingsModel.empty() {
    return SettingsModel(
      id: '',
      userId: '',
      notificationsEnabled: true,
      emailNotifications: true,
      pushNotifications: true,
      theme: 'system',
      language: 'en',
      riskLevel: 2,
      maxPositionSize: 0.1,
      maxDailyLoss: 0.02,
      autoTradingEnabled: false,
      paperTradingMode: 'disabled',
      preferences: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json["id"] ?? json["_id"] ?? '',
      userId: json["user_id"] ?? '',
      notificationsEnabled: json["notifications_enabled"] ?? true,
      emailNotifications: json["email_notifications"] ?? true,
      pushNotifications: json["push_notifications"] ?? true,
      theme: json["theme"] ?? 'system',
      language: json["language"] ?? 'en',
      riskLevel: json["risk_level"] ?? 2,
      maxPositionSize: (json["max_position_size"] ?? 0.1).toDouble(),
      maxDailyLoss: (json["max_daily_loss"] ?? 0.02).toDouble(),
      autoTradingEnabled: json["auto_trading_enabled"] ?? false,
      paperTradingMode: json["paper_trading_mode"] ?? 'disabled',
      preferences: json["preferences"] ?? {},
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now(),
    );
  }

  factory SettingsModel.fromRawJson(String source) =>
      SettingsModel.fromJson(jsonDecode(source));

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "notifications_enabled": notificationsEnabled,
      "email_notifications": emailNotifications,
      "push_notifications": pushNotifications,
      "theme": theme,
      "language": language,
      "risk_level": riskLevel,
      "max_position_size": maxPositionSize,
      "max_daily_loss": maxDailyLoss,
      "auto_trading_enabled": autoTradingEnabled,
      "paper_trading_mode": paperTradingMode,
      "preferences": preferences,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  String toRawJson() => jsonEncode(toJson());

  SettingsModel copyWith({
    String? id,
    String? userId,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? theme,
    String? language,
    int? riskLevel,
    double? maxPositionSize,
    double? maxDailyLoss,
    bool? autoTradingEnabled,
    String? paperTradingMode,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      riskLevel: riskLevel ?? this.riskLevel,
      maxPositionSize: maxPositionSize ?? this.maxPositionSize,
      maxDailyLoss: maxDailyLoss ?? this.maxDailyLoss,
      autoTradingEnabled: autoTradingEnabled ?? this.autoTradingEnabled,
      paperTradingMode: paperTradingMode ?? this.paperTradingMode,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
