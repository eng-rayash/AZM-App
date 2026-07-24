import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../domain/visitors_repository.dart';
import '../../../shared/widgets/export_button.dart';
import '../../reports/domain/export_service.dart';
import '../../../shared/widgets/sort_menu.dart';

import '../../../core/database/app_database.dart';

/// Visitors List Screen — with search, status filter, multi-select, and export.
class VisitorsListScreen extends ConsumerStatefulWidget {
  const VisitorsListScreen({super.key});

  @override
  ConsumerState<VisitorsListScreen> createState() =>
      _VisitorsListScreenState();
}

class _VisitorsListScreenState
    extends ConsumerState<VisitorsListScreen> {
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
      'الاسم (أبجدي)',
      (a, b) => a.visitorName.compareTo(b.visitorName),
    ),
    SortOption(
      'الحالة',
      (a, b) => a.status.compareTo(b.status),
    ),
  ];


  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'بالداخل', value: '1', icon: Icons.login_rounded),
    FilterOption(
        label: 'بالانتظار', value: '0', icon: Icons.hourglass_top_rounded),
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
    final visitorsState = ref.watch(activeVisitorsProvider);

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
            ? Text('لوحة الزوار',
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

                visitorsState.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (visitors) {
                    var filtered = visitors.toList();
                    if (_statusFilter != 'all') {
                      final statusVal = int.tryParse(_statusFilter);
                      if (statusVal != null) {
                        filtered = filtered.where((v) => v.status == statusVal).toList();
                      }
                    }
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((v) {
                        return v.visitorName.toLowerCase().contains(q) ||
                            (v.company ?? '').toLowerCase().contains(q) ||
                            (v.purpose ?? '').toLowerCase().contains(q);
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
                                _selectedIds.addAll(filtered.map((v) => v.id));
                              }
                            });
                          },
                        ),
                        ExportButton(
                          itemCount: _selectedIds.length,
                          onExport: (format) {
                            final selectedItems = filtered
                                .where((v) => _selectedIds.contains(v.id))
                                .toList();
                            selectedItems.sort((a, b) => (a.entryTime ?? '').compareTo(b.entryTime ?? ''));
                            final exportService = ref.read(exportServiceProvider);
                            exportService.exportDataList(
                              context: context,
                              title: 'زوار المكتب التنفيذي المحددين',
                              items: selectedItems,
                              headers: [
                                'م',
                                'اسم الزائر',
                                'الجهة / الشركة',
                                'الغرض / السبب',
                                'وقت الدخول',
                                'وقت الخروج',
                                'الحالة'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final v = entry.value;
                                String statusStr = 'بالانتظار';
                                if (v.status == 1) statusStr = 'بالداخل';
                                if (v.status == 2) statusStr = 'غادر';
                                return <String>[
                                  i.toString(),
                                  v.visitorName,
                                  v.company ?? 'غير محدد',
                                  v.purpose ?? 'غير محدد',
                                  v.entryTime ?? 'غير محدد',
                                  v.exitTime ?? 'غير محدد',
                                  statusStr,
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
              searchHint: 'بحث في الزوار...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _statusFilter,
              onFilterChanged: (v) =>
                  setState(() => _statusFilter = v),
            ),
            AppSpacing.gapSm,

            // Add button — hide when selecting
            if (_selectedIds.isEmpty) ...[
              Padding(
                padding: AppSpacing.screenH,
                child: Row(
                  children: [
                    Expanded(
                      child: NeuButton(
                        label: 'تسجيل زائر',
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: () =>
                            _showAddVisitorDialog(context, ref, isDark),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,
            ],

            // Visitors List
            Expanded(
              child: visitorsState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (visitors) {
                  var filtered = visitors.toList();

                  // Status filter
                  if (_statusFilter != 'all') {
                    final statusVal =
                        int.tryParse(_statusFilter);
                    if (statusVal != null) {
                      filtered = filtered
                          .where(
                              (v) => v.status == statusVal)
                          .toList();
                    }
                  }

                  // Search
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((v) {
                      return v.visitorName
                              .toLowerCase()
                              .contains(q) ||
                          (v.company ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (v.purpose ?? '')
                              .toLowerCase()
                              .contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ||
                                _statusFilter != 'all'
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا يوجد زوار في الانتظار أو بالداخل',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screenH,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final visitor = filtered[index];
                      final isSelected = _selectedIds.contains(visitor.id);

                      return NeuCard(
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            _toggleSelection(visitor.id);
                          } else {
                            _toggleSelection(visitor.id);
                          }
                        },
                        onLongPress: () => _toggleSelection(visitor.id),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                const SizedBox(width: 8),
                              ],
                              CircleAvatar(
                                backgroundColor: isDark
                                    ? NeuColors.navyLight
                                    : NeuColors.navyMid,
                                child: Text(
                                    visitor.visitorName[0],
                                    style: const TextStyle(
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                          title: Text(visitor.visitorName,
                              style: isDark
                                  ? AppTypography.h4Dark
                                  : AppTypography.h4),
                          subtitle: Text(
                            'الجهة: ${visitor.company ?? 'غير محدد'} • وقت الدخول: ${visitor.entryTime}',
                            style: isDark
                                ? AppTypography.captionDark
                                : AppTypography.caption,
                          ),
                          trailing: _selectedIds.isNotEmpty
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_rounded,
                                        color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                        size: 20,
                                      ),
                                      onPressed: () => _showAddVisitorDialog(context, ref, isDark, editVisitor: visitor),
                                    ),
                                    const SizedBox(width: 4),
                                    visitor.status == 1
                                        ? TextButton.icon(
                                            icon: const Icon(
                                                Icons.exit_to_app_rounded,
                                                color: NeuColors.danger,
                                                size: 18),
                                            label: const Text(
                                                'خروج',
                                                style: TextStyle(
                                                    color: NeuColors.danger,
                                                    fontSize: 12)),
                                            onPressed: () {
                                              ref
                                                  .read(visitorsRepositoryProvider)
                                                  .checkoutVisitor(
                                                      visitor.id,
                                                      visitor.visitorName);
                                            },
                                          )
                                        : Text('بالانتظار',
                                            style: TextStyle(
                                                color: isDark
                                                    ? NeuColors.goldAccent
                                                    : NeuColors.warning,
                                                fontSize: 12)),
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
    );
  }

  void _showAddVisitorDialog(
      BuildContext context, WidgetRef ref, bool isDark, {VisitorItem? editVisitor}) {
    final nameCtrl = TextEditingController(text: editVisitor?.visitorName);
    final companyCtrl = TextEditingController(text: editVisitor?.company);
    final purposeCtrl = TextEditingController(text: editVisitor?.purpose);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: NeuCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    editVisitor != null ? 'تعديل بيانات الزائر' : 'تسجيل دخول زائر جديد',
                    style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapLg,
                  NeuInput(
                    controller: nameCtrl,
                    label: 'اسم الزائر *',
                    hint: 'أدخل الاسم الثلاثي للزائر',
                    prefixIcon: Icons.person_rounded,
                  ),
                  AppSpacing.gapMd,
                  NeuInput(
                    controller: companyCtrl,
                    label: 'الجهة / الشركة',
                    hint: 'اسم الجهة أو الشركة التابع لها',
                    prefixIcon: Icons.business_rounded,
                  ),
                  AppSpacing.gapMd,
                  NeuInput(
                    controller: purposeCtrl,
                    label: 'سبب الزيارة',
                    hint: 'الغرض أو موعد المقابلة',
                    prefixIcon: Icons.description_rounded,
                  ),
                  AppSpacing.gapXl,
                  Row(
                    children: [
                      Expanded(
                        child: NeuButton(
                          onPressed: () async {
                            if (nameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('اسم الزائر مطلوب لتسجيل الدخول', textDirection: TextDirection.rtl),
                                  backgroundColor: NeuColors.priorityCritical,
                                ),
                              );
                              return;
                            }
                            final repo = ref.read(visitorsRepositoryProvider);
                            if (editVisitor != null) {
                              await repo.updateVisitor(
                                id: editVisitor.id,
                                visitorName: nameCtrl.text.trim(),
                                company: companyCtrl.text.trim(),
                                purpose: purposeCtrl.text.trim(),
                              );
                            } else {
                              await repo.registerVisitor(
                                visitorName: nameCtrl.text.trim(),
                                company: companyCtrl.text.trim(),
                                purpose: purposeCtrl.text.trim(),
                              );
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          label: editVisitor != null ? 'حفظ التعديلات' : 'تسجيل الدخول',
                          icon: Icons.check_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeuButton(
                          onPressed: () => Navigator.pop(ctx),
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
                    'هل أنت متأكد من رغبتك في حذف سجل الزوار المحددين (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(visitorsRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteVisitor(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف سجل الزوار المحددين بنجاح', textDirection: TextDirection.rtl),
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