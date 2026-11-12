import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/secure_storage_service.dart';
import '../../routine_tasks/providers/routine_tasks_provider.dart';
import '../domain/notification_service.dart';

/// تذكيرات الجهاز في RVIOS: الروتين اليومي للمتجر وحده. تنبيهات الطلبات تصل من
/// الخادم (`order_watcher` وإشعارات الدفع)، ووحدات الأعمال العامة في تطبيق «عزم».
final smartNotificationsSchedulerProvider = Provider<void>((ref) {
  final routineState = ref.watch(routineTasksProvider);
  final notificationService = ref.read(notificationServiceProvider);

  Future.microtask(() async {
    final enabled = await SecureStorageService.instance.read('notifications_enabled') != 'false';
    if (!enabled) {
      await notificationService.cancelAllReminders();
      return;
    }
    if (!routineState.isLoading) {
      await notificationService.scheduleRoutineTaskReminders(routineState.tasks);
    }
  });
});
