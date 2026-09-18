import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/export_button.dart';
import '../../reports/domain/export_service.dart';
import '../../../shared/widgets/sort_menu.dart';

import '../providers/meetings_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/constants/enums.dart';
import '../../../shared/widgets/neu_button.dart';
import '../domain/meetings_repository.dart';

/// Meetings List Screen — displays all meetings with search, filter, multi-select, and export.
class MeetingsListScreen extends ConsumerStatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  ConsumerState<MeetingsListScreen> createState() =>
      _MeetingsListScreenState();
}

class _MeetingsListScreenState
    extends ConsumerState<MeetingsListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
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
      'العنوان (أبجدي)',
      (a, b) => a.title.compareTo(b.title),
    ),
    SortOption(
      'نوع الاجتماع',
      (a, b) => a.meetingType.compareTo(b.meetingType),
    ),
  ];


  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'مجدول', value: '0'),
    FilterOption(label: 'قيد التنفيذ', value: '1'),
    FilterOption(label: 'مكتمل', value: '2'),
    FilterOption(label: 'مؤجل', value: '3'),
    FilterOption(label: 'ملغي', value: '4'),
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
    final meetingsAsync = ref.watch(meetingsListProvider);
    final filterParam = GoRouterState.of(context).uri.queryParameters['filter'];

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Dynamic Header: Shows selection controls when _selectedIds is not empty
              Padding(
                padding: AppSpacing.screen,
                child: meetingsAsync.when(
                  loading: () => _buildNormalHeader(isDark),
                  error: (_, _) => _buildNormalHeader(isDark),
                  data: (meetings) {
                    var filtered = _applyFilters(meetings, filterParam);
                    if (_selectedIds.isNotEmpty) {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _selectedIds.clear()),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? NeuColors.surfaceDark
                                    : NeuColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: isDark
                                      ? NeuColors.accentMuted
                                      : NeuColors.navyDeep,
                                  size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'تم تحديد ${_selectedIds.length}',
                            style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                          ),
                          const Spacer(),
                          // Select/Deselect All
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedIds.length == filtered.length) {
                                  _selectedIds.clear();
                                } else {
                                  _selectedIds.addAll(filtered.map((m) => m.id));
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? NeuColors.surfaceDark
                                    : NeuColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _selectedIds.length == filtered.length
                                    ? Icons.deselect_rounded
                                    : Icons.select_all_rounded,
                                color: isDark
                                    ? NeuColors.accentMuted
                                    : NeuColors.navyDeep,
                                size: 22,
                              ),
                            ),
                          ),
                          // Delete Button
                          GestureDetector(
                            onTap: () => _confirmDeleteSelected(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? NeuColors.surfaceDark
                                    : NeuColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: NeuColors.priorityCritical,
                                size: 22,
                              ),
                            ),
                          ),
                          // Export Button
                          ExportButton(
                            itemCount: _selectedIds.length,
                            onExport: (format) {
                              final selectedItems = filtered
                                  .where((m) => _selectedIds.contains(m.id))
                                  .toList();
                              selectedItems.sort((a, b) => '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}'));
                              final exportService = ref.read(exportServiceProvider);
                              exportService.exportDataList(
                                context: context,
                                title: 'الاجتماعات الرسمية المحددة',
                                items: selectedItems,
                                headers: [
                                  'م',
                                  'العنوان',
                                  'نوع الاجتماع',
                                  'التاريخ',
                                  'الوقت',
                                  'المكان',
                                  'الحضور',
                                  'التفاصيل',
                                  'المخرجات',
                                  'القرارات',
                                  'الاعمال',
                                  'الملاحظات'
                                ],
                                itemMapper: (items) => items.asMap().entries.map((entry) {
                                  final i = entry.key + 1;
                                  final m = entry.value;
                                  String typeStr = m.customMeetingType ?? MeetingType.fromValue(m.meetingType).arabicLabel;
                                  
                                  return [
                                    i.toString(),
                                    m.title,
                                    typeStr,
                                    m.date,
                                    m.time,
                                    m.location ?? 'غير محدد',
                                    exportService.decodeJsonArray(m.attendees),
                                    m.objective ?? '',
                                    exportService.decodeJsonArray(m.outcomes),
                                    exportService.decodeJsonArray(m.decisions),
                                    exportService.decodeJsonArray(m.agenda),
                                    m.notes ?? '',
                                  ];
                                }).toList(),
                                format: format,
                              );
                            },
                          ),
                        ],
                      );
                    }
                    return _buildNormalHeader(isDark);
                  },
                ),
              ),

              // Search & Filter
              SearchFilterBar(
                searchHint: 'بحث في الاجتماعات...',
                onSearchChanged: (q) =>
                    setState(() => _searchQuery = q),
                filters: _filters,
                selectedFilter: _statusFilter,
                onFilterChanged: (v) =>
                    setState(() => _statusFilter = v),
              ),

              AppSpacing.gapMd,

              // Meeting List
              Expanded(
                child: meetingsAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                      child: Text('حدث خطأ: $err',
                          style: AppTypography.bodySmall
                              .copyWith(color: NeuColors.danger))),
                  data: (meetings) {
                    var filtered = _applyFilters(meetings, filterParam);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups_outlined,
                                size: 64,
                                color: (isDark
                                        ? NeuColors.textHintDark
                                        : NeuColors.textHint)
                                    .withAlpha(120)),
                            AppSpacing.gapLg,
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _statusFilter != 'all'
                                  ? 'لا توجد نتائج مطابقة'
                                  : 'لا توجد اجتماعات',
                              style: (isDark
                                      ? AppTypography.h4Dark
                                      : AppTypography.h4)
                                  .copyWith(
                                      color: isDark
                                          ? NeuColors
                                              .textHintDark
                                          : NeuColors.textHint),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final meeting = filtered[index];
                        final isSelected = _selectedIds.contains(meeting.id);

                        return NeuCard(
                          onTap: () {
                            if (_selectedIds.isNotEmpty) {
                              _toggleSelection(meeting.id);
                            } else {
                              context.push(
                                  RouteNames.meetingDetailPath(
                                      meeting.id));
                            }
                          },
                          onLongPress: () => _toggleSelection(meeting.id),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            meeting.title,
                                            style: isDark
                                                ? AppTypography.h4Dark
                                                : AppTypography.h4,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        AppSpacing.gapHMd,
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (isDark ? NeuColors.goldAccent : NeuColors.navyDeep).withAlpha(25),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            meeting.customMeetingType ?? MeetingType.fromValue(meeting.meetingType).arabicLabel,
                                            style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        AppSpacing.gapHSm,
                                        StatusBadge
                                            .fromMeetingStatus(
                                                meeting.status),
                                      ],
                                    ),
                                    AppSpacing.gapSm,
                                    Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .calendar_today_rounded,
                                            size: 14,
                                            color: isDark
                                                ? NeuColors
                                                    .textHintDark
                                                : NeuColors.navyMid),
                                        AppSpacing.gapHSm,
                                        Text(meeting.date,
                                            style: isDark
                                                ? AppTypography
                                                    .captionDark
                                                : AppTypography
                                                    .caption),
                                        AppSpacing.gapHMd,
                                        Icon(
                                            Icons
                                                .access_time_rounded,
                                            size: 14,
                                            color: isDark
                                                ? NeuColors
                                                    .textHintDark
                                                : NeuColors.navyMid),
                                        AppSpacing.gapHSm,
                                        Text(meeting.time,
                                            style: isDark
                                                ? AppTypography
                                                    .captionDark
                                                : AppTypography
                                                    .caption),
                                        if (meeting.location !=
                                                null &&
                                            meeting.location!
                                                .isNotEmpty) ...[
                                          AppSpacing.gapHMd,
                                          Icon(
                                              Icons
                                                  .location_on_rounded,
                                              size: 14,
                                              color: isDark
                                                  ? NeuColors
                                                      .textHintDark
                                                  : NeuColors
                                                      .navyMid),
                                          AppSpacing.gapHSm,
                                          Expanded(
                                            child: Text(
                                                meeting.location!,
                                                style: isDark
                                                    ? AppTypography
                                                        .captionDark
                                                    : AppTypography
                                                        .caption,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
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
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () => context.push(RouteNames.meetingCreate),
              backgroundColor: NeuColors.navyDeep,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildNormalHeader(bool isDark) {
    return Row(
      children: [
        Text('الاجتماعات',
            style: isDark
                ? AppTypography.h2Dark
                : AppTypography.h2),
        const Spacer(),
        SortMenu(
          options: _sortOptions,
          selectedIndex: _selectedSortIndex,
          onSelected: (index) => setState(() => _selectedSortIndex = index),
        ),
      ],
    );
  }


  List<Meeting> _applyFilters(List<Meeting> meetings, String? filterParam) {
    var filtered = meetings;

    if (filterParam == 'today') {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      filtered = filtered.where((m) => m.date == todayStr).toList();
    }

    // Status filter
    if (_statusFilter != 'all') {
      final statusVal = int.tryParse(_statusFilter);
      if (statusVal != null) {
        filtered = filtered
            .where((m) => m.status == statusVal)
            .toList();
      }
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((m) {
        return m.title.toLowerCase().contains(q) ||
            (m.location ?? '').toLowerCase().contains(q) ||
            (m.objective ?? '').toLowerCase().contains(q) ||
            (m.notes ?? '').toLowerCase().contains(q) ||
            m.date.contains(q);
      }).toList();
    }

    filtered = filtered.toList();
    filtered.sort(_sortOptions[_selectedSortIndex].comparator);

    return filtered;
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
                    'هل أنت متأكد من رغبتك في حذف الاجتماعات المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(meetingsRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteMeeting(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الاجتماعات المحددة بنجاح', textDirection: TextDirection.rtl),
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