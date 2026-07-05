import 'dart:convert';

/// ===============================================================
/// Scheduler Status Model
/// Compatible with:
/// GET /scheduler/status
/// ===============================================================

class SchedulerStatusModel {
  final bool running;

  final int totalJobs;

  final List<SchedulerJob> jobs;

  const SchedulerStatusModel({
    required this.running,
    required this.totalJobs,
    required this.jobs,
  });

  factory SchedulerStatusModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SchedulerStatusModel(
      running: json["running"] ?? false,

      totalJobs: json["total_jobs"] ?? 0,

      jobs: (json["jobs"] as List? ?? [])
          .map(
            (e) => SchedulerJob.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  factory SchedulerStatusModel.fromRawJson(
    String source,
  ) =>
      SchedulerStatusModel.fromJson(
        jsonDecode(source),
      );

  Map<String, dynamic> toJson() {
    return {
      "running": running,
      "total_jobs": totalJobs,
      "jobs": jobs
          .map(
            (e) => e.toJson(),
          )
          .toList(),
    };
  }

  String toRawJson() =>
      jsonEncode(toJson());

  SchedulerStatusModel copyWith({
    bool? running,
    int? totalJobs,
    List<SchedulerJob>? jobs,
  }) {
    return SchedulerStatusModel(
      running: running ?? this.running,
      totalJobs: totalJobs ?? this.totalJobs,
      jobs: jobs ?? this.jobs,
    );
  }

  bool get isRunning => running;

  bool get hasJobs => jobs.isNotEmpty;

  @override
  String toString() {
    return '''
SchedulerStatusModel(
running : $running
totalJobs : $totalJobs
)
''';
  }
}

/// ===============================================================
/// Scheduler Dashboard Model
/// Compatible with:
/// GET /scheduler/dashboard
/// ===============================================================

class SchedulerDashboardModel {
  final SchedulerInfo scheduler;

  final MarketHealth marketHealth;

  final List<JobInfo> jobs;

  final DateTime? timestamp;

  const SchedulerDashboardModel({
    required this.scheduler,
    required this.marketHealth,
    required this.jobs,
    required this.timestamp,
  });

  factory SchedulerDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SchedulerDashboardModel(
      scheduler: SchedulerInfo.fromJson(
        json["scheduler"] ?? {},
      ),

      marketHealth: MarketHealth.fromJson(
        json["market_health"] ?? {},
      ),

      jobs: (json["jobs"] as List? ?? [])
          .map(
            (e) => JobInfo.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),

      timestamp: json["timestamp"] != null
          ? DateTime.tryParse(
              json["timestamp"],
            )
          : null,
    );
  }

  factory SchedulerDashboardModel.fromRawJson(
    String source,
  ) =>
      SchedulerDashboardModel.fromJson(
        jsonDecode(source),
      );

  Map<String, dynamic> toJson() {
    return {
      "scheduler": scheduler.toJson(),
      "market_health": marketHealth.toJson(),
      "jobs": jobs
          .map(
            (e) => e.toJson(),
          )
          .toList(),
      "timestamp":
          timestamp?.toIso8601String(),
    };
  }

  String toRawJson() =>
      jsonEncode(toJson());

  SchedulerDashboardModel copyWith({
    SchedulerInfo? scheduler,
    MarketHealth? marketHealth,
    List<JobInfo>? jobs,
    DateTime? timestamp,
  }) {
    return SchedulerDashboardModel(
      scheduler:
          scheduler ?? this.scheduler,
      marketHealth:
          marketHealth ??
              this.marketHealth,
      jobs: jobs ?? this.jobs,
      timestamp:
          timestamp ?? this.timestamp,
    );
  }

  bool get isRunning =>
      scheduler.running;

  @override
  String toString() {
    return '''
SchedulerDashboardModel(
running : ${scheduler.running}
jobs : ${scheduler.totalJobs}
)
''';
  }
}
/// ===============================================================
/// Scheduler Info
/// ===============================================================

class SchedulerInfo {
  final bool running;

  final int totalJobs;

  final List<SchedulerJob> jobs;

  const SchedulerInfo({
    required this.running,
    required this.totalJobs,
    required this.jobs,
  });

  factory SchedulerInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return SchedulerInfo(
      running: json["running"] ?? false,

      totalJobs: json["total_jobs"] ?? 0,

      jobs: (json["jobs"] as List? ?? [])
          .map(
            (e) => SchedulerJob.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "running": running,
      "total_jobs": totalJobs,
      "jobs": jobs
          .map(
            (e) => e.toJson(),
          )
          .toList(),
    };
  }

