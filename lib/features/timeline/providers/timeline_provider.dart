import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../appointments/domain/appointments_repository.dart';
import '../../calls/domain/calls_repository.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../visitors/domain/visitors_repository.dart';
import '../../movements/domain/movements_repository.dart';
import '../../directives/providers/directives_provider.dart';
import '../../followups/providers/follow_ups_provider.dart';

/// Represents a single event on the timeline
class TimelineEvent {
  final int? id;
  final String title;
  final String time;
  final String type; // 'meeting', 'visitor', 'movement', 'appointment', 'task', 'call', 'directive', 'followup'
  final bool isCompleted;
  final int priority; // 0=critical,1=high,2=medium,3=low (for sorting)
  final bool isOverdue; // for followup overdue items

  TimelineEvent({
    this.id,
    required this.title,
    required this.time,
    required this.type,
    this.isCompleted = false,
    this.priority = 3,
    this.isOverdue = false,
  });
}

/// Priority order for timeline display:
/// Overdue followups (4) > Critical (0) > InProgress (1) > Awaiting (2) > New (0) > Others
int _eventSortKey(TimelineEvent e) {
  if (e.type == 'followup') {
    if (e.isOverdue) return 0; // متأخر — highest priority
    if (e.priority == 0) return 1; // عاجل
    if (e.priority == 1) return 2; // عالي
    if (e.priority == 2) return 3; // متوسط
    return 4; // منخفض
  }
  return 5; // all other events after followups
}

/// Provider that aggregates events for the daily timeline
/// Includes: meetings, visitors, movements, appointments, tasks, calls, directives, 
/// AND incomplete follow-ups (new, in-progress, overdue, awaiting-response)
final timelineProvider = Provider<List<TimelineEvent>>((ref) {
  final events = <TimelineEvent>[];

  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

  String formatTimestamp(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('HH:mm').format(dt);
  }

  // 1. Meetings (الاجتماعات) - already filtered today in todayMeetingsProvider
  final meetings = ref.watch(todayMeetingsProvider).valueOrNull ?? [];
  for (final m in meetings) {
    if (m.date == todayStr) {
      events.add(TimelineEvent(
        id: m.id,
        title: m.title,
        time: m.time,
        type: 'meeting',
        isCompleted: m.status == 2, // 2: Completed
      ));
    }
  }

  // 2. Visitors (اللقاءات / الزوار)
  final visitors = ref.watch(activeVisitorsProvider).valueOrNull ?? [];
  for (final v in visitors) {
    final vDate = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(v.createdAt));
    if (vDate == todayStr) {
      events.add(TimelineEvent(
        id: v.id,
        title: 'لقاء مع: ${v.visitorName}',
        time: v.entryTime ?? formatTimestamp(v.createdAt),
        type: 'visitor',
        isCompleted: v.status == 2, // 2: Left
      ));
    }
  }

  // 3. Movements (التحركات)
  final movements = ref.watch(activeMovementsProvider).valueOrNull ?? [];
  for (final m in movements) {
    if (m.date == todayStr) {
      String typeStr = 'خروج';
      if (m.type == 1) typeStr = 'عودة';
      if (m.type == 2) typeStr = 'مهمة خارجية';
      
      events.add(TimelineEvent(
        id: m.id,
        title: '$typeStr إلى: ${m.destination}',
        time: m.time,
        type: 'movement',
        isCompleted: false,
      ));
    }
  }

  // 4. Appointments (المواعيد)
  final appointments = ref.watch(appointmentsListProvider).valueOrNull ?? [];
  for (final a in appointments) {
    if (a.date == todayStr) {
      events.add(TimelineEvent(
        id: a.id,
        title: 'موعد: ${a.title}',
        time: a.time,
        type: 'appointment',
        isCompleted: false,
      ));
    }
  }

  // 5. Tasks (المهام)
  final tasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  for (final t in tasks) {
    final tDate = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(t.createdAt));
    if (tDate == todayStr) {
      events.add(TimelineEvent(
        id: t.id,
        title: 'مهمة: ${t.title}',
        time: formatTimestamp(t.createdAt),
        type: 'task',
        isCompleted: t.status == 3, // 3: Completed (UnifiedStatus)
      ));
    }
  }

  // 6. Calls (المكالمات)
  final calls = ref.watch(callsListProvider).valueOrNull ?? [];
  for (final c in calls) {
    if (c.date == todayStr) {
      events.add(TimelineEvent(
        id: c.id,
        title: 'مكالمة: ${c.callerName}',
        time: c.time,
        type: 'call',
        isCompleted: true,
      ));
    }
  }

  // 7. Directives (التوجيهات)
  final directives = ref.watch(directivesListProvider).valueOrNull ?? [];
  for (final d in directives) {
    final dDate = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(d.createdAt));
    if (dDate == todayStr) {
      events.add(TimelineEvent(
        id: d.id,
        title: 'توجيه: ${d.title}',
        time: formatTimestamp(d.createdAt),
        type: 'directive',
        isCompleted: d.status == 3, // 3: Completed (UnifiedStatus)
      ));
    }
  }

  // 8. Follow-ups (المتابعات) — only INCOMPLETE ones (not status 3=completed)
  // Status: 0=new, 1=inProgress, 2=awaitingResponse, 4=overdue
  final followups = ref.watch(followUpsListProvider).valueOrNull ?? [];
  for (final f in followups) {
    // Skip completed follow-ups
    if (f.status == 3) continue;
    // Only include: new(0), inProgress(1), awaitingResponse(2), overdue(4)
    if (![0, 1, 2, 4].contains(f.status)) continue;

    final isOverdue = f.status == 4;
    
    // Determine display time: use targetDate if available, otherwise createdAt
    String displayTime = '09:00';
    if (f.targetDate != null && f.targetDate!.isNotEmpty) {
      displayTime = '⏰'; // placeholder — followups don't have time, show early
    }
    displayTime = formatTimestamp(f.createdAt);

    String statusLabel = '';
    if (f.status == 0) statusLabel = 'جديد';
    if (f.status == 1) statusLabel = 'قيد التنفيذ';
    if (f.status == 2) statusLabel = 'بانتظار الرد';
    if (f.status == 4) statusLabel = 'متأخر';

    events.add(TimelineEvent(
      id: f.id,
      title: '${isOverdue ? '⚠️ ' : ''}متابعة: ${f.title} ($statusLabel)',
      time: displayTime,
      type: 'followup',
      isCompleted: false,
      priority: f.priority,
      isOverdue: isOverdue,
    ));
  }

  // Sort events:
  // 1. Follow-up overdue & critical first
  // 2. Then by sort key ascending
  // 3. Within same key, by time ascending
  events.sort((a, b) {
    final keyA = _eventSortKey(a);
    final keyB = _eventSortKey(b);
    if (keyA != keyB) return keyA.compareTo(keyB);
    return a.time.compareTo(b.time);
  });

  return events;
});
