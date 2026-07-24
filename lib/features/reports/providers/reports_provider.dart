import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../appointments/domain/appointments_repository.dart';
import '../../directives/providers/directives_provider.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../calls/domain/calls_repository.dart';

/// Reports Analytics Provider (Phase 3 Engine)
/// 
/// This acts as the Business Intelligence layer, reading from all 
/// repositories to generate insights without needing a separate table.
class ReportsAnalytics {
  final int totalMeetings;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final int stalledTasks;
  final int criticalDirectives;
  final int upcomingAppointments;
  final int cancelledMeetings;
  final int missedCalls;

  ReportsAnalytics({
    required this.totalMeetings,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.overdueTasks,
    required this.stalledTasks,
    required this.criticalDirectives,
    required this.upcomingAppointments,
    required this.cancelledMeetings,
    required this.missedCalls,
  });

  double get taskCompletionRate => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  /// Returns task counts mapped by status (0: new, 1: in progress, 2: awaiting response, 3: completed, 4: overdue, 5: stalled, 6: cancelled)
  Map<int, int> get taskStatusDistribution => {
        0: totalTasks - (completedTasks + inProgressTasks + overdueTasks + stalledTasks), // fallback/other
        1: inProgressTasks,
        3: completedTasks,
        4: overdueTasks,
        5: stalledTasks,
      };
}

final reportsAnalyticsProvider = Provider<ReportsAnalytics>((ref) {
  // Watch the streams natively through Riverpod providers
  final tasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  final meetings = ref.watch(meetingsListProvider).valueOrNull ?? [];
  final directives = ref.watch(directivesListProvider).valueOrNull ?? [];
  final appointments = ref.watch(appointmentsListProvider).valueOrNull ?? [];
  final calls = ref.watch(callsListProvider).valueOrNull ?? [];

  return ReportsAnalytics(
    totalMeetings: meetings.length,
    totalTasks: tasks.length,
    completedTasks: tasks.where((t) => t.status == 3).length, // 3 = completed
    inProgressTasks: tasks.where((t) => t.status == 1).length, // 1 = in progress
    overdueTasks: tasks.where((t) => t.status == 4).length, // 4 = overdue
    stalledTasks: tasks.where((t) => t.status == 5).length, // 5 = stalled
    criticalDirectives: directives.where((d) => d.priority == 0).length, // 0 = critical
    upcomingAppointments: appointments.length,
    cancelledMeetings: meetings.where((m) => m.status == 4).length, // 4 = cancelled
    missedCalls: calls.where((c) => c.callType == 2).length, // 2 = missed
  );
});