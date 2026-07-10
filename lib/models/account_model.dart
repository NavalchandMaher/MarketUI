import 'dart:convert';

/// ===============================================================
/// Account Model
/// Compatible with GET/PUT /v3/account
/// ===============================================================

class AccountModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? country;
  final String? brokerName;
  final String? brokerApiKey;
  final String? brokerApiSecret;
  final String accountTier;
  final double initialBalance;
  final double currentBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.country,
    this.brokerName,
    this.brokerApiKey,
    this.brokerApiSecret,
    required this.accountTier,
    required this.initialBalance,
    required this.currentBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.empty() {
    return AccountModel(
      id: '',
      fullName: '',
      email: '',
      accountTier: 'free',
      initialBalance: 0,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json["id"] ?? json["_id"] ?? '',
      fullName: json["full_name"] ?? '',
      email: json["email"] ?? '',
      phone: json["phone"],
      country: json["country"],
      brokerName: json["broker_name"],
      brokerApiKey: json["broker_api_key"],
      brokerApiSecret: json["broker_api_secret"],
      accountTier: json["account_tier"] ?? 'free',
      initialBalance: (json["initial_balance"] ?? 0).toDouble(),
      currentBalance: (json["current_balance"] ?? 0).toDouble(),
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now(),
    );
  }

  factory AccountModel.fromRawJson(String source) =>
      AccountModel.fromJson(jsonDecode(source));

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "email": email,
      "phone": phone,
      "country": country,
      "broker_name": brokerName,
      "broker_api_key": brokerApiKey,
      "broker_api_secret": brokerApiSecret,
      "account_tier": accountTier,
      "initial_balance": initialBalance,
      "current_balance": currentBalance,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  String toRawJson() => jsonEncode(toJson());

  AccountModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? country,
    String? brokerName,
    String? brokerApiKey,
    String? brokerApiSecret,
    String? accountTier,
    double? initialBalance,
    double? currentBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      brokerName: brokerName ?? this.brokerName,
      brokerApiKey: brokerApiKey ?? this.brokerApiKey,
      brokerApiSecret: brokerApiSecret ?? this.brokerApiSecret,
      accountTier: accountTier ?? this.accountTier,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
