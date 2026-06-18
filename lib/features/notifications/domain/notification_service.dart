import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/app_database.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../routine_tasks/domain/routine_task_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
        },
      );
      _initialized = true;

      // Auto schedule staggered alerts if enabled
      await scheduleStaggeredAlerts();
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
  }

  Future<bool> _isNotificationsEnabled() async {
    final val =
        await SecureStorageService.instance.read('notifications_enabled');
    return val != 'false';
  }

  Future<bool> _isOverdueAlertsEnabled() async {
    final val =
        await SecureStorageService.instance.read('overdue_alerts_enabled');
    return val != 'false';
  }

  Future<void> cancelAllReminders() async {
    if (!_initialized) await init();
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All notifications and scheduled reminders cancelled.');
  }

  Future<void> scheduleStaggeredAlerts() async {
    if (!_initialized) await init();

    final enabled = await _isNotificationsEnabled();
    if (!enabled) {
      await _flutterLocalNotificationsPlugin.cancel(id: 800);
      await _flutterLocalNotificationsPlugin.cancel(id: 801);
      await _flutterLocalNotificationsPlugin.cancel(id: 802);
      return;
    }

    try {
      // 1. Morning Review (08:00 AM)
      final now = DateTime.now();
      var morning = DateTime(now.year, now.month, now.day, 8, 0);
      if (morning.isBefore(now)) morning = morning.add(const Duration(days: 1));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 800,
        title: 'تخطيط اليوم التنفيذي ☀️',
        body:
            'سعادة المدير، ابدأ يومك بالاطلاع على قائمة الاجتماعات والمهام اليومية المجدولة.',
        scheduledDate: tz.TZDateTime.from(morning, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_staggered',
            'Mudiri Daily Staggered Alert',
            channelDescription: 'التنبيهات الإدارية المتفاوتة اليومية',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Midday Follow-up (02:00 PM)
      var midday = DateTime(now.year, now.month, now.day, 14, 0);
      if (midday.isBefore(now)) midday = midday.add(const Duration(days: 1));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 801,
        title: 'متابعة الإنجاز والمصفوفة 📊',
        body:
            'الوقوف على نسب إنجاز المهام والمتابعات المعلقة لضمان سير العمل بكفاءة.',
        scheduledDate: tz.TZDateTime.from(midday, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_staggered',
            'Mudiri Daily Staggered Alert',
            channelDescription: 'التنبيهات الإدارية المتفاوتة اليومية',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 3. Evening Review (08:00 PM)
      var evening = DateTime(now.year, now.month, now.day, 20, 0);
      if (evening.isBefore(now)) evening = evening.add(const Duration(days: 1));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 802,
        title: 'ملخص اليوم والإنجاز 🌙',
        body:
            'مراجعة سريعة لما تم إنجازه اليوم وتجهيز الأولويات لصباح الغد المشرق.',
        scheduledDate: tz.TZDateTime.from(evening, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_staggered',
            'Mudiri Daily Staggered Alert',
            channelDescription: 'التنبيهات الإدارية المتفاوتة اليومية',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Staggered notifications scheduled successfully.');
    } catch (e) {
      debugPrint('NotificationService.scheduleStaggeredAlerts error: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await init();
    }

    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'mudiri_main_channel',
        'Mudiri Main Channel',
        channelDescription: 'تنبيهات تطبيق مديري',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('NotificationService.showNotification error: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) {
      await init();
    }

    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_scheduled',
            'Mudiri Scheduled',
            channelDescription: 'تنبيهات المواعيد المجدولة',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleNotification error: $e');
    }
  }

  /// Dynamic Executive Reminders Engine based on actual database data
  Future<void> scheduleSmartExecutiveReminders({
    required List<Task> pendingTasks,
    required List<Meeting> upcomingMeetings,
    required List<Directive> pendingDirectives,
    required List<FollowUp> pendingFollowUps,
    required List<Meeting> tomorrowMeetings,
  }) async {
    if (!_initialized) await init();

    final enabled = await _isNotificationsEnabled();
    if (!enabled) {
      await _flutterLocalNotificationsPlugin.cancel(id: 900);
      await _flutterLocalNotificationsPlugin.cancel(id: 901);
      await _flutterLocalNotificationsPlugin.cancel(id: 902);
      await _flutterLocalNotificationsPlugin.cancel(id: 903);
      await _flutterLocalNotificationsPlugin.cancel(id: 904);
      return;
    }

    try {
      final now = DateTime.now();

      // Cancel previous dynamic notifications (IDs 900 to 904) to avoid duplicates
      await _flutterLocalNotificationsPlugin.cancel(id: 900);
      await _flutterLocalNotificationsPlugin.cancel(id: 901);
      await _flutterLocalNotificationsPlugin.cancel(id: 902);
      await _flutterLocalNotificationsPlugin.cancel(id: 903);
      await _flutterLocalNotificationsPlugin.cancel(id: 904);

      // 1. Morning Review (08:30 AM) - Urgent Task Reminder
      var morningTime = DateTime(now.year, now.month, now.day, 8, 30);
      if (morningTime.isBefore(now)) {
        morningTime = morningTime.add(const Duration(days: 1));
      }

      String morningTitle = 'مهام اليوم التنفيذية 📌';
      String morningBody =
          'سعادة المدير، لا توجد مهام معلقة حالياً. يومك سعيد ومليء بالإنجاز!';
      if (pendingTasks.isNotEmpty) {
        // Sort by priority (critical/0 first) and due date
        final urgentTask = (List<Task>.from(pendingTasks)
              ..sort((a, b) => a.priority.compareTo(b.priority)))
            .first;
        String priorityStr = urgentTask.priority == 0 ? 'عاجلة جداً 🚨' : 'هامة ⭐';
        final assigned =
            urgentTask.assignedTo != null && urgentTask.assignedTo!.isNotEmpty
                ? ' مسندة لـ [${urgentTask.assignedTo}]'
                : '';
        final due = urgentTask.dueDate != null && urgentTask.dueDate!.isNotEmpty
            ? ' - تسليم: ${urgentTask.dueDate}'
            : '';
        morningBody = 'مهمة $priorityStr: "${urgentTask.title}"$assigned$due';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 900,
        title: morningTitle,
        body: morningBody,
        scheduledDate: tz.TZDateTime.from(morningTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription:
                'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Midmorning Meeting (10:30 AM) - Meeting Reminder
      var midmorningTime = DateTime(now.year, now.month, now.day, 10, 30);
      if (midmorningTime.isBefore(now)) {
        midmorningTime = midmorningTime.add(const Duration(days: 1));
      }

      String meetingTitle = 'الاجتماعات المجدولة اليوم 👥';
      String meetingBody =
          'سعادة المدير، لا توجد اجتماعات معلنة اليوم. فرصة ممتازة للتركيز ومتابعة التقارير.';
      if (upcomingMeetings.isNotEmpty) {
        final nextMeeting = upcomingMeetings.first;
        final loc =
            nextMeeting.location != null && nextMeeting.location!.isNotEmpty
                ? ' في [${nextMeeting.location}]'
                : '';
        meetingBody =
            'اجتماع قادم: "${nextMeeting.title}" في تمام الساعة ${nextMeeting.time}$loc';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 901,
        title: meetingTitle,
        body: meetingBody,
        scheduledDate: tz.TZDateTime.from(midmorningTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription:
                'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 3. Midday Follow-up (01:30 PM) - Followups Reminder
      var middayTime = DateTime(now.year, now.month, now.day, 13, 30);
      if (middayTime.isBefore(now)) {
        middayTime = middayTime.add(const Duration(days: 1));
      }

      String followUpTitle = 'متابعة العمل التنفيذي 🔄';
      String followUpBody =
          'سعادة المدير، جميع المتابعات التنفيذية المسندة تسير بشكل طبيعي ودون تأخير.';
      if (pendingFollowUps.isNotEmpty) {
        final followUp = pendingFollowUps.first;
        final assigned =
            followUp.assignedTo != null && followUp.assignedTo!.isNotEmpty
                ? ' الموكلة للمسؤول [${followUp.assignedTo}]'
                : '';
        followUpBody = 'يرجى متابعة: "${followUp.title}"$assigned';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 902,
        title: followUpTitle,
        body: followUpBody,
        scheduledDate: tz.TZDateTime.from(middayTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription:
                'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 4. Afternoon Directive (04:30 PM) - Directives Reminder
      var afternoonTime = DateTime(now.year, now.month, now.day, 16, 30);
      if (afternoonTime.isBefore(now)) {
        afternoonTime = afternoonTime.add(const Duration(days: 1));
      }

      String directiveTitle = 'التوجيهات التنفيذية القائمة 📋';
      String directiveBody =
          'سعادة المدير، تم تسليم أو إنجاز كافة التوجيهات المسندة للأقسام.';
      if (pendingDirectives.isNotEmpty) {
        final directive = pendingDirectives.first;
        final assigned =
            directive.assignedTo != null && directive.assignedTo!.isNotEmpty
                ? ' لمتابعة [${directive.assignedTo}]'
                : '';
        final due = directive.deadline != null && directive.deadline!.isNotEmpty
            ? ' - تسليم: ${directive.deadline}'
            : '';
        directiveBody = 'توجيه قائم: "${directive.title}"$assigned$due';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 903,
        title: directiveTitle,
        body: directiveBody,
        scheduledDate: tz.TZDateTime.from(afternoonTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription:
                'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 5. Evening Harvest (08:30 PM) - Summary Alert
      var eveningTime = DateTime(now.year, now.month, now.day, 20, 30);
      if (eveningTime.isBefore(now)) {
        eveningTime = eveningTime.add(const Duration(days: 1));
      }

      String harvestTitle = 'الحصاد الإداري اليومي 📈';
      String harvestBody =
          'تقرير المساء: سعادة المدير، لديك ${pendingTasks.length} مهام معلقة، و ${pendingDirectives.length} توجيهات قائمة، و ${tomorrowMeetings.length} اجتماعات مجدولة للغد.';

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 904,
        title: harvestTitle,
        body: harvestBody,
        scheduledDate: tz.TZDateTime.from(eveningTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription:
                'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Smart Executive Reminders scheduled successfully.');
    } catch (e) {
      debugPrint(
          'NotificationService.scheduleSmartExecutiveReminders error: $e');
    }
  }

  // ─── Proactive Alerts Scheduling Logic ───────────────────────

  DateTime? _parseDateTime(String dateStr, String timeStr) {
    try {
      final parts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      if (parts.length == 3 && timeParts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        return DateTime(year, month, day, hour, minute);
      }
    } catch (_) {}
    return null;
  }

  Future<void> scheduleMeetingReminders(List<Meeting> meetings) async {
    if (!_initialized) await init();

    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    final now = DateTime.now();

    for (final meeting in meetings) {
      if (meeting.status == 2 || meeting.status == 4) {
        await _flutterLocalNotificationsPlugin.cancel(id: 10000 + meeting.id);
        continue;
      }

      final meetingDateTime = _parseDateTime(meeting.date, meeting.time);
      if (meetingDateTime == null) continue;

      final reminderTime =
          meetingDateTime.subtract(const Duration(minutes: 15));
      if (reminderTime.isAfter(now)) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: 10000 + meeting.id,
          title: 'اجتماع قادم بعد قليل 👥',
          body:
              'تذكير: اجتماع "${meeting.title}" سيبدأ خلال ١٥ دقيقة${meeting.location != null && meeting.location!.isNotEmpty ? " في [${meeting.location}]" : ""}.',
          scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'mudiri_meetings',
              'Mudiri Meetings Reminders',
              channelDescription: 'تنبيهات اقتراب موعد الاجتماعات',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        await _flutterLocalNotificationsPlugin.cancel(id: 10000 + meeting.id);
      }
    }
  }

  Future<void> scheduleAppointmentReminders(
      List<Appointment> appointments) async {
    if (!_initialized) await init();

    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    final now = DateTime.now();

    for (final appt in appointments) {
      if (appt.status == 2) {
        await _flutterLocalNotificationsPlugin.cancel(id: 20000 + appt.id);
        continue;
      }

      final apptDateTime = _parseDateTime(appt.date, appt.time);
      if (apptDateTime == null) continue;

      final reminderTime = apptDateTime.subtract(const Duration(minutes: 15));
      if (reminderTime.isAfter(now)) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: 20000 + appt.id,
          title: 'موعد قادم بعد قليل 📅',
          body:
              'تذكير: موعد "${appt.title}" سيبدأ خلال ١٥ دقيقة${appt.location != null && appt.location!.isNotEmpty ? " في [${appt.location}]" : ""}.',
          scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'mudiri_appointments',
              'Mudiri Appointments Reminders',
              channelDescription: 'تنبيهات اقتراب موعد المواعيد والزيارات',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        await _flutterLocalNotificationsPlugin.cancel(id: 20000 + appt.id);
      }
    }
  }

  Future<void> scheduleTaskDueReminders(List<Task> tasks) async {
    if (!_initialized) await init();

    final enabled = await _isNotificationsEnabled();
    final overdueEnabled = await _isOverdueAlertsEnabled();
    if (!enabled || !overdueEnabled) return;

    final now = DateTime.now();

    for (final task in tasks) {
      if (task.status == 3) {
        await _flutterLocalNotificationsPlugin.cancel(id: 40000 + task.id);
        continue;
      }

      if (task.dueDate == null || task.dueDate!.isEmpty) continue;

      final parts = task.dueDate!.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final reminderTime = DateTime(year, month, day, 9, 0);

        if (reminderTime.isAfter(now)) {
          String priorityStr = task.priority == 0 ? 'عاجلة جداً 🚨' : 'هامة ⭐';
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            id: 40000 + task.id,
            title: 'موعد استحقاق مهمة 📌',
            body:
                'تذكير: اليوم هو موعد تسليم المهمة الـ $priorityStr: "${task.title}".',
            scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'mudiri_tasks_due',
                'Mudiri Tasks Due',
                channelDescription: 'تنبيهات استحقاق المهام',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } else {
          await _flutterLocalNotificationsPlugin.cancel(id: 40000 + task.id);
        }
      }
    }
  }

  DateTime? _calculateNextOccurrence(RoutineTask task) {
    if (task.time == null || task.time!.isEmpty) return null;
    final timeParts = task.time!.split(':');
    if (timeParts.length != 2) return null;
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    for (int offset = 0; offset < 8; offset++) {
      final candidate = DateTime(now.year, now.month, now.day, hour, minute)
          .add(Duration(days: offset));
      if (candidate.isBefore(now)) continue;

      if (task.repeat.isActiveOn(candidate.weekday, task.daysOfWeek)) {
        return candidate;
      }
    }
    return null;
  }

  Future<void> scheduleRoutineTaskReminders(
      List<RoutineTask> routineTasks) async {
    if (!_initialized) await init();

    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    final now = DateTime.now();

    for (final task in routineTasks) {
      final intId = task.id.hashCode.abs() % 10000;
      if (!task.isActive) {
        await _flutterLocalNotificationsPlugin.cancel(id: 30000 + intId);
        continue;
      }

      final nextOccur = _calculateNextOccurrence(task);
      if (nextOccur != null && nextOccur.isAfter(now)) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: 30000 + intId,
          title: 'تذكير بمهمة روتينية 🔄',
          body:
              '${task.category.emoji} حان موعد مهمتك: "${task.title}" (${task.repeat.arabicLabel}).',
          scheduledDate: tz.TZDateTime.from(nextOccur, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'mudiri_routines',
              'Mudiri Routine Tasks',
              channelDescription: 'تذكيرات المهام الروتينية المتكررة',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        await _flutterLocalNotificationsPlugin.cancel(id: 30000 + intId);
      }
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
