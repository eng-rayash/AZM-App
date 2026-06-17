import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:fl_chart/fl_chart.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../core/router/route_names.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../reports/providers/reports_provider.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../followups/providers/follow_ups_provider.dart';
import '../providers/periodic_tasks_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/dashboard_fab.dart';
import '../../notifications/domain/notification_service.dart';
import '../../notifications/providers/smart_notifications_provider.dart';
import '../../../core/security/secure_storage_service.dart';

/// Dashboard Screen — executive command center.
///
/// Displays: Today's summary, upcoming meetings, stats overview.
/// Quick-add actions are accessible via the center FAB.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGreeting();
      _checkMonthlyUpdate();
    });
  }

  Future<void> _checkAndShowGreeting() async {
    try {
      final storage = SecureStorageService.instance;
      final notificationsVal = await storage.read('notifications_enabled');
      if (notificationsVal == 'false') return;
      if (!mounted) return;

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastShown = await storage.read('last_greeting_shown_date');
      if (lastShown == todayStr) return; // Already shown today
      if (!mounted) return;

      // Get today's stats
      final analytics = ref.read(reportsAnalyticsProvider);
      final todayMeetings = ref.read(todayMeetingsProvider).valueOrNull?.length ?? 0;
      
      // Trigger notification
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.showNotification(
        id: 999,
        title: 'صباح الخير سعادة المدير! ☀️',
        body: 'لديك اليوم $todayMeetings اجتماعات، و ${analytics.totalTasks} مهام، و ${analytics.upcomingAppointments} مواعيد قادمة.',
      );

      // Save that we showed it today
      if (!mounted) return;
      await storage.write('last_greeting_shown_date', todayStr);
    } catch (e) {
      debugPrint('Error triggering daily greeting: $e');
    }
  }

  Future<void> _checkMonthlyUpdate() async {
    try {
      final storage = SecureStorageService.instance;
      final lastCheckStr = await storage.read('last_update_check_date');
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T').first;

      if (lastCheckStr != null) {
        final lastCheck = DateTime.tryParse(lastCheckStr);
        if (lastCheck != null) {
          final difference = now.difference(lastCheck).inDays;
          if (difference >= 30) {
            _showUpdateDialog();
            await storage.write('last_update_check_date', todayStr);
          }
        } else {
          await storage.write('last_update_check_date', todayStr);
        }
      } else {
        // First launch setting: store today's date
        await storage.write('last_update_check_date', todayStr);
      }
    } catch (e) {
      debugPrint('Error checking monthly update: $e');
    }
  }

  void _showUpdateDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: NeuCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.system_update_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تحديث التطبيق متاح',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'يتوفر إصدار جديد من تطبيق "مديري". يرجى التحديث لضمان الحصول على أحدث الميزات وتحسينات الأمان والأداء.',
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: NeuButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يتم الآن تحويلك إلى صفحة التحديث...', textDirection: TextDirection.rtl),
                                backgroundColor: NeuColors.navyDeep,
                              ),
                            );
                          },
                          label: 'تحديث الآن',
                          variant: NeuButtonVariant.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeuButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          label: 'تذكيري لاحقاً',
                          variant: NeuButtonVariant.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    
    // Format Gregorian Date
    final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
    
    // Format Hijri Date
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final hijriStr = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    final events = ref.watch(timelineProvider);
    final displayedEvents = events.take(5).toList();

    // Activate and synchronize smart dynamic reminders
    ref.watch(smartNotificationsSchedulerProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      floatingActionButton: const DashboardFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Executive Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screen,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحبًا، سعادة المدير',
                              style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                            ),
                            AppSpacing.gapXs,
                            Text(
                              '$dateStr | $hijriStr',
                              style: isDark
                                  ? AppTypography.captionDark.copyWith(
                                      color: NeuColors.goldAccent,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : AppTypography.caption.copyWith(
                                      color: NeuColors.navyMid,
                                      fontWeight: FontWeight.w600,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.settings),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
                                offset: const Offset(3, 3),
                                blurRadius: 6,
                              ),
                              BoxShadow(
                                color: isDark ? NeuColors.shadowLightDark : NeuColors.shadowLight,
                                offset: const Offset(-3, -3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Periodic Tasks System Card (replaces Today Summary)
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenH,
                  child: _PeriodicTasksCard(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Executive Follow-ups Donut Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenH,
                  child: ref.watch(followUpsListProvider).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text(
                        'خطأ في تحميل إحصائيات المتابعات: $err',
                        style: const TextStyle(color: NeuColors.priorityCritical),
                      ),
                    ),
                    data: (followups) {
                      final newCount = followups.where((f) => f.status == 0).length;
                      final inProgressCount = followups.where((f) => f.status == 1).length;
                      final awaitingResponseCount = followups.where((f) => f.status == 2).length;
                      final completedCount = followups.where((f) => f.status == 3).length;
                      final overdueCount = followups.where((f) => f.status == 4).length;

                      return FollowUpDistributionChart(
                        newItems: newCount,
                        inProgress: inProgressCount,
                        awaitingResponse: awaitingResponseCount,
                        completed: completedCount,
                        overdue: overdueCount,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              ),

              // Section: Daily Timeline (السجل الزمني اليومي)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'السجل الزمني اليومي',
                        style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.timeline),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'عرض المخطط',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Timeline List using SliverList.builder
              displayedEvents.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: AppSpacing.screenH,
                        child: NeuCard(
                          child: EmptyState(
                            icon: Icons.timeline_rounded,
                            title: 'لا توجد أحداث مجدولة لليوم',
                            actionLabel: 'عرض المخطط الكامل',
                            onAction: () => context.push(RouteNames.timeline),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: AppSpacing.screenH,
                      sliver: SliverList.builder(
                        itemCount: displayedEvents.length,
                        itemBuilder: (context, idx) {
                          final event = displayedEvents[idx];
                          
                          IconData getEventIcon(String type) {
                            switch (type) {
                              case 'meeting': return Icons.groups_rounded;
                              case 'visitor': return Icons.badge_rounded;
                              case 'movement': return Icons.directions_car_rounded;
                              case 'appointment': return Icons.calendar_month_rounded;
                              case 'task': return Icons.task_alt_rounded;
                              case 'call': return Icons.phone_in_talk_rounded;
                              case 'directive': return Icons.campaign_rounded;
                              case 'followup': return Icons.track_changes_rounded;
                              default: return Icons.event_note_rounded;
                            }
                          }

                          Color getEventColor(String type) {
                            switch (type) {
                              case 'meeting': return NeuColors.info;
                              case 'visitor': return NeuColors.warning;
                              case 'movement': return isDark ? NeuColors.goldAccent : NeuColors.navyMid;
                              case 'appointment': return NeuColors.success;
                              case 'task': return NeuColors.navyLight;
                              case 'call': return NeuColors.info;
                              case 'directive': return NeuColors.danger;
                              case 'followup': return NeuColors.priorityCritical;
                              default: return NeuColors.goldAccent;
                            }
                          }

                          String getEventTypeName(String type) {
                            switch (type) {
                              case 'meeting': return 'اجتماع';
                              case 'visitor': return 'لقاء / زيارة';
                              case 'movement': return 'تحرك خارجي';
                              case 'appointment': return 'موعد';
                              case 'task': return 'مهمة عمل';
                              case 'call': return 'مكالمة هاتفية';
                              case 'directive': return 'توجيه تنفيذي';
                              case 'followup': return 'متابعة تنفيذية';
                              default: return 'حدث';
                            }
                          }

                          void handleEventTap(BuildContext context, TimelineEvent event) {
                            if (event.id == null) return;
                            switch (event.type) {
                              case 'meeting':
                                context.push(RouteNames.meetingDetailPath(event.id!));
                                break;
                              case 'task':
                                context.push(RouteNames.taskDetailPath(event.id!));
                                break;
                              case 'directive':
                                context.push(RouteNames.directiveDetailPath(event.id!));
                                break;
                              case 'followup':
                                context.push(RouteNames.followupEditPath(event.id!));
                                break;
                              case 'appointment':
                                context.push(RouteNames.appointmentsList);
                                break;
                              case 'call':
                                context.push(RouteNames.callsList);
                                break;
                              case 'visitor':
                                context.push(RouteNames.visitorsList);
                                break;
                              case 'movement':
                                context.push(RouteNames.movementsList);
                                break;
                            }
                          }

                          final color = getEventColor(event.type);
                          final icon = getEventIcon(event.type);
                          final typeLabel = getEventTypeName(event.type);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time Column
                              SizedBox(
                                width: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    event.time,
                                    style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              
                              // Line & Dot
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 18),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: event.isCompleted ? NeuColors.success : color,
                                      border: Border.all(
                                        color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  if (idx != displayedEvents.length - 1)
                                    Container(
                                      width: 2,
                                      height: 62,
                                      color: isDark ? NeuColors.dividerDark : NeuColors.divider,
                                    ),
                                ],
                              ),
                              
                              AppSpacing.gapHSm,
                              
                              // Card
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => handleEventTap(context, event),
                                    child: NeuCard(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              icon,
                                              color: event.isCompleted ? NeuColors.success : color,
                                              size: 18,
                                            ),
                                          ),
                                          AppSpacing.gapHSm,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.title,
                                                  style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  typeLabel,
                                                  style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (event.isCompleted)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: NeuColors.success,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),



              // Extra padding at bottom for FAB clearance
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }



}

// ─────────────────────────────────────────────────────────────────
// Periodic Tasks Card Widget
// ─────────────────────────────────────────────────────────────────

class _PeriodicTasksCard extends ConsumerWidget {
  const _PeriodicTasksCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periodicState = ref.watch(periodicTasksProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final completeAction = ref.watch(periodicTaskCompletionProvider);

    return NeuCard(
      showGoldBorder: true,
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                size: 20,
              ),
              AppSpacing.gapHSm,
              Text(
                'نظام المهام',
                style: isDark ? AppTypography.h4Dark : AppTypography.h4,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('${RouteNames.tasksListFull}?status=all'),
                child: Text(
                  'عرض الكل',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,

          // Period Tabs
          Row(
            children: TaskPeriod.values.map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(selectedPeriodProvider.notifier).setPeriod(period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? NeuColors.dividerDark : NeuColors.divider),
                      ),
                    ),
                    child: Text(
                      '${period.iconLabel} ${period.arabicLabel}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Tajawal',
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AppSpacing.gapLg,

          // Progress Ring + Stats Row
          Row(
            children: [
              // Donut progress circle
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: periodicState.completionRatio,
                      strokeWidth: 8,
                      backgroundColor:
                          isDark ? NeuColors.dividerDark : NeuColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        periodicState.completionPercent >= 80
                            ? NeuColors.success
                            : periodicState.completionPercent >= 40
                                ? NeuColors.warning
                                : NeuColors.danger,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${periodicState.completionPercent}%',
                        style: (isDark
                                ? AppTypography.h4Dark
                                : AppTypography.h4)
                            .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapHMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإنجاز: ${periodicState.completedCount} / ${periodicState.totalCount}',
                      style: (isDark ? AppTypography.bodyDark : AppTypography.body)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      periodicState.totalCount == 0
                          ? 'لا توجد مهام لهذه الفترة'
                          : periodicState.completionPercent >= 80
                              ? '🎉 أداء رائع! استمر'
                              : periodicState.completionPercent >= 40
                                  ? '💪 على الطريق الصحيح'
                                  : '⚡ ابدأ بالمهام الأهم',
                      style: (isDark ? AppTypography.captionDark : AppTypography.caption)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tasks list
          if (periodicState.items.isNotEmpty) ...[
            AppSpacing.gapMd,
            const Divider(),
            AppSpacing.gapSm,
            ...periodicState.items.take(5).map((item) {
              return _PeriodicTaskTile(
                item: item,
                isDark: isDark,
                onToggle: () => completeAction(
                  item.task.id,
                  !item.isCompleted,
                ),
              );
            }),
            if (periodicState.items.length > 5)
              Center(
                child: TextButton(
                  onPressed: () => context.push('${RouteNames.tasksListFull}?status=all'),
                  child: Text(
                    '+${periodicState.items.length - 5} مهام أخرى',
                    style: TextStyle(
                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
          ] else ...[
            AppSpacing.gapMd,
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                    size: 32,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    'لا توجد مهام لهذه الفترة',
                    style: isDark ? AppTypography.bodySmallDark : AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Single task tile with completion toggle
class _PeriodicTaskTile extends StatelessWidget {
  final PeriodicTaskItem item;
  final bool isDark;
  final VoidCallback onToggle;

  const _PeriodicTaskTile({
    required this.item,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(item.task.priority);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Completion checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isCompleted
                    ? NeuColors.success
                    : Colors.transparent,
                border: Border.all(
                  color: item.isCompleted
                      ? NeuColors.success
                      : (isDark ? NeuColors.dividerDark : NeuColors.divider),
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          // Priority dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // Task title
          Expanded(
            child: Text(
              item.task.title,
              style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                fontSize: 13,
                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                color: item.isCompleted
                    ? (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary)
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Routine/Achievement badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: item.isRoutine
                  ? NeuColors.info.withValues(alpha: 0.15)
                  : NeuColors.goldAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.isRoutine ? 'روتيني' : 'إنجازي',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Tajawal',
                color: item.isRoutine ? NeuColors.info : NeuColors.goldAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 0: return NeuColors.priorityCritical;
      case 1: return NeuColors.danger;
      case 2: return NeuColors.warning;
      default: return NeuColors.success;
    }
  }
}

/// Executive follow-up distribution fl_chart section
class FollowUpDistributionChart extends StatelessWidget {
  final int newItems;
  final int inProgress;
  final int awaitingResponse;
  final int completed;
  final int overdue;
  final bool isDark;

  const FollowUpDistributionChart({
    super.key,
    required this.newItems,
    required this.inProgress,
    required this.awaitingResponse,
    required this.completed,
    required this.overdue,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = newItems + inProgress + awaitingResponse + completed + overdue;
    final awaitingColor = isDark ? NeuColors.goldAccent : NeuColors.navyMid;

    return NeuCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.donut_large_rounded,
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                size: 20,
              ),
              AppSpacing.gapHSm,
              Text(
                'مخطط المتابعات التنفيذية',
                style: isDark ? AppTypography.h4Dark : AppTypography.h4,
              ),
            ],
          ),
          AppSpacing.gapLg,
          if (total == 0)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'لا توجد متابعات تنفيذية مسجلة حتى الآن.',
                  style: isDark ? AppTypography.bodySmallDark : AppTypography.bodySmall,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: NeuColors.info,
                            value: newItems.toDouble(),
                            title: newItems > 0 ? '$newItems' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            color: NeuColors.warning,
                            value: inProgress.toDouble(),
                            title: inProgress > 0 ? '$inProgress' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            color: awaitingColor,
                            value: awaitingResponse.toDouble(),
                            title: awaitingResponse > 0 ? '$awaitingResponse' : '',
                            radius: 16,
                            titleStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.black : Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            color: NeuColors.success,
                            value: completed.toDouble(),
                            title: completed > 0 ? '$completed' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            color: NeuColors.danger,
                            value: overdue.toDouble(),
                            title: overdue > 0 ? '$overdue' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapHMd,
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(context, 'جديدة', newItems, NeuColors.info, isDark, () => context.push('${RouteNames.followupsListFull}?status=0')),
                      AppSpacing.gapSm,
                      _buildLegendItem(context, 'قيد التنفيذ', inProgress, NeuColors.warning, isDark, () => context.push('${RouteNames.followupsListFull}?status=1')),
                      AppSpacing.gapSm,
                      _buildLegendItem(context, 'بانتظار الرد', awaitingResponse, awaitingColor, isDark, () => context.push('${RouteNames.followupsListFull}?status=2')),
                      AppSpacing.gapSm,
                      _buildLegendItem(context, 'مكتملة', completed, NeuColors.success, isDark, () => context.push('${RouteNames.followupsListFull}?status=3')),
                      AppSpacing.gapSm,
                      _buildLegendItem(context, 'متأخرة', overdue, NeuColors.danger, isDark, () => context.push('${RouteNames.followupsListFull}?status=4')),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, int count, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.gapHSm,
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Tajawal',
                color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBMPlexSansArabic',
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
