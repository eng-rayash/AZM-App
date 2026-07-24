import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

import '../providers/tasks_provider.dart';
import '../domain/tasks_repository.dart';

/// Tasks List Screen — displays all active tasks with search, filter, multi-select, and export.
class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() =>
      _TasksListScreenState();
}

class _TasksListScreenState
    extends ConsumerState<TasksListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  final Set<int> _selectedIds = {};
  int _selectedSortIndex = 0;

  static final List<SortOption> _sortOptions = [
    SortOption(
      'تاريخ الاستحقاق (الأحدث)',
      (a, b) => (b.dueDate ?? '').compareTo(a.dueDate ?? ''),
    ),
    SortOption(
      'تاريخ الاستحقاق (الأقدم)',
      (a, b) => (a.dueDate ?? '').compareTo(b.dueDate ?? ''),
    ),
    SortOption(
      'العنوان (أبجدي)',
      (a, b) => a.title.compareTo(b.title),
    ),
    SortOption(
      'الأهمية (هام أولاً)',
      (a, b) => b.priority.compareTo(a.priority),
    ),
  ];


  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'جديد', value: '0'),
    FilterOption(label: 'قيد التنفيذ', value: '1'),
    FilterOption(label: 'مكتمل', value: '3'),
    FilterOption(label: 'متأخر', value: '4'),
    FilterOption(label: 'ملغي', value: '6'),
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

  bool _initializedStatusFromRoute = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksState = ref.watch(tasksListProvider);

    final statusParam = GoRouterState.of(context).uri.queryParameters['status'];
    if (!_initializedStatusFromRoute && statusParam != null) {
      _statusFilter = statusParam;
      _initializedStatusFromRoute = true;
    }

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: _selectedIds.isEmpty,
        leading: _selectedIds.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => setState(() => _selectedIds.clear()),
              ),
        title: _selectedIds.isEmpty
            ? Text('المهام',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3)
            : Text('تم تحديد ${_selectedIds.length}',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        actions: _selectedIds.isEmpty
            ? [
                SortMenu(
                  options: _sortOptions,
                  selectedIndex: _selectedSortIndex,
                  onSelected: (index) =>
                      setState(() => _selectedSortIndex = index),
                ),
              ]
            : [

                tasksState.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (tasks) {
                    var filtered = tasks.toList();
                    // Status filter
                    if (_statusFilter != 'all') {
                      final statusVal = int.tryParse(_statusFilter);
                      if (statusVal != null) {
                        filtered = filtered
                            .where((t) => t.status == statusVal)
                            .toList();
                      }
                    }
                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((t) {
                        return t.title.toLowerCase().contains(q) ||
                            (t.description ?? '').toLowerCase().contains(q) ||
                            (t.assignedTo ?? '').toLowerCase().contains(q) ||
                            (t.dueDate ?? '').contains(q);
                      }).toList();
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _selectedIds.length == filtered.length
                                ? Icons.deselect_rounded
                                : Icons.select_all_rounded,
                            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_selectedIds.length == filtered.length) {
                                _selectedIds.clear();
                              } else {
                                _selectedIds.addAll(filtered.map((t) => t.id));
                              }
                            });
                          },
                        ),
                        ExportButton(
                          itemCount: _selectedIds.length,
                          onExport: (format) {
                            final selectedItems = filtered
                                .where((t) => _selectedIds.contains(t.id))
                                .toList();
                            selectedItems.sort((a, b) => (a.dueDate ?? '').compareTo(b.dueDate ?? ''));
                            final exportService = ref.read(exportServiceProvider);
                            exportService.exportDataList(
                              context: context,
                              title: 'مهام الإدارة التنفيذية المحددة',
                              items: selectedItems,
                              headers: [
                                'م',
                                'العنوان',
                                'التفاصيل',
                                'تاريخ الاستحقاق',
                                'المكلف بالمهام',
                                'الأهمية',
                                'الحالة'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final t = entry.value;
                                return [
                                  i.toString(),
                                  t.title,
                                  t.description ?? '',
                                  t.dueDate ?? 'غير محدد',
                                  t.assignedTo ?? 'غير محدد',
                                  Priority.fromValue(t.priority).arabicLabel,
                                  UnifiedStatus.fromValue(t.status).arabicLabel,
                                ];
                              }).toList(),
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
                  },
                ),
              ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter
            SearchFilterBar(
              searchHint: 'بحث في المهام...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _statusFilter,
              onFilterChanged: (v) =>
                  setState(() => _statusFilter = v),
            ),
            AppSpacing.gapMd,

            // Tasks List
            Expanded(
              child: tasksState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (tasks) {
                  var filtered = tasks.toList();

                  // Status filter
                  if (_statusFilter != 'all') {
                    final statusVal =
                        int.tryParse(_statusFilter);
                    if (statusVal != null) {
                      filtered = filtered
                          .where((t) => t.status == statusVal)
                          .toList();
                    }
                  }

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((t) {
                      return t.title
                              .toLowerCase()
                              .contains(q) ||
                          (t.description ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (t.assignedTo ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (t.dueDate ?? '').contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_rounded,
                              size: 64,
                              color: isDark
                                  ? NeuColors.textHintDark
                                  : NeuColors.textHint),
                          AppSpacing.gapMd,
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _statusFilter != 'all'
                                ? 'لا توجد نتائج مطابقة'
                                : 'لا توجد مهام حالياً',
                            style: AppTypography.body.copyWith(
                                color: isDark
                                    ? NeuColors.textHintDark
                                    : NeuColors.textHint),
                          ),
                          if (_searchQuery.isEmpty &&
                              _statusFilter == 'all' &&
                              _selectedIds.isEmpty) ...[
                            AppSpacing.gapLg,
                            NeuButton(
                              label: 'إضافة مهمة جديدة',
                              onPressed: () => context
                                  .push(RouteNames.taskCreate),
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
                    separatorBuilder: (context, index) =>
                        AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      final isSelected = _selectedIds.contains(task.id);
                      final priority =
                          Priority.fromValue(task.priority);
                      final status =
                          UnifiedStatus.fromValue(task.status);

                      return GestureDetector(
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            _toggleSelection(task.id);
                          } else {
                            context.push(
                                RouteNames.taskDetailPath(task.id));
                          }
                        },
                        onLongPress: () => _toggleSelection(task.id),
                        child: NeuCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              if (_selectedIds.isNotEmpty) ...[
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? (isDark
                                          ? NeuColors.goldAccent
                                          : NeuColors.navyDeep)
                                      : (isDark
                                          ? NeuColors.textHintDark
                                          : NeuColors.textHint),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            style: (isDark
                                                    ? AppTypography
                                                        .h4Dark
                                                    : AppTypography.h4)
                                                .copyWith(
                                              decoration: status ==
                                                      UnifiedStatus
                                                          .completed
                                                  ? TextDecoration
                                                      .lineThrough
                                                  : null,
                                              color: status ==
                                                      UnifiedStatus
                                                          .completed
                                                  ? (isDark
                                                      ? NeuColors
                                                          .textSecondaryDark
                                                      : NeuColors
                                                          .textSecondary)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        AppSpacing.gapHSm,
                                        PriorityChip(
                                            priority: priority),
                                      ],
                                    ),
                                    AppSpacing.gapSm,
                                    if (task.dueDate?.isNotEmpty ==
                                        true) ...[
                                      Row(
                                        children: [
                                          Icon(
                                              Icons
                                                  .calendar_today_rounded,
                                              size: 14,
                                              color: isDark
                                                  ? NeuColors
                                                      .textHintDark
                                                  : NeuColors.textHint),
                                          AppSpacing.gapHSm,
                                          Text(task.dueDate!,
                                              style: isDark
                                                  ? AppTypography
                                                      .captionDark
                                                  : AppTypography
                                                      .caption),
                                          const Spacer(),
                                          Text(
                                            status.arabicLabel,
                                            style: (isDark
                                                    ? AppTypography
                                                        .captionDark
                                                    : AppTypography
                                                        .caption)
                                                .copyWith(
                                              color: status ==
                                                      UnifiedStatus
                                                          .completed
                                                  ? NeuColors.success
                                                  : NeuColors.navyMid,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Align(
                                        alignment: AlignmentDirectional
                                            .centerEnd,
                                        child: Text(
                                          status.arabicLabel,
                                          style: (isDark
                                                  ? AppTypography
                                                      .captionDark
                                                  : AppTypography
                                                      .caption)
                                              .copyWith(
                                            color: status ==
                                                    UnifiedStatus
                                                        .completed
                                                ? NeuColors.success
                                                : NeuColors.navyMid,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
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
              onPressed: () => context.push(RouteNames.taskCreate),
              backgroundColor: NeuColors.navyDeep,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
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
                    'هل أنت متأكد من رغبتك في حذف المهام المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(tasksRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteTask(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المهام المحددة بنجاح', textDirection: TextDirection.rtl),
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
}