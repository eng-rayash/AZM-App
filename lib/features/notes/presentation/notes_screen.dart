import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../../shared/widgets/export_button.dart';
import '../../reports/domain/export_service.dart';
import '../../../shared/widgets/sort_menu.dart';

import '../domain/notes_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/error_state.dart';

/// Notes Screen — with search across title and content.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _searchQuery = '';
  final Set<int> _selectedIds = {};
  int _selectedSortIndex = 0;

  static final List<SortOption> _sortOptions = [
    SortOption(
      'الأحدث أولاً',
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ),
    SortOption(
      'الأقدم أولاً',
      (a, b) => a.createdAt.compareTo(b.createdAt),
    ),
    SortOption(
      'العنوان (أبجدي)',
      (a, b) => (a.title ?? '').compareTo(b.title ?? ''),
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

  Future<void> _confirmDelete(BuildContext context, NoteItem note) async {
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
                    'حذف الملاحظة',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      color: NeuColors.priorityCritical,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف الملاحظة "${note.title ?? 'بدون عنوان'}"؟ لا يمكن التراجع عن هذا الإجراء.',
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
                              await ref.read(notesRepositoryProvider).deleteNote(note.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم حذف الملاحظة بنجاح', textDirection: TextDirection.rtl),
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
                    'هل أنت متأكد من رغبتك في حذف الملاحظات المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(notesRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteNote(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الملاحظات المحددة بنجاح', textDirection: TextDirection.rtl),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesState = ref.watch(notesListProvider);

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
            ? Text('الملاحظات السريعة',
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
                  icon: Icon(Icons.add_box_rounded,
                      color: isDark
                          ? NeuColors.accentMuted
                          : NeuColors.navyDeep),
                  onPressed: () => _showAddNoteDialog(context, ref, isDark),
                ),
              ]
            : [

                notesState.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (notes) {
                    var filtered = notes.toList();
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((n) {
                        return (n.title ?? '')
                                .toLowerCase()
                                .contains(q) ||
                            n.content
                                .toLowerCase()
                                .contains(q);
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
                                _selectedIds.addAll(filtered.map((n) => n.id));
                              }
                            });
                          },
                        ),
                        ExportButton(
                          itemCount: _selectedIds.length,
                          onExport: (format) {
                            final selectedItems = filtered
                                .where((n) => _selectedIds.contains(n.id))
                                .toList();
                            final exportService = ref.read(exportServiceProvider);
                            exportService.exportDataList(
                              context: context,
                              title: 'الملاحظات المحددة',
                              items: selectedItems,
                              headers: [
                                'م',
                                'العنوان',
                                'المحتوى',
                                'تاريخ الإنشاء'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final n = entry.value;
                                final dateStr = DateTime.fromMillisecondsSinceEpoch(n.createdAt).toIso8601String().split('T').first;
                                return [
                                  i.toString(),
                                  n.title ?? 'بدون عنوان',
                                  n.content,
                                  dateStr,
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
            // Search
            SearchFilterBar(
              searchHint: 'بحث في الملاحظات...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
            ),
            AppSpacing.gapMd,

            // Notes Grid
            Expanded(
              child: notesState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    ErrorState(error: err),
                data: (notes) {
                  var filtered = notes.toList();

                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((n) {
                      return (n.title ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          n.content
                              .toLowerCase()
                              .contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد ملاحظات',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: AppSpacing.screen,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      final isSelected = _selectedIds.contains(note.id);

                      return NeuCard(
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            _toggleSelection(note.id);
                          }
                        },
                        onLongPress: () => _toggleSelection(note.id),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (note.title != null &&
                                    note.title!.isNotEmpty)
                                  Expanded(
                                    child: Text(note.title!,
                                        style: isDark
                                            ? AppTypography.h4Dark
                                            : AppTypography.h4,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis),
                                  )
                                else
                                  const Spacer(),
                                if (_selectedIds.isNotEmpty)
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
                                    size: 20,
                                  ),
                              ],
                            ),
                            if (note.title != null &&
                                note.title!.isNotEmpty)
                              AppSpacing.gapXs,
                            Expanded(
                              child: Text(note.content,
                                  style: isDark
                                      ? AppTypography.bodyDark
                                      : AppTypography.body,
                                  overflow:
                                      TextOverflow.fade),
                            ),
                             if (_selectedIds.isEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_rounded,
                                        color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                        size: 18,
                                      ),
                                      onPressed: () => _showAddNoteDialog(context, ref, isDark, editNote: note),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons
                                              .delete_outline_rounded,
                                          color: NeuColors.danger,
                                          size: 18),
                                      onPressed: () => _confirmDelete(context, note),
                                      padding: EdgeInsets.zero,
                                      constraints:
                                          const BoxConstraints(),
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

  void _showAddNoteDialog(
      BuildContext context, WidgetRef ref, bool isDark, {NoteItem? editNote}) {
    final titleCtrl = TextEditingController(text: editNote?.title);
    final contentCtrl = TextEditingController(text: editNote?.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        title: Text(editNote != null ? 'تعديل الملاحظة' : 'ملاحظة جديدة',
            style: isDark
                ? AppTypography.h3Dark
                : AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'العنوان (اختياري)')),
            AppSpacing.gapSm,
            TextField(
              controller: contentCtrl,
              decoration:
                  const InputDecoration(labelText: 'الملاحظة'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          NeuButton(
            label: 'حفظ',
            onPressed: () async {
              if (contentCtrl.text.isNotEmpty) {
                final repo = ref.read(notesRepositoryProvider);
                if (editNote != null) {
                  await repo.updateNote(
                    id: editNote.id,
                    title: titleCtrl.text,
                    content: contentCtrl.text,
                  );
                } else {
                  await repo.createNote(
                    title: titleCtrl.text,
                    content: contentCtrl.text,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }
}