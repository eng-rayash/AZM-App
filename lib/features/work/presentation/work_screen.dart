import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/azm_list.dart';
import '../../../shared/widgets/azm_screen.dart';
import '../../followups/providers/follow_ups_provider.dart';
import '../../meetings/providers/meetings_provider.dart';

/// AZM — التنفيذ
///
/// عمود EXECUTE. يجيب عن سؤال واحد: **ما الذي يجب تنفيذه؟**
///
/// حلّ محلّ تبويب «المزيد» الذي كان يحمل ٢٣ وجهة في سبع مجموعات — وهو
/// عرَض لا علاج: حين يصير «المزيد» مكبًّا، فالمشكلة في معمار المعلومات
/// لا في القائمة. هنا البنود مجموعة حول ما تفعله لا حول الوحدة التي
/// تنتمي إليها تقنيًا.
class WorkScreen extends ConsumerWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);

    // أعداد حيّة من القاعدة — لا أرقام معروضة بلا مصدر.
    final followUps = ref.watch(followUpsListProvider).valueOrNull;
    final meetings = ref.watch(meetingsListProvider).valueOrNull;

    final openFollowUps =
        followUps?.where((f) => f.status != 3 && f.status != 6).length ?? 0;
    final overdueFollowUps = followUps?.where((f) => f.status == 4).length ?? 0;
    final upcomingMeetings = meetings?.where((m) => m.status == 0).length ?? 0;

    return AzmScreen(
      title: 'التنفيذ',
      caption: 'ما الذي يجب تنفيذه',
      primaryAction: AzmIconAction(
        icon: Icons.search_rounded,
        tooltip: 'بحث',
        onTap: () => context.push(RouteNames.globalSearch),
      ),
      slivers: [
        // ── التنفيذ ───────────────────────────────────────────
        SliverToBoxAdapter(
          // القسم لا يحمل اسم الشاشة: «التنفيذ» داخل «التنفيذ» يضيع
          // معه معنى الفصل بين الأقسام.
          child: AzmSectionHeader(
            title: 'الالتزامات',
            caption: 'ما التزمتَ به وما ينتظر إغلاقًا',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'المتابعات',
                subtitle: 'كل ما هو مفتوح ومسند',
                icon: Icons.checklist_rounded,
                badge: AzmCount(
                  openFollowUps,
                  tone: overdueFollowUps > 0 ? p.danger : null,
                ),
                onTap: () => context.go(RouteNames.followupsListFull),
              ),
              AzmNavRow(
                title: 'التوجيهات',
                subtitle: 'ما وجّهتَ به ولم يُغلق بعد',
                icon: Icons.assignment_turned_in_outlined,
                onTap: () => context.push(RouteNames.directivesList),
              ),
              AzmNavRow(
                title: 'الروتين اليومي',
                subtitle: 'الالتزامات المتكررة',
                icon: Icons.repeat_rounded,
                onTap: () => context.push(RouteNames.routineTasksList),
              ),
            ],
          ),
        ),

        // ── اللقاء والقرار ────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'اللقاء والقرار',
            caption: 'حيث تُتَّخذ القرارات التي تُولّد التنفيذ',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الاجتماعات واللقاءات',
                subtitle: 'جدول الأعمال والقرارات والمخرجات',
                icon: Icons.groups_2_outlined,
                badge: AzmCount(upcomingMeetings),
                onTap: () => context.push(RouteNames.meetingsList),
              ),
              AzmNavRow(
                title: 'المواعيد',
                subtitle: 'ما هو مثبّت في التقويم',
                icon: Icons.event_outlined,
                onTap: () => context.push(RouteNames.appointmentsList),
              ),
              AzmNavRow(
                title: 'الجدول الزمني',
                subtitle: 'أحداث اليوم مرتّبة بالأولوية',
                icon: Icons.timeline_rounded,
                onTap: () => context.push(RouteNames.timeline),
              ),
            ],
          ),
        ),

        // ── الاعتماد ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(title: 'الاعتماد', caption: 'ما ينتظر قرارك'),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الموافقات',
                subtitle: 'طلبات الإجازات والسلف والمشتريات',
                icon: Icons.approval_outlined,
                onTap: () => context.push('/approvals'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