  SchedulerInfo copyWith({
    bool? running,
    int? totalJobs,
    List<SchedulerJob>? jobs,
  }) {
    return SchedulerInfo(
      running: running ?? this.running,
      totalJobs: totalJobs ?? this.totalJobs,
      jobs: jobs ?? this.jobs,
    );
  }

  bool get isRunning => running;

  bool get hasJobs => jobs.isNotEmpty;

  SchedulerJob? get nextJob =>
      jobs.isNotEmpty ? jobs.first : null;

  @override
  String toString() {
    return '''
SchedulerInfo(
running : $running
totalJobs : $totalJobs
)
''';
  }
}

/// ===============================================================
/// Scheduler Job
/// ===============================================================

class SchedulerJob {
  final String id;

  final DateTime? nextRun;

  final String trigger;

  const SchedulerJob({
    required this.id,
    required this.nextRun,
    required this.trigger,
  });

  factory SchedulerJob.fromJson(
    Map<String, dynamic> json,
  ) {
    return SchedulerJob(
      id: json["id"] ?? "",

      nextRun: json["next_run"] != null
          ? DateTime.tryParse(
              json["next_run"].toString(),
            )
          : null,

      trigger: json["trigger"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "next_run":
          nextRun?.toIso8601String(),
      "trigger": trigger,
    };
  }

  SchedulerJob copyWith({
    String? id,
    DateTime? nextRun,
    String? trigger,
  }) {
    return SchedulerJob(
      id: id ?? this.id,
      nextRun: nextRun ?? this.nextRun,
      trigger: trigger ?? this.trigger,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  bool get isMarketCycle =>
      id == "market_cycle";

  bool get isNightlyCycle =>
      id == "nightly_cycle";

  bool get hasNextRun =>
      nextRun != null;

  String get displayName {
    switch (id) {
      case "market_cycle":
        return "Market Cycle";

      case "nightly_cycle":
        return "Nightly AI";

      default:
        return id;
    }
  }

  @override
  String toString() {
    return '''
SchedulerJob(
id : $id
nextRun : $nextRun
trigger : $trigger
)
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchedulerJob &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nextRun == other.nextRun;

  @override
  int get hashCode =>
      Object.hash(id, nextRun);
}
/// ===============================================================
/// Dashboard Job Info
/// Used by GET /scheduler/dashboard
/// ===============================================================

class JobInfo {
  final String name;

  final String frequency;

  const JobInfo({
    required this.name,
    required this.frequency,
  });

  factory JobInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return JobInfo(
      name: json["name"] ?? "",
      frequency: json["frequency"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "frequency": frequency,
    };
  }

  JobInfo copyWith({
    String? name,
    String? frequency,
  }) {
    return JobInfo(
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  String toString() {
    return '''
JobInfo(
name: $name
frequency: $frequency
)
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          frequency == other.frequency;

  @override
  int get hashCode =>
      Object.hash(name, frequency);
}

/// ===============================================================
/// Market Health
/// Compatible with:
/// {
///   "market_cycle":"RUNNING"
/// }
/// ===============================================================

class MarketHealth {
  final String marketCycle;

  const MarketHealth({
    required this.marketCycle,
  });

  factory MarketHealth.fromJson(
    Map<String, dynamic> json,
  ) {
    return MarketHealth(
      marketCycle:
          json["market_cycle"] ?? "UNKNOWN",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "market_cycle": marketCycle,
    };
  }

  MarketHealth copyWith({
    String? marketCycle,
  }) {
    return MarketHealth(
      marketCycle:
          marketCycle ?? this.marketCycle,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  bool get isRunning =>
      marketCycle.toUpperCase() == "RUNNING";

  bool get isStopped =>
      marketCycle.toUpperCase() == "STOPPED";

  bool get isPaused =>
      marketCycle.toUpperCase() == "PAUSED";

  ColorStatus get status {
    switch (marketCycle.toUpperCase()) {
      case "RUNNING":
        return ColorStatus.success;

      case "PAUSED":
        return ColorStatus.warning;

      case "STOPPED":
        return ColorStatus.error;

      default:
        return ColorStatus.unknown;
    }
  }

  @override
  String toString() {
    return '''
MarketHealth(
marketCycle: $marketCycle
)
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketHealth &&
          runtimeType == other.runtimeType &&
          marketCycle == other.marketCycle;

  @override
  int get hashCode => marketCycle.hashCode;
}

/// ===============================================================
/// Scheduler Status Enum
/// ===============================================================

enum ColorStatus {
  success,
  warning,
  error,
  unknown,
}