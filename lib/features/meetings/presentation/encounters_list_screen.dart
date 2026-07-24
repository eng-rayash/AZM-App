import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/search_filter_bar.dart';

import '../../../core/constants/enums.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/export_button.dart';
import '../../reports/domain/export_service.dart';
import '../../../shared/widgets/sort_menu.dart';
import '../../../shared/widgets/neu_button.dart';

import '../domain/meetings_repository.dart';

/// Encounters List Screen — اللقاءات السريعة
class EncountersListScreen extends ConsumerStatefulWidget {
  const EncountersListScreen({super.key});

  @override
  ConsumerState<EncountersListScreen> createState() => _EncountersListScreenState();
}

class _EncountersListScreenState extends ConsumerState<EncountersListScreen> {
  String _searchQuery = '';
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
    final meetingsState = ref.watch(meetingsListProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: _selectedIds.isEmpty,
        title: _selectedIds.isEmpty
            ? Text(
                'اللقاءات السريعة',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3,
              )
            : Text(
                'تم تحديد ${_selectedIds.length}',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3,
              ),
        leading: _selectedIds.isEmpty
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                ),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                ),
                onPressed: () => setState(() => _selectedIds.clear()),
              ),
        actions: _selectedIds.isEmpty
            ? [
                SortMenu(
                  options: _sortOptions,
                  selectedIndex: _selectedSortIndex,
                  onSelected: (index) =>
                      setState(() => _selectedSortIndex = index),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                  ),
                  onPressed: () => context.push(RouteNames.encounterCreate),
                ),
              ]
            : [

                meetingsState.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (meetings) {
                    var filtered = meetings.where((m) => m.meetingType == MeetingType.external_.value).toList();
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((m) {
                        return m.title.toLowerCase().contains(q) ||
                            (m.location ?? '').toLowerCase().contains(q) ||
                            (m.objective ?? '').toLowerCase().contains(q) ||
                            (m.notes ?? '').toLowerCase().contains(q);
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
                                _selectedIds.addAll(filtered.map((m) => m.id));
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: NeuColors.priorityCritical,
                          ),
                          onPressed: () => _confirmDeleteSelected(context),
                        ),
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
                              title: 'اللقاءات السريعة المحددة',
                              items: selectedItems,
                              headers: [
                                'م',
                                'العنوان',
                                'التاريخ',
                                'الوقت',
                                'المكان',
                                'الحضور',
                                'التفاصيل',
                                'المخرجات',
                                'القرارات',
                                'الملاحظات'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final m = entry.value;
                                return [
                                  i.toString(),
                                  m.title,
                                  m.date,
                                  m.time,
                                  m.location ?? 'غير محدد',
                                  exportService.decodeJsonArray(m.attendees),
                                  m.objective ?? '',
                                  exportService.decodeJsonArray(m.outcomes),
                                  exportService.decodeJsonArray(m.decisions),
                                  m.notes ?? '',
                                ];
                              }).toList(),
                              format: format,
                            );
                          },
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
            SearchFilterBar(
              searchHint: 'بحث في اللقاءات...',
              onSearchChanged: (q) => setState(() => _searchQuery = q),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: meetingsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('خطأ: $err')),
                data: (meetings) {
                  var filtered = meetings.where((m) => m.meetingType == MeetingType.external_.value).toList();

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((m) {
                      return m.title.toLowerCase().contains(q) ||
                          (m.location ?? '').toLowerCase().contains(q) ||
                          (m.objective ?? '').toLowerCase().contains(q) ||
                          (m.notes ?? '').toLowerCase().contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ? 'لا توجد نتائج مطابقة' : 'لا توجد لقاءات مسجلة',
                        style: AppTypography.body.copyWith(
                          color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.screenH,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final meeting = filtered[index];
                      final isSelected = _selectedIds.contains(meeting.id);

                      return NeuCard(
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            _toggleSelection(meeting.id);
                          } else {
                            context.push(RouteNames.meetingDetailPath(meeting.id));
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
                                    children: [
                                      Expanded(
                                        child: Text(
                                          meeting.title,
                                          style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      StatusBadge.fromMeetingStatus(meeting.status),
                                    ],
                                  ),
                                  AppSpacing.gapSm,
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.navyMid),
                                      AppSpacing.gapHSm,
                                      Text(meeting.date,
                                          style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                      AppSpacing.gapHMd,
                                      Icon(Icons.access_time_rounded,
                                          size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.navyMid),
                                      AppSpacing.gapHSm,
                                      Text(meeting.time,
                                          style: isDark ? AppTypography.captionDark : AppTypography.caption),
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
                    'هل أنت متأكد من رغبتك في حذف اللقاءات السريعة المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
            content: Text('تم حذف اللقاءات السريعة المحددة بنجاح', textDirection: TextDirection.rtl),
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
