import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/neu_button.dart';
import '../../../../shared/widgets/neu_card.dart';
import '../../domain/directives_repository.dart';
import '../../providers/directives_provider.dart';
import '../../../../core/router/route_names.dart';

/// Directive Detail Page — shows full details of a directive.
class DirectiveDetailPage extends ConsumerWidget {
  const DirectiveDetailPage({super.key, required this.directiveId});

  final int directiveId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final directivesAsync = ref.watch(directivesListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'تفاصيل التوجيه',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.directivesList),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color:
                  isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ),
            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context, ref);
              } else if (value == 'edit') {
                context.push(RouteNames.directiveEditPath(directiveId));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded,
                        color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'تعديل التوجيه',
                      style: AppTypography.body.copyWith(
                        color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded,
                        color: NeuColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'حذف التوجيه',
                      style: AppTypography.body.copyWith(
                        color: NeuColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: directivesAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (directives) {
            final directive = directives
                .where((d) => d.id == directiveId)
                .firstOrNull;

            if (directive == null) {
              return const Center(
                  child: Text('التوجيه غير موجود'));
            }

            final status =
                UnifiedStatus.fromValue(directive.status);
            final priority =
                Priority.fromValue(directive.priority);

            return SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  NeuCard(
                    showGoldBorder: true,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          directive.title,
                          style: isDark
                              ? AppTypography.h2Dark
                              : AppTypography.h2,
                        ),
                        AppSpacing.gapMd,
                        Row(
                          children: [
                            _buildBadge(
                              status.arabicLabel,
                              _statusColor(status),
                            ),
                            AppSpacing.gapHSm,
                            _buildBadge(
                              priority.arabicLabel,
                              _priorityColor(priority),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapMd,

                  // Details
                  if (directive.details != null &&
                      directive.details!.isNotEmpty) ...[
                    _buildInfoCard(
                      isDark,
                      'التفاصيل',
                      Icons.description_rounded,
                      directive.details!,
                    ),
                    AppSpacing.gapMd,
                  ],

                  // Source
                  if (directive.source != null &&
                      directive.source!.isNotEmpty) ...[
                    _buildInfoCard(
                      isDark,
                      'المصدر',
                      Icons.badge_rounded,
                      directive.source!,
                    ),
                    AppSpacing.gapMd,
                  ],

                  // Assigned
                  if (directive.assignedTo != null &&
                      directive.assignedTo!.isNotEmpty) ...[
                    _buildInfoCard(
                      isDark,
                      'الجهة المنفذة',
                      Icons.people_rounded,
                      directive.assignedTo!,
                    ),
                    AppSpacing.gapMd,
                  ],

                  // Deadline
                  if (directive.deadline != null &&
                      directive.deadline!.isNotEmpty) ...[
                    _buildInfoCard(
                      isDark,
                      'موعد التنفيذ',
                      Icons.schedule_rounded,
                      directive.deadline!,
                    ),
                    AppSpacing.gapMd,
                  ],

                  AppSpacing.gapLg,

                  // Status update buttons
                  Text(
                    'تحديث الحالة',
                    style: isDark
                        ? AppTypography.h4Dark
                        : AppTypography.h4,
                  ),
                  AppSpacing.gapMd,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      UnifiedStatus.inProgress,
                      UnifiedStatus.completed,
                      UnifiedStatus.overdue,
                      UnifiedStatus.cancelled,
                    ].map((s) {
                      return NeuButton(
                        label: s.arabicLabel,
                        isExpanded: false,
                        variant: s == status
                            ? NeuButtonVariant.primary
                            : NeuButtonVariant.secondary,
                        onPressed: s == status
                            ? null
                            : () {
                                ref
                                    .read(
                                        directivesRepositoryProvider)
                                    .updateStatus(
                                        directive.id, s);
                              },
                      );
                    }).toList(),
                  ),

                  AppSpacing.gapXxl,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      bool isDark, String label, IconData icon, String value) {
    return NeuCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark
                    ? NeuColors.goldAccent
                    : NeuColors.navyDeep,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: isDark
                    ? AppTypography.labelDark
                    : AppTypography.label,
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            value,
            style: isDark
                ? AppTypography.bodyDark
                : AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Panorama',
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف التوجيه',
              style: AppTypography.h3),
          content: const Text(
            'هل أنت متأكد من حذف هذا التوجيه؟',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.danger,
              ),
              onPressed: () {
                ref
                    .read(directivesRepositoryProvider)
                    .deleteDirective(directiveId);
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(UnifiedStatus status) {
    switch (status) {
      case UnifiedStatus.newItem:
        return NeuColors.info;
      case UnifiedStatus.inProgress:
        return NeuColors.warning;
      case UnifiedStatus.awaitingResponse:
        return NeuColors.goldAccent;
      case UnifiedStatus.completed:
        return NeuColors.success;
      case UnifiedStatus.overdue:
        return NeuColors.danger;
      case UnifiedStatus.stalled:
        return NeuColors.priorityHigh;
      case UnifiedStatus.cancelled:
        return NeuColors.textHint;
    }
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return NeuColors.priorityCritical;
      case Priority.high:
        return NeuColors.priorityHigh;
      case Priority.medium:
        return NeuColors.priorityMedium;
      case Priority.low:
        return NeuColors.priorityLow;
    }
  }
}