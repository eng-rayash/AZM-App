import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/priority_chip.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../../shared/widgets/export_button.dart';
import '../../reports/domain/export_service.dart';
import '../../../shared/widgets/sort_menu.dart';

import '../domain/follow_ups_repository.dart';
import '../providers/follow_ups_provider.dart';
import '../../../core/database/app_database.dart';

/// Follow-ups List Screen — displays all active follow-ups with search, filter, and premium export.
/// Offers full interactive details sheet, instant status update, and confirmation dialogs.
class FollowupsListScreen extends ConsumerStatefulWidget {
  const FollowupsListScreen({super.key});

  @override
  ConsumerState<FollowupsListScreen> createState() =>
      _FollowupsListScreenState();
}

class _FollowupsListScreenState extends ConsumerState<FollowupsListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  final Set<int> _selectedIds = {};
  int _selectedSortIndex = 0;

  static final List<SortOption> _sortOptions = [
    SortOption(
      'الأحدث تاريخاً',
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ),
    SortOption(
      'الأقدم تاريخاً',
      (a, b) => a.createdAt.compareTo(b.createdAt),
    ),
    SortOption(
      'الموضوع (أبجدي)',
      (a, b) => a.title.compareTo(b.title),
    ),
    SortOption(
      'الأهمية (هام أولاً)',
      (a, b) => a.priority.compareTo(b.priority),
    ),
    SortOption(
      'الحالة',
      (a, b) => a.status.compareTo(b.status),
    ),
  ];


  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'جديد', value: '0'),
    FilterOption(label: 'قيد التنفيذ', value: '1'),
    FilterOption(label: 'بانتظار الرد', value: '2'),
    FilterOption(label: 'مكتمل', value: '3'),
    FilterOption(label: 'متأخر', value: '4'),
  ];

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // Open high-end bottom sheet detailing the follow-up and offering quick updates
  void _showFollowUpDetailsBottomSheet(BuildContext context, FollowUp followup) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priority = Priority.fromValue(followup.priority);
    final type = FollowUpEntityType.fromValue(followup.entityType);

    final priorityColor = priority == Priority.critical
        ? NeuColors.priorityCritical
        : priority == Priority.high
            ? NeuColors.priorityHigh
            : priority == Priority.medium
            ? NeuColors.priorityMedium
            : NeuColors.priorityLow;

    UnifiedStatus currentStatus = UnifiedStatus.fromValue(followup.status);

    // Decode notes JSON
    String notesGeneral = '';
    String executedProgress = '';
    String obstaclesText = '';

    if (followup.notes != null && followup.notes!.isNotEmpty) {
      try {
        final decoded = json.decode(followup.notes!);
        if (decoded is Map) {
          notesGeneral = decoded['general']?.toString() ?? '';
          executedProgress = decoded['executed']?.toString() ?? '';
          obstaclesText = decoded['obstacles']?.toString() ?? '';
        } else {
          notesGeneral = followup.notes!;
        }
      } catch (_) {
        notesGeneral = followup.notes!;
      }
    }

    final generalCtrl = TextEditingController(text: notesGeneral);
    final executedCtrl = TextEditingController(text: executedProgress);
    final obstaclesCtrl = TextEditingController(text: obstaclesText);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Decorative Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Title & Delete Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تفاصيل وإجراءات المتابعة الذكية',
                        style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: NeuColors.priorityCritical, size: 24),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _confirmDelete(context, followup);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Topic Card
                  NeuCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'موضوع المتابعة',
                          style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                            color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          followup.title,
                          style: (isDark ? AppTypography.h4Dark : AppTypography.h4).copyWith(
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Target Entity & Assigned To
                  Row(
                    children: [
                      Expanded(
                        child: NeuCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.business_rounded, size: 14, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                                  const SizedBox(width: 6),
                                  Text('الجهة المسؤولة', style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                followup.assignedTo != null && followup.assignedTo!.isNotEmpty
                                    ? followup.assignedTo!
                                    : 'غير محدد',
                                style: isDark ? AppTypography.bodyDark : AppTypography.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeuCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                                  const SizedBox(width: 6),
                                  Text('تاريخ الاستحقاق', style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                followup.targetDate != null && followup.targetDate!.isNotEmpty
                                    ? followup.targetDate!
                                    : 'غير محدد',
                                style: isDark ? AppTypography.bodyDark : AppTypography.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Associated Entity & Priority
                  Row(
                    children: [
                      Expanded(
                        child: NeuCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.link_rounded, size: 14, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                                  const SizedBox(width: 6),
                                  Text('المرتبط بـ', style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    type.arabicLabel,
                                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                                  ),
                                  const Spacer(),
                                  if (followup.entityId != null)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        if (type == FollowUpEntityType.meeting) {
                                          context.push(RouteNames.meetingDetailPath(followup.entityId!));
                                        } else if (type == FollowUpEntityType.task) {
                                          context.push(RouteNames.taskDetailPath(followup.entityId!));
                                        } else if (type == FollowUpEntityType.directive) {
                                          context.push(RouteNames.directiveDetailPath(followup.entityId!));
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isDark ? NeuColors.goldAccent.withAlpha(30) : NeuColors.navyDeep.withAlpha(20),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'انتقال للمصدر 🔗',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeuCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.priority_high_rounded, size: 14, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                                  const SizedBox(width: 6),
                                  Text('الأهمية', style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                priority.arabicLabel,
                                style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Remaining Time & Duration Tracker
                  NeuCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 16, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                            const SizedBox(width: 8),
                            Text('الزمن المتبقي للتنفيذ:', style: isDark ? AppTypography.bodyDark : AppTypography.body),
                          ],
                        ),
                        _buildRemainingTimeWidget(followup.targetDate, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Smart Fields: General Notes, Achievements (Executed), and Obstacles
                  Text(
                    'المتابعة الذكية للتنفيذ:',
                    style: (isDark ? AppTypography.labelDark : AppTypography.label).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Editable General Notes
                  TextField(
                    controller: generalCtrl,
                    maxLines: 2,
                    textDirection: TextDirection.rtl,
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات عامة',
                      labelStyle: TextStyle(color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                      filled: true,
                      fillColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Editable Achievements (What has been executed)
                  TextField(
                    controller: executedCtrl,
                    maxLines: 2,
                    textDirection: TextDirection.rtl,
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    decoration: InputDecoration(
                      labelText: 'ما تم إنجازه وتنفيذه حتى الآن',
                      labelStyle: const TextStyle(color: NeuColors.success),
                      filled: true,
                      fillColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Editable Obstacles
                  TextField(
                    controller: obstaclesCtrl,
                    maxLines: 2,
                    textDirection: TextDirection.rtl,
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    decoration: InputDecoration(
                      labelText: 'العوائق والصعوبات القائمة',
                      labelStyle: const TextStyle(color: NeuColors.priorityCritical),
                      filled: true,
                      fillColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Status Update
                  Text(
                    'تعديل حالة المتابعة:',
                    style: (isDark ? AppTypography.labelDark : AppTypography.label).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (context, setModalState) {
                      final statuses = [
                        UnifiedStatus.newItem,
                        UnifiedStatus.inProgress,
                        UnifiedStatus.awaitingResponse,
                        UnifiedStatus.completed,
                        UnifiedStatus.overdue,
                      ];

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: statuses.map((statusVal) {
                            final isSelected = currentStatus == statusVal;

                            Color statusColor = NeuColors.navyMid;
                            if (statusVal == UnifiedStatus.newItem) statusColor = NeuColors.goldAccent;
                            if (statusVal == UnifiedStatus.inProgress) statusColor = NeuColors.navyDeep;
                            if (statusVal == UnifiedStatus.awaitingResponse) statusColor = NeuColors.goldAccent;
                            if (statusVal == UnifiedStatus.completed) statusColor = NeuColors.success;
                            if (statusVal == UnifiedStatus.overdue) statusColor = NeuColors.priorityCritical;

                            return Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  try {
                                    await ref.read(followUpsRepositoryProvider).updateStatus(followup.id, statusVal);
                                    setModalState(() {
                                      currentStatus = statusVal;
                                    });
                                    if (context.mounted) {
                                      final hasLinked = followup.entityId != null && 
                                          FollowUpEntityType.fromValue(followup.entityType) != FollowUpEntityType.other;
                                      final msg = (statusVal == UnifiedStatus.completed && hasLinked)
                                          ? 'تم تحديث حالة المتابعة والكيان المرتبط إلى "مكتمل" بنجاح'
                                          : 'تم تحديث حالة المتابعة إلى "${statusVal.arabicLabel}" بنجاح';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(msg, textDirection: TextDirection.rtl),
                                          backgroundColor: NeuColors.navyDeep,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('فشل التحديث: $e', textDirection: TextDirection.rtl),
                                          backgroundColor: NeuColors.priorityCritical,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                    color: isDark ? statusColor.withValues(alpha: 0.2) : statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor, width: 1.5),
                                  )
                                      : BoxDecoration(
                                    color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.transparent, width: 1.5),
                                  ),
                                  child: Text(
                                    statusVal.arabicLabel,
                                    style: TextStyle(
                                      color: isSelected
                                          ? statusColor
                                          : (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary),
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Save Smart Fields Button
                  SizedBox(
                    width: double.infinity,
                    child: NeuButton(
                      label: 'حفظ الملاحظات والإجراءات الذكية',
                      icon: Icons.save_rounded,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(ctx);
                        try {
                          final newNotesEncoded = jsonEncode({
                            'general': generalCtrl.text.trim(),
                            'executed': executedCtrl.text.trim(),
                            'obstacles': obstaclesCtrl.text.trim(),
                          });

                          await ref.read(followUpsRepositoryProvider).updateFollowUp(
                            id: followup.id,
                            title: followup.title,
                            type: FollowUpEntityType.fromValue(followup.entityType),
                            priority: Priority.fromValue(followup.priority),
                            notes: newNotesEncoded,
                            targetDate: followup.targetDate,
                            entityId: followup.entityId,
                            assignedTo: followup.assignedTo,
                          );

                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ الإجراءات والمتابعة بنجاح'),
                              backgroundColor: NeuColors.success,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ أثناء الحفظ: $e'),
                              backgroundColor: NeuColors.priorityCritical,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRemainingTimeWidget(String? targetDateStr, bool isDark) {
    if (targetDateStr == null || targetDateStr.isEmpty) {
      return Text('غير محدد', style: isDark ? AppTypography.bodyDark : AppTypography.body);
    }
    try {
      final dueDate = DateTime.parse(targetDateStr);
      final now = DateTime.now();
      final difference = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;

      String label;
      Color color;

      if (difference < 0) {
        label = 'متأخر بمقدار ${difference.abs()} يوم';
        color = NeuColors.priorityCritical;
      } else if (difference == 0) {
        label = 'يستحق اليوم';
        color = NeuColors.priorityHigh;
      } else if (difference == 1) {
        label = 'يستحق غداً';
        color = NeuColors.priorityHigh;
      } else {
        label = 'متبقي $difference يوم';
        if (difference <= 2) {
          color = NeuColors.priorityCritical;
        } else if (difference <= 7) {
          color = NeuColors.warning;
        } else {
          color = NeuColors.success;
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Tajawal',
          ),
        ),
      );
    } catch (_) {
      return Text(targetDateStr, style: isDark ? AppTypography.bodyDark : AppTypography.body);
    }
  }

  // Soft delete confirmation
  Future<void> _confirmDelete(BuildContext context, FollowUp doc) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
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
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: NeuColors.priorityCritical,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حذف المتابعة',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      color: NeuColors.priorityCritical,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف المتابعة "${doc.title}" نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: NeuButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            try {
                              await ref.read(followUpsRepositoryProvider).deleteFollowUp(doc.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم حذف المتابعة بنجاح', textDirection: TextDirection.rtl),
                                    backgroundColor: NeuColors.priorityCritical,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('فشل الحذف: $e', textDirection: TextDirection.rtl),
                                    backgroundColor: NeuColors.priorityCritical,
                                  ),
                                );
                              }
                            }
                          },
                          label: 'تأكيد الحذف',
                          variant: NeuButtonVariant.danger,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NeuButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          label: 'إلغاء',
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

  Future<void> _confirmDeleteSelected(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
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
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: NeuColors.priorityCritical,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تأكيد الحذف',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      color: NeuColors.priorityCritical,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف المتابعات المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: NeuButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _deleteSelectedItems();
                          },
                          label: 'حذف',
                          variant: NeuButtonVariant.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeuButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          label: 'إلغاء',
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

  Future<void> _deleteSelectedItems() async {
    try {
      final repo = ref.read(followUpsRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteFollowUp(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المتابعات المحددة بنجاح', textDirection: TextDirection.rtl),
            backgroundColor: NeuColors.priorityCritical,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحذف: $e', textDirection: TextDirection.rtl),
            backgroundColor: NeuColors.priorityCritical,
          ),
        );
      }
    }
  }

  bool _initializedStatusFromRoute = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final followupsState = ref.watch(followUpsListProvider);

    final statusParam = GoRouterState.of(context).uri.queryParameters['status'];
    if (!_initializedStatusFromRoute && statusParam != null) {
      _statusFilter = statusParam;
      _initializedStatusFromRoute = true;
    }

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: _selectedIds.isEmpty,
        leading: _selectedIds.isEmpty
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: Icon(Icons.close_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => setState(() => _selectedIds.clear()),
              ),
        title: _selectedIds.isEmpty
            ? Text('المتابعات التنفيذية', style: isDark ? AppTypography.h3Dark : AppTypography.h3)
            : Text('تم تحديد ${_selectedIds.length}', style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        actions: [
          followupsState.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (followups) {
              var filteredDocs = followups.toList();
              // Let's filter correctly using the standard:
              filteredDocs = filteredDocs.where((f) {
                if (_statusFilter != 'all') {
                  final statusVal = int.tryParse(_statusFilter);
                  if (statusVal != null && f.status != statusVal) return false;
                }
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  final matches = f.title.toLowerCase().contains(q) ||
                      (f.notes ?? '').toLowerCase().contains(q) ||
                      (f.targetDate ?? '').contains(q);
                  if (!matches) return false;
                }
                return true;
              }).toList();

              if (_selectedIds.isEmpty) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SortMenu(
                      options: _sortOptions,
                      selectedIndex: _selectedSortIndex,
                      onSelected: (index) => setState(() => _selectedSortIndex = index),
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _selectedIds.length == filteredDocs.length
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                        color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_selectedIds.length == filteredDocs.length) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds.addAll(filteredDocs.map((f) => f.id));
                          }
                        });
                      },
                    ),
                    ExportButton(
                      itemCount: _selectedIds.length,
                      onExport: (format) async {
                        final selectedItems = filteredDocs
                            .where((f) => _selectedIds.contains(f.id))
                            .toList();
                        final exportService = ref.read(exportServiceProvider);
                        await exportService.exportDataList<FollowUp>(
                          context: context,
                          title: 'متابعات الإدارة التنفيذية المحددة',
                          items: selectedItems,
                          headers: [
                            'م',
                            'الموضوع',
                            'النوع المرتبط',
                            'الجهة المسؤولة',
                            'تاريخ الاستحقاق',
                            'الأولوية',
                            'الحالة',
                            'الملاحظات'
                          ],
                          itemMapper: (list) => List.generate(list.length, (idx) {
                            final f = list[idx];
                            return [
                              '${idx + 1}',
                              f.title,
                              FollowUpEntityType.fromValue(f.entityType).arabicLabel,
                              f.assignedTo ?? 'غير محدد',
                              f.targetDate ?? 'غير محدد',
                              Priority.fromValue(f.priority).arabicLabel,
                              UnifiedStatus.fromValue(f.status).arabicLabel,
                              f.notes ?? '',
                            ];
                          }),
                          format: format,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: NeuColors.priorityCritical,
                      ),
                      onPressed: () => _confirmDeleteSelected(context),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter
            SearchFilterBar(
              searchHint: 'بحث في المتابعات...',
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _statusFilter,
              onFilterChanged: (v) => setState(() => _statusFilter = v),
            ),
            AppSpacing.gapMd,

            // Follow-ups List
            Expanded(
              child: followupsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('خطأ: $err', style: const TextStyle(color: NeuColors.priorityCritical))),
                data: (followups) {
                  var filtered = followups.toList();

                  // Status filter
                  if (_statusFilter != 'all') {
                    final statusVal = int.tryParse(_statusFilter);
                    if (statusVal != null) {
                      filtered = filtered.where((f) => f.status == statusVal).toList();
                    }
                  }

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((f) {
                      return f.title.toLowerCase().contains(q) ||
                          (f.notes ?? '').toLowerCase().contains(q) ||
                          (f.targetDate ?? '').contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded,
                              size: 64,
                              color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                          AppSpacing.gapMd,
                          Text(
                            _searchQuery.isNotEmpty || _statusFilter != 'all'
                                ? 'لا توجد نتائج مطابقة لبحثك'
                                : 'لا توجد متابعات تنفيذية حالياً',
                            style: AppTypography.body.copyWith(
                                color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                          ),
                          if (_searchQuery.isEmpty && _statusFilter == 'all') ...[
                            AppSpacing.gapLg,
                            NeuButton(
                              label: 'إضافة متابعة جديدة',
                              onPressed: () => context.push(RouteNames.followupCreate),
                              icon: Icons.add_rounded,
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screen,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final followup = filtered[index];
                      final priority = Priority.fromValue(followup.priority);
                      final status = UnifiedStatus.fromValue(followup.status);
                      final type = FollowUpEntityType.fromValue(followup.entityType);

                      final priorityColor = priority == Priority.critical
                          ? NeuColors.priorityCritical
                          : priority == Priority.high
                          ? NeuColors.priorityHigh
                          : priority == Priority.medium
                          ? NeuColors.priorityMedium
                          : NeuColors.priorityLow;

                      final isSelected = _selectedIds.contains(followup.id);

                      // Decode notes JSON
                      String notesGeneral = '';
                      String executedProgress = '';
                      String obstaclesText = '';

                      if (followup.notes != null && followup.notes!.isNotEmpty) {
                        try {
                          final decoded = json.decode(followup.notes!);
                          if (decoded is Map) {
                            notesGeneral = decoded['general']?.toString() ?? '';
                            executedProgress = decoded['executed']?.toString() ?? '';
                            obstaclesText = decoded['obstacles']?.toString() ?? '';
                          } else {
                            notesGeneral = followup.notes!;
                          }
                        } catch (_) {
                          notesGeneral = followup.notes!;
                        }
                      }

                      final hasGeneral = notesGeneral.trim().isNotEmpty;
                      final hasExecuted = executedProgress.trim().isNotEmpty;
                      final hasObstacles = obstaclesText.trim().isNotEmpty;

                      return GestureDetector(
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            _toggleSelection(followup.id);
                          } else {
                            _showFollowUpDetailsBottomSheet(context, followup);
                          }
                        },
                        onLongPress: () => _toggleSelection(followup.id),
                        child: NeuCard(
                          statusColor: priorityColor,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              if (_selectedIds.isNotEmpty) ...[
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                                      : (isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            followup.title,
                                            style: (isDark ? AppTypography.h4Dark : AppTypography.h4).copyWith(
                                              decoration: status == UnifiedStatus.completed
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: status == UnifiedStatus.completed
                                                  ? (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        AppSpacing.gapHSm,
                                        PriorityChip(priority: priority),
                                      ],
                                    ),
                                    AppSpacing.gapSm,
                                    Row(
                                      children: [
                                        Icon(
                                          type == FollowUpEntityType.meeting
                                              ? Icons.groups_rounded
                                              : type == FollowUpEntityType.directive
                                                  ? Icons.assignment_rounded
                                                  : Icons.link_rounded,
                                          size: 14,
                                          color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                                        ),
                                        AppSpacing.gapHSm,
                                        Text(type.arabicLabel,
                                            style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                        const Spacer(),
                                        Text(
                                          status.arabicLabel,
                                          style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                            color: status == UnifiedStatus.completed
                                                ? NeuColors.success
                                                : status == UnifiedStatus.overdue
                                                    ? NeuColors.priorityCritical
                                                    : NeuColors.navyMid,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (followup.targetDate?.isNotEmpty == true) ...[
                                      AppSpacing.gapSm,
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_rounded,
                                              size: 14,
                                              color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                          AppSpacing.gapHSm,
                                          Text(
                                            followup.targetDate!,
                                            style: isDark ? AppTypography.captionDark : AppTypography.caption,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildRemainingTimeWidget(followup.targetDate, isDark),
                                          if (followup.assignedTo != null && followup.assignedTo!.isNotEmpty) ...[
                                            const SizedBox(width: 16),
                                            Icon(Icons.business_rounded,
                                                size: 14,
                                                color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                            AppSpacing.gapHSm,
                                            Expanded(
                                              child: Text(
                                                followup.assignedTo!,
                                                style: isDark ? AppTypography.captionDark : AppTypography.caption,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                    if (hasGeneral || hasExecuted || hasObstacles) ...[
                                      AppSpacing.gapSm,
                                      Row(
                                        children: [
                                          if (hasGeneral) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (isDark ? NeuColors.goldAccent : NeuColors.navyMid).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.description_outlined,
                                                      size: 12,
                                                      color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'ملاحظات',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Tajawal',
                                                      color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          if (hasExecuted) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: NeuColors.success.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle_outline_rounded,
                                                      size: 12,
                                                      color: NeuColors.success),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'إنجازات',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Tajawal',
                                                      color: NeuColors.success,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          if (hasObstacles) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: NeuColors.priorityCritical.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.warning_amber_rounded,
                                                      size: 12,
                                                      color: NeuColors.priorityCritical),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'عوائق',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Tajawal',
                                                      color: NeuColors.priorityCritical,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? FloatingActionButton(
              onPressed: () => context.push(RouteNames.followupCreate),
              backgroundColor: NeuColors.navyDeep,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}
