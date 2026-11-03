import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/priority_chip.dart';
import '../providers/tasks_provider.dart';
import '../domain/tasks_repository.dart';
import '../../../core/design/azm_tokens.dart';

/// Task Detail Screen
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskDetailProvider(taskId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.followupsListFull),
        ),
        title: Text(
          'تفاصيل المهمة',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ),
            onPressed: taskState.valueOrNull != null
                ? () => context.push(RouteNames.taskEditPath(taskId))
                : null,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ),
            onPressed: taskState.valueOrNull != null
                ? () => _showMoreOptions(context, ref, taskState.valueOrNull!)
                : null,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err', style: isDark ? AppTypography.bodyDark : AppTypography.body)),
          data: (task) {
            if (task == null) {
              return Center(child: Text('المهمة غير موجودة أو تم حذفها', style: isDark ? AppTypography.bodyDark : AppTypography.body));
            }

            final status = UnifiedStatus.fromValue(task.status);
            final priority = Priority.fromValue(task.priority);

            return ListView(
              padding: AppSpacing.screen,
              children: [
                NeuCard(
                  showGoldBorder: true,
                  radius: AzmRadius.sm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                                decoration: status == UnifiedStatus.completed ? TextDecoration.lineThrough : null,
                                color: status == UnifiedStatus.completed 
                                    ? (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary) 
                                    : (isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
                              ),
                            ),
                          ),
                          AppSpacing.gapHSm,
                          PriorityChip(priority: priority),
                        ],
                      ),
                      AppSpacing.gapMd,
                      _buildInfoRow(context, Icons.info_outline_rounded, 'الحالة', status.arabicLabel),
                      if (task.dueDate?.isNotEmpty == true) ...[
                        AppSpacing.gapSm,
                        _buildInfoRow(context, Icons.calendar_today_rounded, 'تاريخ التسليم', task.dueDate!),
                      ],
                      if (task.assignedTo?.isNotEmpty == true) ...[
                        AppSpacing.gapSm,
                        _buildInfoRow(context, Icons.person_outline_rounded, 'المسؤول', task.assignedTo!),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapMd,

                if (task.description?.isNotEmpty == true) ...[
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الوصف', style: isDark ? AppTypography.h4Dark : AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(
                          task.description!, 
                          style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapMd,
                ],
                
                // Status Selector Block
                NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تحديث حالة المهمة',
                        style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                      ),
                      AppSpacing.gapSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: UnifiedStatus.values.map((statusVal) {
                            final isSelected = statusVal.value == task.status;
                            final color = switch (statusVal) {
                              UnifiedStatus.newItem => NeuColors.info,
                              UnifiedStatus.inProgress => NeuColors.warning,
                              UnifiedStatus.awaitingResponse => NeuColors.warning,
                              UnifiedStatus.completed => NeuColors.success,
                              UnifiedStatus.overdue => NeuColors.danger,
                              UnifiedStatus.stalled => isDark ? NeuColors.navyLight : NeuColors.navyMid,
                              UnifiedStatus.cancelled => NeuColors.danger,
                            };
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  if (isSelected) return;
                                  try {
                                    await ref
                                        .read(tasksRepositoryProvider)
                                        .updateStatus(taskId, statusVal);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'تم تحديث الحالة إلى: ${statusVal.arabicLabel}',
                                            textDirection: TextDirection.rtl,
                                          ),
                                          backgroundColor: NeuColors.success,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('حدث خطأ: $e'),
                                          backgroundColor: NeuColors.danger,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withAlpha(isDark ? 35 : 25)
                                        : (isDark
                                            ? NeuColors.surfaceDark
                                            : NeuColors.surface),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : (isDark
                                              ? NeuColors.dividerDark
                                              : NeuColors.divider),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: isDark
                                                  ? NeuColors.shadowDarkDark
                                                  : NeuColors.shadowDark,
                                              offset: const Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: isDark
                                                  ? NeuColors.shadowLightDark
                                                  : NeuColors.shadowLight,
                                              offset: const Offset(-2, -2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                  ),
                                  child: Text(
                                    statusVal.arabicLabel,
                                    style: (isDark
                                            ? AppTypography.bodySmallDark
                                            : AppTypography.bodySmall)
                                        .copyWith(
                                      color: isSelected
                                          ? color
                                          : (isDark
                                              ? NeuColors.textSecondaryDark
                                              : NeuColors.textSecondary),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon, 
          size: 18, 
          color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
        ),
        AppSpacing.gapHSm,
        Text(
          '$label: ', 
          style: isDark ? AppTypography.labelDark : AppTypography.label,
        ),
        Expanded(
          child: Text(
            value, 
            style: isDark ? AppTypography.bodyDark : AppTypography.body,
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, dynamic task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.undo_rounded, color: NeuColors.warning),
                title: Text(
                  'إعادة فتح المهمة', 
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                ),
                onTap: () {
                  ref.read(tasksRepositoryProvider).updateStatus(taskId, UnifiedStatus.inProgress);
                  ctx.pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: NeuColors.danger),
                title: Text(
                  'حذف المهمة', 
                  style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                    color: NeuColors.danger, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  ctx.pop();
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          title: Text(
            'حذف المهمة', 
            style: isDark ? AppTypography.h3Dark : AppTypography.h3,
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذه المهمة نهائياً؟', 
            style: isDark ? AppTypography.bodyDark : AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(), 
              child: Text(
                'تراجع',
                style: TextStyle(
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                  fontFamily: AppTypography.fontFamilyBody,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(tasksRepositoryProvider).deleteTask(taskId);
                ctx.pop();
                context.pop(); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المهمة')));
              },
              child: const Text('حذف', style: TextStyle(color: NeuColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}