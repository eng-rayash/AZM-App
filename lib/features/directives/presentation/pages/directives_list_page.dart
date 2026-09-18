import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/search_filter_bar.dart';
import '../../../../shared/widgets/export_button.dart';
import '../../../../shared/widgets/neu_button.dart';
import '../../../../shared/widgets/neu_card.dart';
import '../../../reports/domain/export_service.dart';
import '../../../../shared/widgets/sort_menu.dart';

import '../../providers/directives_provider.dart';
import '../../widgets/directive_card.dart';
import '../../domain/directives_repository.dart';
import '../../../../shared/widgets/error_state.dart';

/// Directives List — displays all executive directives with search, filter, multi-select, and export.
class DirectivesListPage extends ConsumerStatefulWidget {
  const DirectivesListPage({super.key});

  @override
  ConsumerState<DirectivesListPage> createState() =>
      _DirectivesListPageState();
}

class _DirectivesListPageState extends ConsumerState<DirectivesListPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  final Set<int> _selectedIds = {};
  int _selectedSortIndex = 0;

  static final List<SortOption> _sortOptions = [
    SortOption(
      'تاريخ التوجيه (الأحدث)',
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ),
    SortOption(
      'تاريخ التوجيه (الأقدم)',
      (a, b) => a.createdAt.compareTo(b.createdAt),
    ),
    SortOption(
      'موعد الاستحقاق',
      (a, b) => (a.deadline ?? '').compareTo(b.deadline ?? ''),
    ),
    SortOption(
      'العنوان (أبجدي)',
      (a, b) => a.title.compareTo(b.title),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final directivesAsync = ref.watch(directivesListProvider);
    final filterParam = GoRouterState.of(context).uri.queryParameters['filter'];
    final isCriticalFilter = filterParam == 'critical';

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
            ? Text(
                isCriticalFilter ? 'التوجيهات العاجلة' : 'التوجيهات الإدارية',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3,
              )
            : Text(
                'تم تحديد ${_selectedIds.length}',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3,
              ),
        actions: _selectedIds.isEmpty
            ? [
                if (isCriticalFilter)
                  IconButton(
                    icon: Icon(
                      Icons.filter_alt_off_rounded,
                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                    ),
                    onPressed: () => context.go(RouteNames.directivesList),
                  ),
                SortMenu(
                  options: _sortOptions,
                  selectedIndex: _selectedSortIndex,
                  onSelected: (index) =>
                      setState(() => _selectedSortIndex = index),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                  ),
                  onPressed: () => context.push(RouteNames.directiveCreate),
                ),
              ]
            : [

                directivesAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (directives) {
                    var filtered = directives.toList();
                    if (isCriticalFilter) {
                      filtered = filtered.where((d) => d.priority == 0).toList();
                    }
                    // Status filter
                    if (_statusFilter != 'all') {
                      final statusVal = int.tryParse(_statusFilter);
                      if (statusVal != null) {
                        filtered = filtered
                            .where((d) => d.status == statusVal)
                            .toList();
                      }
                    }
                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((d) {
                        return d.title.toLowerCase().contains(q) ||
                            (d.assignedTo ?? '').toLowerCase().contains(q) ||
                            (d.details ?? '').toLowerCase().contains(q);
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
                                _selectedIds.addAll(filtered.map((d) => d.id));
                              }
                            });
                          },
                        ),
                        ExportButton(
                          itemCount: _selectedIds.length,
                          onExport: (format) {
                            final selectedItems = filtered
                                .where((d) => _selectedIds.contains(d.id))
                                .toList();
                            selectedItems.sort((a, b) => (a.deadline ?? '').compareTo(b.deadline ?? ''));
                            final exportService = ref.read(exportServiceProvider);
                            exportService.exportDataList(
                              context: context,
                              title: 'توجيهات الإدارة التنفيذية المحددة',
                              items: selectedItems,
                              headers: [
                                'م',
                                'التوجيه / العنوان',
                                'التفاصيل',
                                'الجهة المصدرة',
                                'الجهة المكلفة',
                                'الموعد النهائي',
                                'الأهمية',
                                'الحالة'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final d = entry.value;
                                return [
                                  i.toString(),
                                  d.title,
                                  d.details ?? '',
                                  d.source ?? 'غير محدد',
                                  d.assignedTo ?? 'غير محدد',
                                  d.deadline ?? 'غير محدد',
                                  Priority.fromValue(d.priority).arabicLabel,
                                  UnifiedStatus.fromValue(d.status).arabicLabel,
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
              searchHint: 'بحث في التوجيهات...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _statusFilter,
              onFilterChanged: (v) =>
                  setState(() => _statusFilter = v),
            ),
            AppSpacing.gapMd,

            // List
            Expanded(
              child: directivesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    ErrorState(error: err),
                data: (directives) {
                  var filtered = directives.toList();

                  if (isCriticalFilter) {
                    filtered = filtered.where((d) => d.priority == 0).toList();
                  }

                  // Status filter
                  if (_statusFilter != 'all') {
                    final statusVal =
                        int.tryParse(_statusFilter);
                    if (statusVal != null) {
                      filtered = filtered
                          .where((d) => d.status == statusVal)
                          .toList();
                    }
                  }

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((d) {
                      return d.title
                              .toLowerCase()
                              .contains(q) ||
                          (d.assignedTo ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (d.details ?? '')
                              .toLowerCase()
                              .contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.assignment_rounded,
                      title: _searchQuery.isNotEmpty ||
                              _statusFilter != 'all'
                          ? 'لا توجد نتائج مطابقة'
                          : 'لا توجد توجيهات',
                      subtitle: _searchQuery.isEmpty &&
                              _statusFilter == 'all' &&
                              _selectedIds.isEmpty
                          ? 'أضف توجيهًا إداريًا جديدًا'
                          : null,
                      actionLabel: _searchQuery.isEmpty &&
                              _statusFilter == 'all' &&
                              _selectedIds.isEmpty
                          ? 'إضافة توجيه'
                          : null,
                      onAction: _searchQuery.isEmpty &&
                              _statusFilter == 'all' &&
                              _selectedIds.isEmpty
                          ? () => context.push(
                              RouteNames.directiveCreate)
                          : null,
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screenH,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final directive = filtered[index];
                      final isSelected = _selectedIds.contains(directive.id);

                      return GestureDetector(
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            _toggleSelection(directive.id);
                          } else {
                            context.push(
                              RouteNames.directiveDetailPath(directive.id),
                            );
                          }
                        },
                        onLongPress: () => _toggleSelection(directive.id),
                        child: Row(
                          children: [
                            if (_selectedIds.isNotEmpty) ...[
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? (isDark
                                        ? NeuColors.accentMuted
                                        : NeuColors.navyDeep)
                                    : (isDark
                                        ? NeuColors.textHintDark
                                        : NeuColors.textHint),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: DirectiveCard(
                                directive: directive,
                              ),
                            ),
                          ],
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
                    'هل أنت متأكد من رغبتك في حذف التوجيهات المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(directivesRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteDirective(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التوجيهات المحددة بنجاح', textDirection: TextDirection.rtl),
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