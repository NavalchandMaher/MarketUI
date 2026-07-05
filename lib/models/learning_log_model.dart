import 'dart:convert';

/// ===============================================================
/// Learning Log Model
/// Compatible with GET /learning-logs
/// ===============================================================

class LearningLogModel {
  final List<LearningLog> logs;

  const LearningLogModel({
    required this.logs,
  });

  factory LearningLogModel.empty() {
    return const LearningLogModel(
      logs: [],
    );
  }

  factory LearningLogModel.fromJson(
    List<dynamic> json,
  ) {
    return LearningLogModel(
      logs: json
          .map(
            (e) => LearningLog.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  factory LearningLogModel.fromRawJson(
    String source,
  ) =>
      LearningLogModel.fromJson(
        jsonDecode(source),
      );

  List<Map<String, dynamic>> toJson() {
    return logs
        .map(
          (e) => e.toJson(),
        )
        .toList();
  }

  String toRawJson() =>
      jsonEncode(toJson());

  LearningLogModel copyWith({
    List<LearningLog>? logs,
  }) {
    return LearningLogModel(
      logs: logs ?? this.logs,
    );
  }

  bool get isEmpty => logs.isEmpty;

  bool get isNotEmpty => logs.isNotEmpty;

  int get count => logs.length;

  @override
  String toString() {
    return '''
LearningLogModel(
count: $count
)
''';
  }
}

/// ===============================================================
/// Learning Log
/// ===============================================================

class LearningLog {
  final String id;

  final DateTime? createdAt;

  final String strategy;

  final String parameter;

  final String oldValue;

  final String newValue;

  final String reason;

  final String status;

  const LearningLog({
    required this.id,
    required this.createdAt,
    required this.strategy,
    required this.parameter,
    required this.oldValue,
    required this.newValue,
    required this.reason,
    required this.status,
  });

  factory LearningLog.fromJson(
    Map<String, dynamic> json,
  ) {
    return LearningLog(
      id: json["id"]?.toString() ?? "",

      createdAt: json["created_at"] != null
          ? DateTime.tryParse(
              json["created_at"].toString(),
            )
          : null,

      strategy: json["strategy"] ?? "",

      parameter: json["parameter"] ?? "",

      oldValue:
          json["old_value"]?.toString() ?? "",

      newValue:
          json["new_value"]?.toString() ?? "",

      reason: json["reason"] ?? "",

      status: json["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "created_at":
          createdAt?.toIso8601String(),
      "strategy": strategy,
      "parameter": parameter,
      "old_value": oldValue,
      "new_value": newValue,
      "reason": reason,
      "status": status,
    };
  }

  LearningLog copyWith({
    String? id,
    DateTime? createdAt,
    String? strategy,
    String? parameter,
    String? oldValue,
    String? newValue,
    String? reason,
    String? status,
  }) {
    return LearningLog(
      id: id ?? this.id,
      createdAt:
          createdAt ?? this.createdAt,
      strategy:
          strategy ?? this.strategy,
      parameter:
          parameter ?? this.parameter,
      oldValue:
          oldValue ?? this.oldValue,
      newValue:
          newValue ?? this.newValue,
      reason:
          reason ?? this.reason,
      status:
          status ?? this.status,
    );
  }

  @override
  String toString() {
    return '''
LearningLog(
strategy: $strategy
parameter: $parameter
status: $status
)
''';
  }
}