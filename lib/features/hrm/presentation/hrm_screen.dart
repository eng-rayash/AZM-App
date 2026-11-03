import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/azm_list.dart';
import '../../../shared/widgets/azm_screen.dart';
import '../domain/hrm_repository.dart';

/// AZM — الفريق
///
/// عمود PEOPLE. يجيب عن: **من ينفّذ، وما له وما عليه؟**
///
/// كان هذا تبويبًا مدفونًا: اثنتا عشرة وجهة تعيش خلف بند واحد في
/// «الأعمال»، وهي أكبر مجموعة في التطبيق. رفعه إلى الشريط السفلي يعني
/// أن أكبر ما في التطبيق صار في متناول الإبهام لا خلف ثلاث ضغطات.
///
/// والترتيب هنا بالدورة لا بالوحدة: من يعمل معنا، ثم حضوره ووقته، ثم
/// ما يُستحَقّ له، ثم كيف ينمو، ثم الهيكل الذي يجلس فيه.
class HrmScreen extends ConsumerWidget {
  const HrmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);

    // أعداد حيّة من القاعدة — لا أرقام معروضة بلا مصدر.
    final employees = ref.watch(employeesListProvider).valueOrNull;
    final headcount = employees?.length ?? 0;

    return AzmScreen(
      title: 'الفريق',
      caption: 'من ينفّذ وما له وما عليه',
      primaryAction: AzmIconAction(
        icon: Icons.person_add_alt_1_rounded,
        tooltip: 'موظف جديد',
        onTap: () => context.push(RouteNames.employeeCreate),
      ),
      slivers: [
        // ── من يعمل معنا ──────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'من يعمل معنا',
            caption: 'الملفات والعقود',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الموظفون',
                subtitle: 'الملفات الشخصية والبيانات الوظيفية',
                icon: Icons.badge_outlined,
                badge: AzmCount(headcount),
                onTap: () => context.push(RouteNames.employeesList),
              ),
              AzmNavRow(
                title: 'العقود',
                subtitle: 'المدد والتجديد وما يقترب من الانتهاء',
                icon: Icons.description_outlined,
                onTap: () => context.push(RouteNames.contractsList),
              ),
            ],
          ),
        ),

        // ── الوقت ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الوقت',
            caption: 'من حضر ومن غاب ومن في إجازة',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الحضور والانصراف',
                subtitle: 'التسجيل اليومي والتأخّر',
                icon: Icons.schedule_outlined,
                onTap: () => context.push(RouteNames.attendanceList),
              ),
              AzmNavRow(
                title: 'الإجازات',
                subtitle: 'الأرصدة والطلبات المعلّقة',
                icon: Icons.beach_access_outlined,
                onTap: () => context.push(RouteNames.leavesList),
              ),
            ],
          ),
        ),

        // ── ما يُستحَقّ ───────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'ما يُستحَقّ',
            caption: 'الرواتب وما يُصرف قبلها أو معها',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الرواتب',
                subtitle: 'مسير الرواتب والبدلات والخصومات',
                icon: Icons.payments_outlined,
                onTap: () => context.push(RouteNames.salariesList),
              ),
              AzmNavRow(
                title: 'السلف',
                subtitle: 'المصروف مقدّمًا وما تبقّى منه',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => context.push(RouteNames.advancesList),
              ),
              AzmNavRow(
                title: 'المكافآت والجزاءات',
                subtitle: 'ما زاد وما نقص عن الأصل',
                icon: Icons.gavel_outlined,
                onTap: () => context.push(RouteNames.rewardsPenaltiesList),
              ),
            ],
          ),
        ),

        // ── النموّ ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'النموّ',
            caption: 'كيف يتطوّر من يعمل معك',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'التقييم',
                subtitle: 'دورات تقييم الأداء ونتائجها',
                icon: Icons.star_outline_rounded,
                onTap: () => context.push(RouteNames.evaluationsList),
              ),
              AzmNavRow(
                title: 'التدريب',
                subtitle: 'البرامج والمشاركون',
                icon: Icons.school_outlined,
                onTap: () => context.push(RouteNames.trainingsList),
              ),
            ],
          ),
        ),

        // ── الهيكل ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الهيكل',
            caption: 'أين يجلس كلٌّ في التنظيم',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الأقسام',
                subtitle: 'الهيكل التنظيمي والتبعية',
                icon: Icons.account_tree_outlined,
                onTap: () => context.push(RouteNames.departmentsList),
              ),
              AzmNavRow(
                title: 'الفروع',
                subtitle: 'المواقع والمكاتب',
                icon: Icons.location_city_outlined,
                onTap: () => context.push(RouteNames.branchesList),
              ),
              AzmNavRow(
                title: 'تقارير الموارد',
                subtitle: 'القوى العاملة والحضور والتكلفة',
                icon: Icons.insert_chart_outlined_rounded,
                // التقارير آخر القائمة لا أوّلها: تُقرأ بعد أن تُدار
                // الدورة لا قبلها.
                badge: Icon(
                  Icons.north_east_rounded,
                  size: 14,
                  color: p.inkGhost,
                ),
                onTap: () => context.push(RouteNames.hrmReports),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
