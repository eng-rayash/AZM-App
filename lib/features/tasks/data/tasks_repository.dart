import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/base_repository.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';

// ─────────────────────────────────────────────
// Task Model
// ─────────────────────────────────────────────

class TaskModel {
  const TaskModel({
    required this.id,
    required this.syncId,
    required this.title,
    required this.status,
    required this.priority,
    this.companySyncId,
    this.description,
    this.assignedTo,
    this.dueDate,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String syncId;
  final String title;
  final int status;
  final int priority;
  final String? companySyncId;
  final String? description;
  final String? assignedTo;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id:             json['id'] as String,
        syncId:         json['sync_id'] as String,
        title:          json['title'] as String,
        status:         (json['status'] as num?)?.toInt() ?? 0,
        priority:       (json['priority'] as num?)?.toInt() ?? 2,
        companySyncId:  json['company_sync_id'] as String?,
        description:    json['description'] as String?,
        assignedTo:     json['assigned_to'] as String?,
        dueDate:  _parseDate(json['due_date']),
        completedAt: _parseDate(json['completed_at']),
        createdAt: _parseDate(json['created_at']),
        updatedAt: _parseDate(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'sync_id':   syncId,
        'title':     title,
        'status':    status,
        'priority':  priority,
        if (companySyncId != null) 'company_sync_id': companySyncId,
        if (description != null)   'description': description,
        if (assignedTo != null)    'assigned_to': assignedTo,
        if (dueDate != null)       'due_date': dueDate!.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic v) =>
      v != null ? DateTime.tryParse(v as String) : null;
}

// ─────────────────────────────────────────────
// Follow-up Model
// ─────────────────────────────────────────────

class FollowUpModel {
  const FollowUpModel({
    required this.id,
    required this.syncId,
    required this.title,
    required this.status,
    required this.priority,
    this.companySyncId,
    this.notes,
    this.targetDate,
    this.assignedTo,
    this.createdAt,
  });

  final String id;
  final String syncId;
  final String title;
  final int status;
  final int priority;
  final String? companySyncId;
  final String? notes;
  final DateTime? targetDate;
  final String? assignedTo;
  final DateTime? createdAt;

  factory FollowUpModel.fromJson(Map<String, dynamic> json) => FollowUpModel(
        id:            json['id'] as String,
        syncId:        json['sync_id'] as String,
        title:         json['title'] as String,
        status:        (json['status'] as num?)?.toInt() ?? 0,
        priority:      (json['priority'] as num?)?.toInt() ?? 2,
        companySyncId: json['company_sync_id'] as String?,
        notes:         json['notes'] as String?,
        assignedTo:    json['assigned_to'] as String?,
        targetDate: json['target_date'] != null
            ? DateTime.tryParse(json['target_date'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}

// ─────────────────────────────────────────────
// Tasks Repository
// ─────────────────────────────────────────────

class TasksRepository extends SupabaseRepository {
  const TasksRepository(super.client);

  // ── Fetch tasks ────────────────────────────
  Future<List<TaskModel>> getTasks({String? companySyncId}) async {
    return guard(() async {
      var query = client.from(SupabaseConfig.tableTasks).select();
      if (companySyncId != null) {
        query = query.eq('company_sync_id', companySyncId);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List)
          .map((j) => TaskModel.fromJson(j as Map<String, dynamic>))
          .toList();
    });
  }

  // ── Watch tasks (Realtime) ─────────────────
  Stream<List<TaskModel>> watchTasks({String? companySyncId}) {
    if (companySyncId != null) {
      return client
          .from(SupabaseConfig.tableTasks)
          .stream(primaryKey: ['id'])
          .eq('company_sync_id', companySyncId)
          .map((rows) => rows.map((j) => TaskModel.fromJson(j)).toList());
    }
    return client
        .from(SupabaseConfig.tableTasks)
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((j) => TaskModel.fromJson(j)).toList());
  }

  // ── Create task ────────────────────────────
  Future<TaskModel> createTask({
    required String syncId,
    required String title,
    String? description,
    int priority = 2,
    DateTime? dueDate,
    String? assignedTo,
    String? companySyncId,
  }) async {
    return guard(() async {
      final data = await client
          .from(SupabaseConfig.tableTasks)
          .insert({
            'sync_id':   syncId,
            'title':     title,
            'status':    0,
            'priority':  priority,
            'description': ?description,
            if (dueDate != null)       'due_date': dueDate.toIso8601String(),
            'assigned_to': ?assignedTo,
            'company_sync_id': ?companySyncId,
          })
          .select()
          .single();
      return TaskModel.fromJson(data);
    });
  }

  // ── Update task status ─────────────────────
  Future<void> updateStatus(String syncId, int status) async {
    return guard(() async {
      await client
          .from(SupabaseConfig.tableTasks)
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('sync_id', syncId);
    });
  }

  // ── Delete task ────────────────────────────
  Future<void> deleteTask(String syncId) async {
    return guard(() async {
      await client
          .from(SupabaseConfig.tableTasks)
          .update({'is_deleted': true})
          .eq('sync_id', syncId);
    });
  }
}

// ─────────────────────────────────────────────
// Follow-ups Repository
// ─────────────────────────────────────────────

class FollowUpsRepository extends SupabaseRepository {
  const FollowUpsRepository(super.client);

  Future<List<FollowUpModel>> getFollowUps({String? companySyncId}) async {
    return guard(() async {
      var query = client.from(SupabaseConfig.tableFollowUps).select();
      if (companySyncId != null) {
        query = query.eq('company_sync_id', companySyncId);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List)
          .map((j) => FollowUpModel.fromJson(j as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<FollowUpModel>> watchFollowUps({String? companySyncId}) {
    if (companySyncId != null) {
      return client
          .from(SupabaseConfig.tableFollowUps)
          .stream(primaryKey: ['id'])
          .eq('company_sync_id', companySyncId)
          .map((rows) => rows.map((j) => FollowUpModel.fromJson(j)).toList());
    }
    return client
        .from(SupabaseConfig.tableFollowUps)
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((j) => FollowUpModel.fromJson(j)).toList());
  }
}

// ─────────────────────────────────────────────
// Riverpod Providers
// ─────────────────────────────────────────────

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(supabaseClientProvider));
});

final followUpsRepositoryProvider = Provider<FollowUpsRepository>((ref) {
  return FollowUpsRepository(ref.watch(supabaseClientProvider));
});

/// Live stream of tasks (Realtime)
final tasksStreamProvider =
    StreamProvider.family<List<TaskModel>, String?>((ref, companySyncId) {
  return ref.watch(tasksRepositoryProvider).watchTasks(
        companySyncId: companySyncId,
      );
});

/// Live stream of follow-ups (Realtime)
final followUpsStreamProvider =
    StreamProvider.family<List<FollowUpModel>, String?>((ref, companySyncId) {
  return ref.watch(followUpsRepositoryProvider).watchFollowUps(
        companySyncId: companySyncId,
      );
});