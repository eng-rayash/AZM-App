import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../../shared/widgets/export_button.dart';
import '../../reports/domain/export_service.dart';
import '../../../shared/widgets/sort_menu.dart';

import '../../../core/database/app_database.dart';
import '../domain/calls_repository.dart';

/// Calls List Screen — with search, filter by call type, multi-select, and export.
class CallsListScreen extends ConsumerStatefulWidget {
  const CallsListScreen({super.key});

  @override
  ConsumerState<CallsListScreen> createState() =>
      _CallsListScreenState();
}

class _CallsListScreenState
    extends ConsumerState<CallsListScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all';
  final Set<int> _selectedIds = {};
  int _selectedSortIndex = 0;

  static final List<SortOption> _sortOptions = [
    SortOption(
      'الأحدث تاريخاً',
      (a, b) => '${b.date} ${b.time}'.compareTo('${a.date} ${a.time}'),
    ),
    SortOption(
      'الأقدم تاريخاً',
      (a, b) => '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}'),
    ),
    SortOption(
      'الاسم (أبجدي)',
      (a, b) => a.callerName.compareTo(b.callerName),
    ),
    SortOption(
      'الأهمية (هام أولاً)',
      (a, b) => (b.isImportant ? 1 : 0).compareTo(a.isImportant ? 1 : 0),
    ),
  ];


  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(
        label: 'واردة', value: '0', icon: Icons.call_received_rounded),
    FilterOption(
        label: 'صادرة', value: '1', icon: Icons.call_made_rounded),
    FilterOption(
        label: 'فائتة', value: '2', icon: Icons.call_missed_rounded),
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
    final callsState = ref.watch(callsListProvider);

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
            ? Text('سجل المكالمات',
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
                IconButton(
                  icon: Icon(Icons.add_ic_call_rounded,
                      color: isDark
                          ? NeuColors.goldAccent
                          : NeuColors.navyDeep),
                  onPressed: () => _showAddCallModal(context, ref, isDark),
                ),
              ]
            : [

                callsState.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (calls) {
                    var filtered = calls.toList();
                    // Type filter
                    if (_typeFilter != 'all') {
                      final typeVal = int.tryParse(_typeFilter);
                      if (typeVal != null) {
                        filtered = filtered
                            .where((c) => c.callType == typeVal)
                            .toList();
                      }
                    }
                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((c) {
                        return c.callerName.toLowerCase().contains(q) ||
                            (c.summary ?? '').toLowerCase().contains(q) ||
                            c.date.contains(q);
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
                                _selectedIds.addAll(filtered.map((c) => c.id));
                              }
                            });
                          },
                        ),
                        ExportButton(
                          itemCount: _selectedIds.length,
                          onExport: (format) {
                            final selectedItems = filtered
                                .where((c) => _selectedIds.contains(c.id))
                                .toList();
                            selectedItems.sort((a, b) => '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}'));
                            final exportService = ref.read(exportServiceProvider);
                            exportService.exportDataList(
                              context: context,
                              title: 'سجل المكالمات المحددة',
                              items: selectedItems,
                              headers: [
                                'م',
                                'اسم المتصل',
                                'رقم الهاتف',
                                'نوع المكالمة',
                                'التاريخ',
                                'الوقت',
                                'الملخص',
                                'هام'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final c = entry.value;
                                return [
                                  i.toString(),
                                  c.callerName,
                                  c.phoneNumber ?? '',
                                  c.callType == 0 ? 'واردة' : c.callType == 1 ? 'صادرة' : 'فائتة',
                                  c.date,
                                  c.time,
                                  c.summary ?? '',
                                  c.isImportant ? 'نعم' : 'لا',
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
              searchHint: 'بحث في المكالمات...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _typeFilter,
              onFilterChanged: (v) =>
                  setState(() => _typeFilter = v),
            ),
            AppSpacing.gapMd,

            // Calls List
            Expanded(
              child: callsState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (calls) {
                  var filtered = calls.toList();

                  // Type filter
                  if (_typeFilter != 'all') {
                    final typeVal =
                        int.tryParse(_typeFilter);
                    if (typeVal != null) {
                      filtered = filtered
                          .where(
                              (c) => c.callType == typeVal)
                          .toList();
                    }
                  }

                  // Search
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((c) {
                      return c.callerName
                              .toLowerCase()
                              .contains(q) ||
                          (c.summary ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          c.date.contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ||
                                _typeFilter != 'all'
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد مكالمات مسجلة',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screen,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final call = filtered[index];
                      final isSelected = _selectedIds.contains(call.id);

                      return GestureDetector(
                        onTap: () => _toggleSelection(call.id),
                        onLongPress: () => _toggleSelection(call.id),
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
                              _buildCallIcon(
                                  call.callType, isDark),
                              AppSpacing.gapHMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              call.callerName,
                                              style: isDark
                                                  ? AppTypography
                                                      .h4Dark
                                                  : AppTypography
                                                      .h4),
                                        ),
                                        if (call.isImportant) ...[
                                          AppSpacing.gapHSm,
                                          const Icon(
                                              Icons.star_rounded,
                                              color: NeuColors
                                                  .goldAccent,
                                              size: 16),
                                        ],
                                      ],
                                    ),
                                    AppSpacing.gapXs,
                                    Text(
                                        '${call.date} - ${call.time}',
                                        style: isDark
                                            ? AppTypography
                                                .captionDark
                                            : AppTypography
                                                .caption),
                                    if (call.summary != null &&
                                        call.summary!
                                            .isNotEmpty) ...[
                                      AppSpacing.gapXs,
                                      Text(call.summary!,
                                          style: isDark
                                              ? AppTypography
                                                  .bodySmallDark
                                              : AppTypography
                                                  .bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis),
                                    ],
                                  ],
                                ),
                              ),
                              if (_selectedIds.isEmpty) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                    size: 20,
                                  ),
                                  onPressed: () => _showAddCallModal(context, ref, isDark, editCall: call),
                                ),
                              ],
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

  Widget _buildCallIcon(int type, bool isDark) {
    IconData icon;
    Color color;
    switch (type) {
      case 0:
        icon = Icons.call_received_rounded;
        color = NeuColors.success;
        break;
      case 1:
        icon = Icons.call_made_rounded;
        color = NeuColors.info;
        break;
      default:
        icon = Icons.call_missed_rounded;
        color = NeuColors.danger;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color:
                  isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
              offset: const Offset(3, 3),
              blurRadius: 6),
          BoxShadow(
              color: isDark
                  ? NeuColors.shadowLightDark
                  : NeuColors.shadowLight,
              offset: const Offset(-3, -3),
              blurRadius: 6),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _showAddCallModal(
      BuildContext context, WidgetRef ref, bool isDark, {CallItem? editCall}) {
    final nameCtrl = TextEditingController(text: editCall?.callerName);
    final summaryCtrl = TextEditingController(text: editCall?.summary);
    int selectedType = editCall?.callType ?? 0;
    bool isImportant = editCall?.isImportant ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(editCall != null ? 'تعديل سجل المكالمة' : 'تسجيل مكالمة جديدة',
                      style: isDark
                          ? AppTypography.h3Dark
                          : AppTypography.h3,
                      textAlign: TextAlign.center),
                  AppSpacing.gapLg,
                  NeuInput(
                    controller: nameCtrl,
                    label: 'اسم المتصل *',
                    hint: 'أدخل اسم المتصل أو الجهة',
                    prefixIcon: Icons.phone_rounded,
                  ),
                  AppSpacing.gapMd,
                  NeuInput(
                    controller: summaryCtrl,
                    label: 'ملخص المكالمة',
                    hint: 'أدخل تفاصيل ومخرجات المكالمة',
                    prefixIcon: Icons.description_rounded,
                    maxLines: 2,
                  ),
                  AppSpacing.gapMd,
                  Text(
                    'نوع المكالمة',
                    style: isDark ? AppTypography.labelDark : AppTypography.label,
                  ),
                  AppSpacing.gapSm,
                  NeuCard(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      children: [
                        _buildTypeSegment(
                          index: 0,
                          label: 'واردة',
                          selectedIndex: selectedType,
                          isDark: isDark,
                          onTap: () => setModalState(() => selectedType = 0),
                        ),
                        _buildTypeSegment(
                          index: 1,
                          label: 'صادرة',
                          selectedIndex: selectedType,
                          isDark: isDark,
                          onTap: () => setModalState(() => selectedType = 1),
                        ),
                        _buildTypeSegment(
                          index: 2,
                          label: 'فائتة',
                          selectedIndex: selectedType,
                          isDark: isDark,
                          onTap: () => setModalState(() => selectedType = 2),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapMd,
                  NeuCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rounded, 
                              color: isImportant ? NeuColors.goldAccent : NeuColors.textHint),
                            const SizedBox(width: 12),
                            Text(
                              'مكالمة هامة وعاجلة',
                              style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: isImportant,
                          onChanged: (val) => setModalState(() => isImportant = val),
                          activeThumbColor: NeuColors.goldAccent,
                          activeTrackColor: NeuColors.goldAccent.withAlpha(100),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapXl,
                  NeuButton(
                    label: editCall != null ? 'حفظ التعديلات' : 'حفظ سجل المكالمة',
                    icon: Icons.save_rounded,
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('اسم المتصل مطلوب لحفظ سجل المكالمة', textDirection: TextDirection.rtl),
                            backgroundColor: NeuColors.priorityCritical,
                          ),
                        );
                        return;
                      }
                      final now = DateTime.now();
                      final repo = ref.read(callsRepositoryProvider);
                      if (editCall != null) {
                        await repo.updateCall(
                          id: editCall.id,
                          callerName: nameCtrl.text.trim(),
                          callType: selectedType,
                          date: editCall.date,
                          time: editCall.time,
                          phoneNumber: editCall.phoneNumber,
                          summary: summaryCtrl.text.trim(),
                          isImportant: isImportant,
                        );
                      } else {
                        await repo.logCall(
                          callerName: nameCtrl.text.trim(),
                          callType: selectedType,
                          date: '${now.year}-${now.month}-${now.day}',
                          time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                          summary: summaryCtrl.text.trim(),
                          isImportant: isImportant,
                        );
                      }
                      if (ctx.mounted) ctx.pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildTypeSegment({
    required int index,
    required String label,
    required int selectedIndex,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? NeuColors.goldAccent.withAlpha(50) : NeuColors.navyDeep)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                    'هل أنت متأكد من رغبتك في حذف سجل المكالمات المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(callsRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteCall(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف سجل المكالمات المحددة بنجاح', textDirection: TextDirection.rtl),
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