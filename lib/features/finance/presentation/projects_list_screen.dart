import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/finance_repository.dart';

/// Projects List Screen — shows active and archived projects.
class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  String _query = '';
  int _statusFilter = -1; // -1 = all
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final projectsAsync = ref.watch(projectsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('المشاريع',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.projectCreate),
            icon: Icon(Icons.add_rounded, color: const Color(0xFFE17055)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: NeuCard(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'بحث في المشاريع...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: NeuColors.textHint),
                ),
              ),
            ),
          ),

          // Status filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildChip('الكل', -1, NeuColors.navyDeep, isDark),
                _buildChip('تخطيط', 0, const Color(0xFF0984E3), isDark),
                _buildChip('نشط', 1, const Color(0xFF00B894), isDark),
                _buildChip('متوقف', 2, const Color(0xFFFDCB6E), isDark),
                _buildChip('مكتمل', 3, const Color(0xFF6C5CE7), isDark),
                _buildChip('ملغي', 4, const Color(0xFFD63031), isDark),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('خطأ: $e',
                    style: AppTypography.bodyMedium.copyWith(color: NeuColors.danger))),
              data: (projects) {
                final filtered = projects.where((p) {
                  final matchQ = _query.isEmpty ||
                      p.name.toLowerCase().contains(_query.toLowerCase()) ||
                      (p.clientName?.toLowerCase().contains(_query.toLowerCase()) ?? false);
                  final matchS = _statusFilter == -1 || p.status == _statusFilter;
                  return matchQ && matchS;
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyProjects(isDark: isDark);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _ProjectCard(
                    project: filtered[i], isDark: isDark,
                    onTap: () => context.push(RouteNames.projectDetailPath(filtered[i].id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.projectCreate),
        backgroundColor: const Color(0xFFE17055),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('مشروع جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildChip(String label, int value, Color color, bool isDark) {
    final selected = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: selected ? null : Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: AppTypography.labelSmall.copyWith(
              color: selected ? Colors.white : color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.isDark, required this.onTap});
  final Project project;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final status = ProjectStatus.fromValue(project.status);
    final progress = project.progress.clamp(0, 100).toDouble();
    final currency = project.currency;

    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.work_rounded, color: status.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name,
                          style: AppTypography.bodyMedium.copyWith(
                              color: textPrimary, fontWeight: FontWeight.w700)),
                      if (project.clientName != null)
                        Text(project.clientName!,
                            style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: status.color.withOpacity(0.3)),
                      ),
                      child: Text(status.arabicLabel,
                          style: AppTypography.labelSmall.copyWith(
                              color: status.color, fontWeight: FontWeight.w700)),
                    ),
                    if (project.contractValue > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppCurrencies.formatAmount(project.contractValue, currency),
                        style: AppTypography.labelSmall.copyWith(
                            color: NeuColors.success, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            if (progress > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التقدم', style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
                  Text('${progress.toInt()}%',
                      style: AppTypography.labelSmall.copyWith(
                          color: status.color, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: status.color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(status.color),
                  minHeight: 6,
                ),
              ),
            ],

            if (project.startDate != null || project.endDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (project.startDate != null)
                    _DateBadge(label: 'البداية', date: project.startDate!, isDark: isDark),
                  if (project.startDate != null && project.endDate != null)
                    const SizedBox(width: 8),
                  if (project.endDate != null)
                    _DateBadge(label: 'النهاية', date: project.endDate!, isDark: isDark),
                  if (project.managerName != null) ...[
                    const Spacer(),
                    Icon(Icons.manage_accounts_rounded, size: 14, color: NeuColors.textHint),
                    const SizedBox(width: 4),
                    Text(project.managerName!,
                        style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.label, required this.date, required this.isDark});
  final String label;
  final String date;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
        Text(date, style: AppTypography.labelSmall.copyWith(color: NeuColors.textPrimary)),
      ],
    ),
  );
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE17055).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.work_rounded, size: 56,
              color: const Color(0xFFE17055).withOpacity(0.4)),
        ),
        const SizedBox(height: 20),
        Text('لا توجد مشاريع',
            style: AppTypography.headingSmall.copyWith(color: NeuColors.textHint)),
        const SizedBox(height: 8),
        Text('أضف أول مشروع بالضغط على الزر أدناه',
            style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
      ],
    ),
  );
}
