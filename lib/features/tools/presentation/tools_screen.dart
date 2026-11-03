import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/azm_list.dart';
import '../../../shared/widgets/azm_screen.dart';

/// AZM — الأدوات
///
/// عمود TOOLS. يجيب عن: **بماذا أعمل؟**
///
/// التبويبات الأربعة الأخرى تجيب عن «ما حال العمل»؛ هذا يجيب عمّا
/// يُمسَك باليد. وُجد لأن أدوات التطبيق كانت مدفونة في غير بابها:
/// الماسح الضوئي خطوةً داخل «إنشاء معاملة أرشيف»، والبحث العالمي بندًا
/// في «الذكاء»، والروتين اليومي بندًا في «التنفيذ» — ثلاث أدوات تُستعمل
/// وحدها، ولا مكان في التطبيق يقول «هنا الأدوات».
///
/// الفرق بين الأداة والوجهة: الوجهة تُفتح لتُقرأ، والأداة تُفتح لتُنتِج
/// شيئًا ثم تُغلق. لذلك تتصدّر هنا الأدوات المنتِجة، وتأتي بعدها
/// المخازن التي تحفظ ما أنتجته.
class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);

    return AzmScreen(
      title: 'الأدوات',
      caption: 'بماذا تعمل',
      primaryAction: AzmIconAction(
        icon: Icons.search_rounded,
        tooltip: 'بحث',
        onTap: () => context.push(RouteNames.globalSearch),
      ),
      slivers: [
        // ── الالتقاط ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الالتقاط',
            caption: 'ما تُدخله إلى النظام من خارجه',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الماسح الضوئي',
                subtitle: 'صوّر مستندًا وقصّه وحسّنه ثم احفظه',
                icon: Icons.document_scanner_outlined,
                // يفتح شاشة إنشاء المعاملة مباشرةً على خطوة المسح:
                // الأداة هي المقصودة، والأرشفة نتيجتها لا بوّابتها.
                onTap: () => context.push(RouteNames.archiveCreate),
              ),
              AzmNavRow(
                title: 'ملاحظة سريعة',
                subtitle: 'ما تدوّنه قبل أن يضيع',
                icon: Icons.sticky_note_2_outlined,
                onTap: () => context.push(RouteNames.notesList),
              ),
            ],
          ),
        ),

        // ── البحث ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'البحث',
            caption: 'حين تعرف أنّ الشيء موجود ولا تعرف أين',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'البحث العالمي',
                subtitle: 'عبر كل الوحدات دفعةً واحدة',
                icon: Icons.manage_search_rounded,
                onTap: () => context.push(RouteNames.globalSearch),
              ),
              AzmNavRow(
                title: 'الأرشيف',
                subtitle: 'المعاملات الصادرة والواردة',
                icon: Icons.inventory_2_outlined,
                onTap: () => context.push(RouteNames.archiveList),
              ),
            ],
          ),
        ),

        // ── الانضباط ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الانضباط',
            caption: 'ما يتكرّر بلا أن تتذكّره',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الروتين اليومي',
                subtitle: 'الالتزامات المتكرّرة ونسبة إغلاقها',
                icon: Icons.repeat_rounded,
                onTap: () => context.push(RouteNames.routineTasksList),
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

        // ── القراءة ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'القراءة',
            caption: 'ما جرى، مجمَّعًا',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'التقارير',
                subtitle: 'الاجتماعات والمتابعات والتوجيهات',
                icon: Icons.summarize_outlined,
                onTap: () => context.push(RouteNames.reports),
              ),
              AzmNavRow(
                title: 'صحة الأعمال',
                subtitle: 'المؤشّر الواحد وعوامله',
                icon: Icons.monitor_heart_outlined,
                badge: Icon(
                  Icons.north_east_rounded,
                  size: 14,
                  color: p.inkGhost,
                ),
                onTap: () => context.go(RouteNames.insightsFull),
              ),
            ],
          ),
        ),

        // ── النظام ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'النظام',
            caption: 'ما يضبط التطبيق نفسه',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الإعدادات',
                subtitle: 'الحساب والأمان والمظهر والبيانات',
                icon: Icons.settings_outlined,
                onTap: () => context.push(RouteNames.settings),
              ),
              AzmNavRow(
                title: 'السجلّ الأمني',
                subtitle: 'من دخل ومتى ومن أين',
                icon: Icons.shield_outlined,
                onTap: () => context.push(RouteNames.securityLog),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
