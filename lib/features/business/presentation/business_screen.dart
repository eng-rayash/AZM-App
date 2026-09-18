import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/azm_list.dart';
import '../../../shared/widgets/azm_screen.dart';
import '../../finance/domain/finance_repository.dart';
import '../../hrm/domain/hrm_repository.dart';

/// AZM — الأعمال
///
/// عمود MANAGE. يجيب عن: **من وماذا أدير؟**
///
/// الترتيب هنا من الخارج إلى الداخل — العميل أولًا لأنه مصدر الإيراد،
/// ثم ما نسلّمه له، ثم من يسلّمه، ثم ما يُقيَّد عن ذلك كله. هذا ترتيب
/// سلسلة القيمة لا ترتيب الوحدات في قاعدة البيانات.
class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);

    final clients = ref.watch(clientsListProvider).valueOrNull;
    final projects = ref.watch(activeProjectsProvider).valueOrNull;
    final employees = ref.watch(employeesListProvider).valueOrNull;
    final overdueInvoices = ref.watch(overdueInvoicesProvider).valueOrNull;

    return AzmScreen(
      title: 'الأعمال',
      caption: 'من وماذا تدير',
      primaryAction: AzmIconAction(
        icon: Icons.search_rounded,
        tooltip: 'بحث',
        onTap: () => context.push(RouteNames.globalSearch),
      ),
      slivers: [
        // ── العملاء والتسليم ──────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'العملاء والتسليم',
            caption: 'من تخدمه وما تسلّمه له',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(rows: [
            AzmNavRow(
              title: 'العملاء',
              subtitle: 'الملف والنشاط والمستحقات',
              icon: Icons.handshake_outlined,
              badge: AzmCount(clients?.length ?? 0),
              onTap: () => context.push(RouteNames.clientsList),
            ),
            AzmNavRow(
              title: 'المشاريع',
              subtitle: 'ما هو قيد التنفيذ الآن',
              icon: Icons.account_tree_outlined,
              badge: AzmCount(projects?.length ?? 0),
              onTap: () => context.push(RouteNames.projectsList),
            ),
            AzmNavRow(
              title: 'الموردون',
              subtitle: 'من تشتري منه',
              icon: Icons.local_shipping_outlined,
              onTap: () => context.push(RouteNames.suppliersList),
            ),
            AzmNavRow(
              title: 'جهات الاتصال',
              subtitle: 'دفتر العلاقات',
              icon: Icons.contacts_outlined,
              onTap: () => context.push(RouteNames.contactsList),
            ),
          ]),
        ),

        // ── المال ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'المال',
            caption: 'ما يدخل وما يخرج وما لم يُحصَّل',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(rows: [
            AzmNavRow(
              title: 'الشؤون المالية',
              subtitle: 'الملخص ومداخل الوحدات المالية',
              icon: Icons.account_balance_outlined,
              onTap: () => context.go(RouteNames.financeFull),
            ),
            AzmNavRow(
              title: 'الفواتير',
              subtitle: 'المُصدَرة والمستحقة والمتأخرة',
              icon: Icons.receipt_long_outlined,
              badge: AzmCount(
                overdueInvoices?.length ?? 0,
                tone: p.danger,
              ),
              onTap: () => context.push(RouteNames.invoicesList),
            ),
            AzmNavRow(
              title: 'المصروفات',
              subtitle: 'ما صُرف ولمن',
              icon: Icons.south_west_rounded,
              onTap: () => context.push(RouteNames.expensesList),
            ),
            AzmNavRow(
              title: 'الإيرادات',
              subtitle: 'ما دخل ومن أين',
              icon: Icons.north_east_rounded,
              onTap: () => context.push(RouteNames.revenuesList),
            ),
          ]),
        ),

        // ── الناس ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الناس',
            caption: 'من ينفّذ، وما له وما عليه',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(rows: [
            AzmNavRow(
              title: 'شؤون العاملين',
              subtitle: 'الملخص ومداخل وحدات الموارد البشرية',
              icon: Icons.badge_outlined,
              onTap: () => context.go(RouteNames.hrmFull),
            ),
            AzmNavRow(
              title: 'الموظفون',
              subtitle: 'الملفات الشخصية',
              icon: Icons.people_outline_rounded,
              badge: AzmCount(employees?.length ?? 0),
              onTap: () => context.push(RouteNames.employeesList),
            ),
            AzmNavRow(
              title: 'الحضور والإجازات',
              subtitle: 'التسجيل اليومي وأرصدة الإجازات',
              icon: Icons.how_to_reg_outlined,
              onTap: () => context.push(RouteNames.attendanceList),
            ),
          ]),
        ),

        // ── الوثائق ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الوثائق',
            caption: 'ما يُحفظ ويُرجع إليه',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(rows: [
            AzmNavRow(
              title: 'الأرشيف',
              subtitle: 'المعاملات الصادرة والواردة بالمسح الضوئي',
              icon: Icons.folder_open_outlined,
              onTap: () => context.push(RouteNames.archiveList),
            ),
            AzmNavRow(
              title: 'الملاحظات',
              subtitle: 'ما دوّنتَه على السريع',
              icon: Icons.sticky_note_2_outlined,
              onTap: () => context.push(RouteNames.notesList),
            ),
          ]),
        ),

        // ── التسجيل الميداني ──────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'التسجيل الميداني',
            caption: 'ما جرى خارج المكتب',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(rows: [
            AzmNavRow(
              title: 'المكالمات',
              icon: Icons.call_outlined,
              onTap: () => context.push(RouteNames.callsList),
            ),
            AzmNavRow(
              title: 'الزيارات',
              icon: Icons.meeting_room_outlined,
              onTap: () => context.push(RouteNames.visitorsList),
            ),
            AzmNavRow(
              title: 'الحركات',
              icon: Icons.directions_car_outlined,
              onTap: () => context.push(RouteNames.movementsList),
            ),
          ]),
        ),
      ],
    );
  }
}
