import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';

/// More Screen — hub for all modules not in the main bottom navigation.
///
/// Provides access to: Meetings, Archive, Contacts, Directives,
/// Appointments, Calls, Visitors, Notes, Movements, Routine Tasks,
/// Reports, Settings, and Search.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(context.brightness);

    final sections = [
      _MoreSection(
        title: 'الإدارة التنفيذية',
        items: [
          _MoreItem(
            title: 'الاجتماعات واللقاءات',
            icon: Icons.groups_rounded,
            color: NeuColors.modulePeople,
            route: RouteNames.meetingsList,
          ),
          _MoreItem(
            title: 'التوجيهات والمعاملات',
            icon: Icons.assignment_rounded,
            color: NeuColors.moduleDelivery,
            route: RouteNames.directivesList,
          ),
          _MoreItem(
            title: 'المواعيد',
            icon: Icons.calendar_today_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.appointmentsList,
          ),
          _MoreItem(
            title: 'الروتين اليومي',
            icon: Icons.loop_rounded,
            color: NeuColors.moduleDelivery,
            route: RouteNames.routineTasksList,
          ),
          _MoreItem(
            title: 'الجدول الزمني',
            icon: Icons.timeline_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.timeline,
          ),
        ],
      ),
      _MoreSection(
        title: 'الاتصالات والزيارات',
        items: [
          _MoreItem(
            title: 'جهات الاتصال',
            icon: Icons.contacts_rounded,
            color: NeuColors.modulePeople,
            route: RouteNames.contactsList,
          ),
          _MoreItem(
            title: 'المكالمات',
            icon: Icons.phone_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.callsList,
          ),
          _MoreItem(
            title: 'الزيارات',
            icon: Icons.person_pin_circle_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.visitorsList,
          ),
          _MoreItem(
            title: 'الحركات الميدانية',
            icon: Icons.directions_car_rounded,
            color: NeuColors.moduleDelivery,
            route: RouteNames.movementsList,
          ),
        ],
      ),
      _MoreSection(
        title: 'الوثائق والأرشيف',
        items: [
          _MoreItem(
            title: 'أرشيف المذكرات',
            icon: Icons.archive_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.archiveList,
          ),
          _MoreItem(
            title: 'الملاحظات',
            icon: Icons.sticky_note_2_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.notesList,
          ),
        ],
      ),
      _MoreSection(
        title: 'التقارير والتحليلات',
        items: [
          _MoreItem(
            title: 'التقارير العامة',
            icon: Icons.analytics_rounded,
            color: NeuColors.moduleInsight,
            route: RouteNames.reports,
          ),
          _MoreItem(
            title: 'تقارير الموارد البشرية',
            icon: Icons.people_outline_rounded,
            color: NeuColors.moduleInsight,
            route: RouteNames.hrmReports,
          ),
          _MoreItem(
            title: 'التقارير المالية',
            icon: Icons.bar_chart_rounded,
            color: NeuColors.moduleInsight,
            route: RouteNames.financeReports,
          ),
        ],
      ),
      _MoreSection(
        title: 'المحاسبة المتقدمة',
        items: [
          _MoreItem(
            title: 'دليل الحسابات',
            icon: Icons.account_tree_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.chartOfAccounts,
          ),
          _MoreItem(
            title: 'القيود اليومية',
            icon: Icons.receipt_long_rounded,
            color: NeuColors.moduleStructure,
            route: RouteNames.journalEntries,
          ),
          _MoreItem(
            title: 'السندات',
            icon: Icons.receipt_rounded,
            color: NeuColors.moduleIncome,
            route: RouteNames.paymentVouchersList,
          ),
          _MoreItem(
            title: 'الموردون',
            icon: Icons.local_shipping_rounded,
            color: NeuColors.moduleOutgoing,
            route: RouteNames.suppliersList,
          ),
        ],
      ),
      _MoreSection(
        title: 'منصة RVIOS',
        items: [
          _MoreItem(
            title: 'نظام الموافقات',
            icon: Icons.approval_rounded,
            color: NeuColors.primary,
            route: '/approvals',
          ),
          _MoreItem(
            title: 'إدارة الشركة',
            icon: Icons.business_rounded,
            color: NeuColors.primaryMid,
            route: '/company/manage',
          ),
          _MoreItem(
            title: 'إدارة الوحدات',
            icon: Icons.layers_rounded,
            color: NeuColors.accentMuted,
            route: '/settings/modules',
          ),
          _MoreItem(
            title: 'باقات الاشتراك',
            icon: Icons.workspace_premium_rounded,
            color: NeuColors.goldDark,
            route: '/subscription/pricing',
          ),
        ],
      ),
      _MoreSection(
        title: 'النظام',
        items: [
          _MoreItem(
            title: 'البحث العالمي',
            icon: Icons.search_rounded,
            color: NeuColors.navyDeep,
            route: RouteNames.globalSearch,
          ),
          _MoreItem(
            title: 'مركز الإشعارات',
            icon: Icons.notifications_rounded,
            color: NeuColors.warning,
            route: RouteNames.notificationCenter,
          ),
          _MoreItem(
            title: 'الإعدادات',
            icon: Icons.settings_rounded,
            color: NeuColors.textSecondary,
            route: RouteNames.settings,
          ),
          _MoreItem(
            title: 'سجل الأمان',
            icon: Icons.security_rounded,
            color: NeuColors.danger,
            route: RouteNames.securityLog,
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: NeuColors.background(context.brightness),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Text(
                      'المزيد',
                      style: AppTypography.h1.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push(RouteNames.globalSearch),
                      icon: Icon(
                        Icons.search_rounded,
                        color: NeuColors.navyDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sections ─────────────────────────────────────────────
            for (final section in sections) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Text(
                    section.title,
                    style: AppTypography.labelMedium.copyWith(
                      color: NeuColors.textHint,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NeuCard(
                    isDark: isDark,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: section.items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final isLast = idx == section.items.length - 1;
                        return _MoreTile(
                          item: item,
                          isDark: isDark,
                          showDivider: !isLast,
                          onTap: () => context.push(item.route),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────

class _MoreSection {
  const _MoreSection({required this.title, required this.items});
  final String title;
  final List<_MoreItem> items;
}

class _MoreItem {
  const _MoreItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
  final String title;
  final IconData icon;
  final Color color;
  final String route;
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.item,
    required this.isDark,
    required this.showDivider,
    required this.onTap,
  });

  final _MoreItem item;
  final bool isDark;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(context.brightness);

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          title: Text(
            item.title,
            style: AppTypography.bodyMedium.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: NeuColors.textHint,
                size: 18,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 56,
            color: isDark ? NeuColors.dividerDark : NeuColors.divider,
          ),
      ],
    );
  }
}

extension on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
}