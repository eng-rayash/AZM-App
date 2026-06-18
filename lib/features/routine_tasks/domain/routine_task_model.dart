import 'dart:convert';

/// يمثّل مهمة روتينية يومية في نظام المهام الجديد.
class RoutineTask {
  final String id;
  final String title;
  final String? description;
  final RoutineCategory category;
  final RoutinePriority priority;
  final RoutineRepeat repeat;
  final String? time; // HH:mm
  final List<int> daysOfWeek; // 1=Mon..7=Sun (for weekly repeat)
  final bool isActive;
  final DateTime createdAt;

  const RoutineTask({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.repeat,
    this.time,
    this.daysOfWeek = const [],
    this.isActive = true,
    required this.createdAt,
  });

  RoutineTask copyWith({
    String? id,
    String? title,
    String? description,
    RoutineCategory? category,
    RoutinePriority? priority,
    RoutineRepeat? repeat,
    String? time,
    List<int>? daysOfWeek,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RoutineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      repeat: repeat ?? this.repeat,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'priority': priority.name,
        'repeat': repeat.name,
        'time': time,
        'daysOfWeek': daysOfWeek,
        'isActive': isActive,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory RoutineTask.fromJson(Map<String, dynamic> json) => RoutineTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: RoutineCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => RoutineCategory.personal,
        ),
        priority: RoutinePriority.values.firstWhere(
          (p) => p.name == json['priority'],
          orElse: () => RoutinePriority.medium,
        ),
        repeat: RoutineRepeat.values.firstWhere(
          (r) => r.name == json['repeat'],
          orElse: () => RoutineRepeat.daily,
        ),
        time: json['time'] as String?,
        daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] as int,
        ),
      );

  static List<RoutineTask> listFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => RoutineTask.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<RoutineTask> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());
}

// ─────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────

enum RoutineCategory {
  work,
  health,
  personal,
  learning,
  spiritual,
  finance,
}

extension RoutineCategoryX on RoutineCategory {
  String get arabicLabel {
    switch (this) {
      case RoutineCategory.work:
        return 'العمل';
      case RoutineCategory.health:
        return 'الصحة';
      case RoutineCategory.personal:
        return 'شخصي';
      case RoutineCategory.learning:
        return 'التعلّم';
      case RoutineCategory.spiritual:
        return 'روحي';
      case RoutineCategory.finance:
        return 'المالية';
    }
  }

  String get emoji {
    switch (this) {
      case RoutineCategory.work:
        return '💼';
      case RoutineCategory.health:
        return '🏃';
      case RoutineCategory.personal:
        return '👤';
      case RoutineCategory.learning:
        return '📚';
      case RoutineCategory.spiritual:
        return '🌙';
      case RoutineCategory.finance:
        return '💰';
    }
  }
}

enum RoutinePriority { critical, high, medium, low }

extension RoutinePriorityX on RoutinePriority {
  String get arabicLabel {
    switch (this) {
      case RoutinePriority.critical:
        return 'حرجة';
      case RoutinePriority.high:
        return 'عالية';
      case RoutinePriority.medium:
        return 'متوسطة';
      case RoutinePriority.low:
        return 'منخفضة';
    }
  }
}

enum RoutineRepeat { daily, weekly, weekdays, weekend }

extension RoutineRepeatX on RoutineRepeat {
  String get arabicLabel {
    switch (this) {
      case RoutineRepeat.daily:
        return 'يومياً';
      case RoutineRepeat.weekly:
        return 'أسبوعياً';
      case RoutineRepeat.weekdays:
        return 'أيام العمل';
      case RoutineRepeat.weekend:
        return 'نهاية الأسبوع';
    }
  }

  /// Returns true if this task should appear for the given [weekday] (1=Mon..7=Sun)
  bool isActiveOn(int weekday, List<int> customDays) {
    switch (this) {
      case RoutineRepeat.daily:
        return true;
      case RoutineRepeat.weekly:
        return customDays.contains(weekday);
      case RoutineRepeat.weekdays:
        return weekday >= 1 && weekday <= 5;
      case RoutineRepeat.weekend:
        return weekday == 6 || weekday == 7;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// Completion Record
// ─────────────────────────────────────────────────────────────────

/// Tracks which tasks were completed on which days.
class RoutineCompletion {
  final String taskId;
  final String dateKey; // yyyy-MM-dd

  const RoutineCompletion({required this.taskId, required this.dateKey});

  Map<String, dynamic> toJson() => {'taskId': taskId, 'dateKey': dateKey};

  factory RoutineCompletion.fromJson(Map<String, dynamic> json) =>
      RoutineCompletion(
        taskId: json['taskId'] as String,
        dateKey: json['dateKey'] as String,
      );

  static List<RoutineCompletion> listFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => RoutineCompletion.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<RoutineCompletion> list) =>
      jsonEncode(list.map((c) => c.toJson()).toList());
}
