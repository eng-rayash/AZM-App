import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hijri/hijri_calendar.dart';

import '../../../core/router/route_names.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../reports/providers/reports_provider.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../followups/providers/follow_ups_provider.dart';
import '../providers/periodic_tasks_provider.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../notifications/domain/notification_service.dart';
import '../../notifications/providers/smart_notifications_provider.dart';
import '../../notifications/presentation/notification_center_screen.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../company/providers/company_providers.dart';
import '../../company/presentation/company_switcher.dart';
import 'widgets/executive_health_card.dart';
import 'widgets/kpi_quick_grid.dart';
import 'widgets/executive_performance_chart.dart';

/// RVIOS Executive Dashboard — Business Command Center.
///
/// The main screen showing:
/// - Executive header with date, company, search & notifications
/// - Business Health Score gauge
/// - KPI quick cards (Revenue, Expenses, Projects, Tasks)
/// - Dual-line performance chart with summary
/// - Periodic tasks system
/// - ERP quick links strip
/// - Follow-up distribution donut chart
/// - Daily timeline
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
      if (lastShown == todayStr) return;
      if (!mounted) return;

      final analytics = ref.read(reportsAnalyticsProvider);
      final todayMeetings =
          ref.read(todayMeetingsProvider).valueOrNull?.length ?? 0;

      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.showNotification(
        id: 999,
        title: 'صباح الخير سعادة المدير! 🌟',
        body:
            'لديك اليوم $todayMeetings اجتماعات، و ${analytics.totalTasks} مهام، و ${analytics.upcomingAppointments} مواعيد قادمة.',
      );

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
                    color: isDark ? NeuColors.goldAccent : NeuColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تحديث التطبيق متاح',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'يتوفر إصدار جديد من تطبيق "عزم". يرجى التحديث لضمان الحصول على أحدث الميزات وتحسينات الأمان والأداء.',
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
                                content: Text(
                                    'يتم الآن تحويلك إلى صفحة التحديث...',
                                    textDirection: TextDirection.rtl),
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

    final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);

    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final hijriStr = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    final events = ref.watch(timelineProvider);
    final displayedEvents = events.take(5).toList();

    ref.watch(smartNotificationsSchedulerProvider);

    final bgColor = NeuColors.background(
        isDark ? Brightness.dark : Brightness.light);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Executive Header ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _ExecutiveHeader(
                  dateStr: dateStr,
                  hijriStr: hijriStr,
                  isDark: isDark,
                ),
              ),

              // ── Company Context Banner ──────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final company = ref.watch(activeCompanyProvider);
                    if (company == null) return const SizedBox.shrink();
                    final role = ref.watch(activeMemberRoleProvider);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: _CompanyBanner(
                        companyName: company.name,
                        roleLabel: role.arabicLabel,
                        isDark: isDark,
                        onTap: () => context.push('/company/manage'),
                      ),
                    );
                  },
                ),
              ),

              // ── Greeting ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: _GreetingHeader(
                    dateStr: dateStr,
                    isDark: isDark,
                  ),
                ),
              ),

              // ── Business Health Score ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: ExecutiveHealthCard(isDark: isDark),
                ),
              ),

              // ── KPI Quick Grid (4 cards) ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: KpiQuickGrid(isDark: isDark),
                ),
              ),

              // ── Performance Chart ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ExecutivePerformanceChart(isDark: isDark),
                ),
              ),

              // ── ERP Quick Links ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _ErpQuickLinks(isDark: isDark),
                ),
              ),

              // ── Periodic Tasks System ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _PeriodicTasksCard(),
                ),
              ),

              // ── Follow-ups Distribution ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ref.watch(followUpsListProvider).when(
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (err, _) => Center(
                          child: Text(
                            'خطأ في تحميل إحصائيات المتابعات',
                            style: const TextStyle(
                                color: NeuColors.priorityCritical),
                          ),
                        ),
                        data: (followups) {
                          final newCount =
                              followups.where((f) => f.status == 0).length;
                          final inProgressCount =
                              followups.where((f) => f.status == 1).length;
                          final awaitingResponseCount =
                              followups.where((f) => f.status == 2).length;
                          final completedCount =
                              followups.where((f) => f.status == 3).length;
                          final overdueCount =
                              followups.where((f) => f.status == 4).length;
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

              // ── Daily Timeline Section ────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'السجل الزمني اليومي',
                  icon: Icons.timeline_rounded,
                  actionLabel: 'عرض المخطط',
                  onAction: () => context.push(RouteNames.timeline),
                  isDark: isDark,
                ),
              ),

              // Daily Events list
              displayedEvents.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverList.builder(
                        itemCount: displayedEvents.length,
                        itemBuilder: (context, idx) {
                          final event = displayedEvents[idx];
                          return _TimelineEventTile(
                            event: event,
                            idx: idx,
                            totalCount: displayedEvents.length,
                            isDark: isDark,
                            onTap: () =>
                                _handleEventTap(context, event),
                          );
                        },
                      ),
                    ),

              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEventTap(BuildContext context, TimelineEvent event) {
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Executive Header
// ─────────────────────────────────────────────────────────────────────────────

class _ExecutiveHeader extends ConsumerWidget {
  final String dateStr;
  final String hijriStr;
  final bool isDark;

  const _ExecutiveHeader({
    required this.dateStr,
    required this.hijriStr,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgIcon = isDark ? NeuColors.surfaceDark : Colors.white;
    final iconColor = isDark ? NeuColors.goldAccent : NeuColors.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Company Switcher + Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CompanySwitcher(),
                const SizedBox(height: 3),
                Text(
                  hijriStr,
                  // Secondary, not accent: the brand colour is reserved for
                  // things the reader can act on.
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyBody,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Search Button
          _HeaderIconButton(
            icon: Icons.search_rounded,
            bg: bgIcon,
            color: iconColor,
            isDark: isDark,
            onTap: () => context.push(RouteNames.globalSearch),
          ),
          const SizedBox(width: 8),

          // Notifications Button with badge
          Consumer(
            builder: (_, ref, _) {
              final unreadCount = ref.watch(notificationsProvider.select(
                  (list) => list.where((n) => !n.isRead).length));
              return _HeaderIconButton(
                icon: Icons.notifications_outlined,
                bg: bgIcon,
                color: iconColor,
                isDark: isDark,
                badgeCount: unreadCount,
                onTap: () => context.push(RouteNames.notificationCenter),
              );
            },
          ),
          const SizedBox(width: 8),

          // Settings Button
          _HeaderIconButton(
            icon: Icons.tune_rounded,
            bg: bgIcon,
            color: iconColor,
            isDark: isDark,
            onTap: () => context.push(RouteNames.settings),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;
  final bool isDark;
  final int badgeCount;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.bg,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              left: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: NeuColors.danger,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Panorama',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Company Banner
// ─────────────────────────────────────────────────────────────────────────────

class _CompanyBanner extends StatelessWidget {
  final String companyName;
  final String roleLabel;
  final bool isDark;
  final VoidCallback onTap;

  const _CompanyBanner({
    required this.companyName,
    required this.roleLabel,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [NeuColors.primary, NeuColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: NeuColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    style: const TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    roleLabel,
                    style: TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_outlined,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'إدارة',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamilyBody,
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting Header
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String dateStr;
  final bool isDark;

  const _GreetingHeader({required this.dateStr, required this.isDark});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${_getGreeting()} 👋',
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyHeading,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: TextStyle(
            fontFamily: AppTypography.fontFamilyBody,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [NeuColors.primary, NeuColors.primaryLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? NeuColors.goldAccent : NeuColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyHeading,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? NeuColors.textPrimaryDark
                        : NeuColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? NeuColors.primary.withValues(alpha: 0.15)
                      : NeuColors.primaryTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: NeuColors.primary.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyBody,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? NeuColors.goldAccent : NeuColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERP Quick Links Strip
// ─────────────────────────────────────────────────────────────────────────────

class _ErpQuickLinks extends ConsumerWidget {
  final bool isDark;
  const _ErpQuickLinks({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const modules = [
      _ErpModule(
          icon: Icons.people_alt_rounded,
          label: 'الموارد\nالبشرية',
          color: NeuColors.modulePeople,
          route: RouteNames.hrmFull),
      _ErpModule(
          icon: Icons.receipt_long_rounded,
          label: 'الفواتير',
          color: NeuColors.moduleIncome,
          route: RouteNames.invoicesList),
      _ErpModule(
          icon: Icons.money_off_csred_rounded,
          label: 'المصروفات',
          color: NeuColors.moduleOutgoing,
          route: RouteNames.expensesList),
      _ErpModule(
          icon: Icons.account_balance_wallet_rounded,
          label: 'الإيرادات',
          color: NeuColors.moduleIncome,
          route: RouteNames.revenuesList),
      _ErpModule(
          icon: Icons.rocket_launch_rounded,
          label: 'المشاريع',
          color: NeuColors.moduleDelivery,
          route: RouteNames.projectsList),
      _ErpModule(
          icon: Icons.supervisor_account_rounded,
          label: 'العملاء',
          color: NeuColors.modulePeople,
          route: RouteNames.clientsList),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'نظرة سريعة — ERP',
          icon: Icons.apps_rounded,
          isDark: isDark,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: modules.map((module) {
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _ErpModuleCard(
                  module: module,
                  isDark: isDark,
                  onTap: () => context.push(module.route),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ErpModule {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _ErpModule({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _ErpModuleCard extends StatefulWidget {
  final _ErpModule module;
  final bool isDark;
  final VoidCallback onTap;

  const _ErpModuleCard({
    required this.module,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ErpModuleCard> createState() => _ErpModuleCardState();
}

class _ErpModuleCardState extends State<_ErpModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 86,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isDark ? NeuColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.module.color.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: widget.isDark ? 0.3 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.module.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.module.icon,
                    color: widget.module.color, size: 22),
              ),
              const SizedBox(height: 9),
              Text(
                widget.module.label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyBody,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark
                      ? NeuColors.textSecondaryDark
                      : NeuColors.textSecondary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Periodic Tasks Card
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodicTasksCard extends ConsumerWidget {
  const _PeriodicTasksCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periodicState = ref.watch(periodicTasksProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final completeAction = ref.watch(periodicTaskCompletionProvider);
    final routineToggle = ref.watch(periodicRoutineCompletionProvider);

    final accentColor = isDark ? NeuColors.goldAccent : NeuColors.primary;

    return NeuCard(
      showGoldBorder: true,
      radius: 22,
      elevation: 1,
      padding: const EdgeInsets.all(18),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.checklist_rounded, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'نظام المهام الدورية',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyHeading,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.routineTasksList),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new_rounded, size: 12, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        'فتح',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamilyBody,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Period Tabs
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: TaskPeriod.values.map((period) {
                final isSelected = selectedPeriod == period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(selectedPeriodProvider.notifier)
                        .setPeriod(period),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        '${period.iconLabel} ${period.arabicLabel}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: AppTypography.fontFamilyBody,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? NeuColors.textSecondaryDark
                                  : NeuColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Progress Ring + Stats
          Row(
            children: [
              // Progress Ring
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: periodicState.completionRatio,
                      strokeWidth: 7,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06),
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        periodicState.completionPercent >= 80
                            ? NeuColors.success
                            : periodicState.completionPercent >= 40
                                ? NeuColors.warning
                                : NeuColors.danger,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${periodicState.completionPercent}%',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamilyHeading,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? NeuColors.textPrimaryDark
                                  : NeuColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإنجاز: ${periodicState.completedCount} / ${periodicState.totalCount}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyBody,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? NeuColors.textPrimaryDark
                            : NeuColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      periodicState.totalCount == 0
                          ? 'لا توجد مهام لهذه الفترة'
                          : periodicState.completionPercent >= 80
                              ? '🎉 أداء رائع! استمر'
                              : periodicState.completionPercent >= 40
                                  ? '💪 على الطريق الصحيح'
                                  : '⚡ ابدأ بالمهام الأهم',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyBody,
                        fontSize: 12,
                        color: isDark
                            ? NeuColors.textSecondaryDark
                            : NeuColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tasks list
          if (periodicState.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(
              color: isDark ? NeuColors.dividerDark : NeuColors.divider,
              height: 1,
            ),
            const SizedBox(height: 12),
            ...periodicState.items.take(5).map((item) {
              return _PeriodicTaskTile(
                item: item,
                isDark: isDark,
                onToggle: () {
                  if (item.isRoutine && item.routineTask != null) {
                    routineToggle(item.routineTask!.id, DateTime.now());
                  } else if (!item.isRoutine && item.task != null) {
                    completeAction(item.task!.id, !item.isCompleted);
                  }
                },
              );
            }),
            if (periodicState.items.length > 5)
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      context.go(RouteNames.followupsListFull),
                  icon: const Icon(Icons.expand_more_rounded, size: 16),
                  label: Text(
                    '+${periodicState.items.length - 5} مهام أخرى',
                    style: TextStyle(
                      color: isDark ? NeuColors.goldAccent : NeuColors.primary,
                      fontFamily: AppTypography.fontFamilyBody,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? NeuColors.goldAccent : NeuColors.primary,
                  ),
                ),
              ),
          ] else ...[
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'لا توجد مهام لهذه الفترة',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamilyBody,
                      fontSize: 13,
                      color: isDark
                          ? NeuColors.textSecondaryDark
                          : NeuColors.textSecondary,
                    ),
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

/// Single task tile with completion toggle.
class _PeriodicTaskTile extends StatelessWidget {
  final PeriodicTaskItem item;
  final bool isDark;
  final VoidCallback onToggle;

  const _PeriodicTaskTile({
    required this.item,
    required this.isDark,
    required this.onToggle,
  });

  Color _priorityColor(int priority) {
    switch (priority) {
      case 0:
        return NeuColors.priorityCritical;
      case 1:
        return NeuColors.danger;
      case 2:
        return NeuColors.warning;
      default:
        return NeuColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(item.priorityIndex);
    final textColor = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final textSecondary =
        isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Animated checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isCompleted ? NeuColors.success : Colors.transparent,
                border: Border.all(
                  color: item.isCompleted
                      ? NeuColors.success
                      : (isDark ? NeuColors.dividerDark : NeuColors.divider),
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),

          // Priority dot
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Task title
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyBody,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: item.isCompleted ? textSecondary : textColor,
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: item.isRoutine
                  ? NeuColors.info.withValues(alpha: 0.12)
                  : NeuColors.accentMuted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              item.isRoutine ? '🔄 روتيني' : '⭐ عملي',
              style: TextStyle(
                fontSize: 10,
                fontFamily: AppTypography.fontFamilyBody,
                color: item.isRoutine ? NeuColors.info : NeuColors.accentMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Follow-up Distribution Donut Chart
// ─────────────────────────────────────────────────────────────────────────────

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
    final total =
        newItems + inProgress + awaitingResponse + completed + overdue;
    final awaitingColor = isDark ? NeuColors.goldAccent : NeuColors.moduleDelivery;

    return NeuCard(
      radius: 22,
      padding: const EdgeInsets.all(18),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: NeuColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.donut_large_rounded,
                    color: NeuColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'مخطط المتابعات التنفيذية',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyHeading,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? NeuColors.textPrimaryDark
                      : NeuColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (total == 0)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'لا توجد متابعات تنفيذية مسجلة حتى الآن.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyBody,
                    fontSize: 13,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                // Donut Chart
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 34,
                        startDegreeOffset: -90,
                        sections: [
                          _buildSection(newItems, NeuColors.info),
                          _buildSection(inProgress, NeuColors.warning),
                          _buildSection(awaitingResponse, awaitingColor),
                          _buildSection(completed, NeuColors.success),
                          _buildSection(overdue, NeuColors.danger),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Legend
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                          label: 'جديدة',
                          count: newItems,
                          color: NeuColors.info,
                          isDark: isDark,
                          onTap: () => context.push(
                              '${RouteNames.followupsListFull}?status=0')),
                      const SizedBox(height: 8),
                      _LegendRow(
                          label: 'قيد التنفيذ',
                          count: inProgress,
                          color: NeuColors.warning,
                          isDark: isDark,
                          onTap: () => context.push(
                              '${RouteNames.followupsListFull}?status=1')),
                      const SizedBox(height: 8),
                      _LegendRow(
                          label: 'بانتظار الرد',
                          count: awaitingResponse,
                          color: awaitingColor,
                          isDark: isDark,
                          onTap: () => context.push(
                              '${RouteNames.followupsListFull}?status=2')),
                      const SizedBox(height: 8),
                      _LegendRow(
                          label: 'مكتملة',
                          count: completed,
                          color: NeuColors.success,
                          isDark: isDark,
                          onTap: () => context.push(
                              '${RouteNames.followupsListFull}?status=3')),
                      const SizedBox(height: 8),
                      _LegendRow(
                          label: 'متأخرة',
                          count: overdue,
                          color: NeuColors.danger,
                          isDark: isDark,
                          onTap: () => context.push(
                              '${RouteNames.followupsListFull}?status=4')),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  PieChartSectionData _buildSection(int value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: value > 0 ? '$value' : '',
      radius: 16,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Panorama',
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _LegendRow({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyBody,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? NeuColors.textSecondaryDark
                    : NeuColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyHeading,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline Event Tile
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineEventTile extends StatelessWidget {
  final TimelineEvent event;
  final int idx;
  final int totalCount;
  final bool isDark;
  final VoidCallback onTap;

  const _TimelineEventTile({
    required this.event,
    required this.idx,
    required this.totalCount,
    required this.isDark,
    required this.onTap,
  });

  IconData _getEventIcon(String type) {
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

  Color _getEventColor(String type, bool isDark) {
    switch (type) {
      case 'meeting': return NeuColors.info;
      case 'visitor': return NeuColors.warning;
      case 'movement': return isDark ? NeuColors.goldAccent : NeuColors.primary;
      case 'appointment': return NeuColors.success;
      case 'task': return NeuColors.primaryLight;
      case 'call': return NeuColors.info;
      case 'directive': return NeuColors.danger;
      case 'followup': return NeuColors.priorityCritical;
      default: return NeuColors.accentMuted;
    }
  }

  String _getEventTypeName(String type) {
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

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor(event.type, isDark);
    final icon = _getEventIcon(event.type);
    final typeLabel = _getEventTypeName(event.type);
    final isLast = idx == totalCount - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time column
        SizedBox(
          width: 48,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              event.time,
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyHeading,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? NeuColors.goldAccent : NeuColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Timeline connector
        Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: event.isCompleted ? NeuColors.success : color,
                border: Border.all(
                  color: NeuColors.background(isDark ? Brightness.dark : Brightness.light),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (event.isCompleted ? NeuColors.success : color)
                        .withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 10),

        // Event Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? NeuColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: event.isCompleted ? NeuColors.success : color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamilyBody,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? NeuColors.textPrimaryDark
                                  : NeuColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamilyBody,
                              fontSize: 11,
                              color: isDark
                                  ? NeuColors.textHintDark
                                  : NeuColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (event.isCompleted)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: NeuColors.success.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: NeuColors.success,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}