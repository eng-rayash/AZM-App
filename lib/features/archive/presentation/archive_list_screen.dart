import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/export_button.dart';
import '../../../shared/widgets/sort_menu.dart';
import '../../reports/domain/export_service.dart';
import '../domain/archive_repository.dart';
import '../providers/archive_categories_provider.dart';
import '../../../core/database/app_database.dart';

/// Professional Executive screen for listing, searching, filtering, and managing Archived Memos.
/// Offers full offline search, high-fidelity neumorphic list layout, and immediate RTL Excel/PDF export.
class ArchiveListScreen extends ConsumerStatefulWidget {
  const ArchiveListScreen({super.key});

  @override
  ConsumerState<ArchiveListScreen> createState() => _ArchiveListScreenState();
}

class _ArchiveListScreenState extends ConsumerState<ArchiveListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  final Set<int> _selectedIds = {};
  int _selectedSortIndex = 0;

  static final List<SortOption> _sortOptions = [
    SortOption(
      'الأحدث تاريخاً',
      (a, b) => (b.createdAt).compareTo(a.createdAt),
    ),
    SortOption(
      'الأقدم تاريخاً',
      (a, b) => (a.createdAt).compareTo(b.createdAt),
    ),
    SortOption(
      'الموضوع (أبجدي)',
      (a, b) => a.title.compareTo(b.title),
    ),
    SortOption(
      'الرقم المرجعي',
      (a, b) => (a.referenceNumber ?? '').compareTo(b.referenceNumber ?? ''),
    ),
    SortOption(
      'النوع',
      (a, b) => (a.category ?? '').compareTo(b.category ?? ''),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // Confirm and delete document (single)
  Future<void> _confirmDelete(BuildContext context, ArchiveData doc) async {
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
                    'حذف المذكرة المؤرشفة',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      color: NeuColors.priorityCritical,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف المذكرة "${doc.title}" نهائياً من الأرشيف؟ لا يمكن التراجع عن هذا الإجراء.',
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
                              await ref.read(archiveRepositoryProvider).deleteRecord(doc.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم حذف المذكرة بنجاح', textDirection: TextDirection.rtl),
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

  // Confirm and delete multiple documents
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
                    'تأكيد الحذف الجماعي',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      color: NeuColors.priorityCritical,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف المذكرات المؤرشفة المحددة (${_selectedIds.length}) نهائياً من الأرشيف؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(archiveRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteRecord(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المذكرات المحددة بنجاح', textDirection: TextDirection.rtl),
            backgroundColor: NeuColors.priorityCritical,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل عملية الحذف: $e', textDirection: TextDirection.rtl),
            backgroundColor: NeuColors.priorityCritical,
          ),
        );
      }
    }
  }

  // Handle PDF preview or direct share
  void _openPdf(ArchiveData doc) {
    if (doc.localFilePath == null || doc.localFilePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد مستند PDF مرفق مع هذه المذكرة', textDirection: TextDirection.rtl),
          backgroundColor: NeuColors.navyDeep,
        ),
      );
      return;
    }

    if (doc.isConfidential) {
      // Log confidential access audit
      ref.read(archiveRepositoryProvider).logConfidentialAccess(doc.title);
    }

    context.push(
      RouteNames.archivePdfViewer,
      extra: {
        'pdfPath': doc.localFilePath!,
        'title': doc.title,
      },
    );
  }

  // Direct share PDF
  Future<void> _sharePdf(ArchiveData doc) async {
    if (doc.localFilePath == null || doc.localFilePath!.isEmpty) return;
    
    final file = File(doc.localFilePath!);
    if (await file.exists()) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'مذكرة مؤرشفة: ${doc.title}',
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر العثور على الملف المحلي للمشاركة', textDirection: TextDirection.rtl),
            backgroundColor: NeuColors.priorityCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final archiveAsync = ref.watch(archiveListProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: _selectedIds.isEmpty,
        leading: _selectedIds.isEmpty
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: Icon(Icons.close_rounded, color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => setState(() => _selectedIds.clear()),
              ),
        title: _selectedIds.isEmpty
            ? Text('أرشيف المذكرات الرسمية', style: isDark ? AppTypography.h3Dark : AppTypography.h3)
            : Text('تم تحديد ${_selectedIds.length}', style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        actions: [
          archiveAsync.when(
            data: (documents) {
              // Local filtering to export only what is filtered / searched
              final filteredDocs = documents.where((doc) {
                final q = _searchQuery.toLowerCase();
                final matchesQuery = doc.title.toLowerCase().contains(q) ||
                    (doc.referenceNumber?.toLowerCase().contains(q) ?? false) ||
                    (doc.directedEntity?.toLowerCase().contains(q) ?? false) ||
                    (doc.category?.toLowerCase().contains(q) ?? false) ||
                    (doc.tags?.toLowerCase().contains(q) ?? false);

                if (!matchesQuery) return false;

                if (_selectedFilter == 'الكل') return true;
                if (_selectedFilter == 'سري للغاية 🔒') return doc.isConfidential;
                return doc.category?.toLowerCase() == _selectedFilter.toLowerCase();
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
                            _selectedIds.addAll(filteredDocs.map((doc) => doc.id));
                          }
                        });
                      },
                    ),
                    ExportButton(
                      itemCount: _selectedIds.length,
                      onExport: (format) async {
                        final selectedItems = filteredDocs
                            .where((doc) => _selectedIds.contains(doc.id))
                            .toList();
                        final exportService = ref.read(exportServiceProvider);
                        await exportService.exportDataList<ArchiveData>(
                          context: context,
                          title: 'مذكرات الأرشيف المحددة',
                          items: selectedItems,
                          headers: [
                            'م',
                            'الموضوع',
                            'النوع',
                            'الرقم المرجعي',
                            'التاريخ الميلادي',
                            'التاريخ الهجري',
                            'الجهة الموجهة إليها',
                            'الملاحظات',
                            'سرية للغاية'
                          ],
                          itemMapper: (list) => List.generate(list.length, (idx) {
                            final doc = list[idx];
                            return [
                              '${idx + 1}',
                              doc.title,
                              doc.category ?? '',
                              doc.referenceNumber ?? '',
                              doc.documentDate ?? '',
                              doc.hijriDate ?? '',
                              doc.directedEntity ?? '',
                              doc.notes ?? '',
                              doc.isConfidential ? 'نعم' : 'لا',
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
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // 1. Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: AnimatedContainer(
                duration: NeuDecorations.pressDuration,
                decoration: NeuDecorations.neuConcave(radius: 16, isDark: isDark),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  textDirection: TextDirection.rtl,
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                  decoration: InputDecoration(
                    hintText: 'ابحث بالموضوع، الرقم، أو الجهة...',
                    hintStyle: AppTypography.body.copyWith(
                      color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: NeuColors.navyMid),
                    border: InputBorder.none,
                    contentPadding: AppSpacing.input,
                  ),
                ),
              ),
            ),

            // 2. Horizontal Filter Chips Scroll — dynamic from provider
            Consumer(
              builder: (context, ref, _) {
                final categoriesAsync = ref.watch(archiveCategoriesProvider);
                final dynamicCategories = categoriesAsync.value ?? [];
                // Build filters: fixed "الكل" + dynamic categories + fixed "سري للغاية"
                final filters = [
                  'الكل',
                  ...dynamicCategories,
                  'سري للغاية 🔒',
                ];

                // Reset filter if the selected one was removed
                if (!filters.contains(_selectedFilter)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedFilter = 'الكل');
                  });
                }

                return SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: NeuDecorations.pressDuration,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: isSelected
                                ? NeuDecorations.neuPressed(radius: 12, isDark: isDark)
                                : NeuDecorations.neuFlat(radius: 12, isDark: isDark),
                            child: Center(
                              child: Text(
                                filter,
                                style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                  color: isSelected
                                      ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                                      : (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // 3. Memos List View
            Expanded(
              child: archiveAsync.when(
                data: (documents) {
                  // Apply search and category filtering
                  final filteredDocs = documents.where((doc) {
                    final q = _searchQuery.toLowerCase();
                    final matchesQuery = doc.title.toLowerCase().contains(q) ||
                        (doc.referenceNumber?.toLowerCase().contains(q) ?? false) ||
                        (doc.directedEntity?.toLowerCase().contains(q) ?? false) ||
                        (doc.category?.toLowerCase().contains(q) ?? false) ||
                        (doc.tags?.toLowerCase().contains(q) ?? false);

                    if (!matchesQuery) return false;

                    if (_selectedFilter == 'الكل') return true;
                    if (_selectedFilter == 'سري للغاية 🔒') return doc.isConfidential;
                    return doc.category?.toLowerCase() == _selectedFilter.toLowerCase();
                  }).toList();

                  // Apply Sort
                  filteredDocs.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filteredDocs.isEmpty) {
                    return EmptyState(
                      icon: Icons.archive_outlined,
                      title: _searchQuery.isEmpty ? 'لا توجد وثائق مؤرشفة بعد' : 'لا توجد نتائج مطابقة لبحثك',
                      subtitle: _searchQuery.isEmpty
                          ? 'ابدأ بأرشفة أول مستند أو مذكرة رسمية عبر تصويرها بالكاميرا أو اختيار صور'
                          : 'جرّب البحث بكلمات مختلفة أو تعديل خيار التصفية',
                      actionLabel: _searchQuery.isEmpty ? 'أرشفة مذكرة جديدة' : null,
                      onAction: _searchQuery.isEmpty ? () => context.push(RouteNames.archiveCreate) : null,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final hasPdf = doc.localFilePath != null && doc.localFilePath!.isNotEmpty;
                      final isSelected = _selectedIds.contains(doc.id);
                      
                      return NeuCard(
                        statusColor: doc.isConfidential ? NeuColors.priorityCritical : NeuColors.goldAccent,
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 18),
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            _toggleSelection(doc.id);
                          }
                        },
                        onLongPress: () => _toggleSelection(doc.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Type Badge + Confidential Badge + Delete Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
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
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: NeuColors.navyDeep.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        doc.category ?? 'مذكرة عامة',
                                        style: TextStyle(
                                          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (doc.isConfidential) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: NeuColors.priorityCritical.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.lock_rounded, size: 10, color: NeuColors.priorityCritical),
                                            SizedBox(width: 4),
                                            Text(
                                              'سري للغاية',
                                              style: TextStyle(
                                                color: NeuColors.priorityCritical,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (_selectedIds.isEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: NeuColors.priorityCritical, size: 20),
                                    onPressed: () => _confirmDelete(context, doc),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Document Title/Subject
                            Text(
                              doc.title,
                              style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Document Info Metadata
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.tag_rounded, size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          doc.referenceNumber != null && doc.referenceNumber!.isNotEmpty
                                              ? doc.referenceNumber!
                                              : 'بدون رقم مرجعي',
                                          style: isDark ? AppTypography.captionDark : AppTypography.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.business_rounded, size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          doc.directedEntity != null && doc.directedEntity!.isNotEmpty
                                              ? doc.directedEntity!
                                              : 'الجهة غير محددة',
                                          style: isDark ? AppTypography.captionDark : AppTypography.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Dates Row
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          doc.documentDate != null && doc.documentDate!.isNotEmpty
                                              ? '${doc.documentDate!} م'
                                              : 'التاريخ الميلادي غير متوفر',
                                          style: isDark ? AppTypography.captionDark : AppTypography.caption,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month_rounded, size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          doc.hijriDate != null && doc.hijriDate!.isNotEmpty
                                              ? '${doc.hijriDate!} هـ'
                                              : 'التاريخ الهجري غير متوفر',
                                          style: isDark ? AppTypography.captionDark : AppTypography.caption,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Notes Preview (if existing)
                            if (doc.notes != null && doc.notes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: NeuDecorations.neuConcave(radius: 12, isDark: isDark),
                                child: Text(
                                  'الملاحظات: ${doc.notes!}',
                                  style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                    color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],

                            // Actions Area: Open Scanned PDF, Edit, Share
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (hasPdf) ...[
                                  Expanded(
                                    child: NeuButton(
                                      onPressed: () => _openPdf(doc),
                                      label: 'معاينة ملف الـ PDF الممسوح',
                                      icon: Icons.picture_as_pdf_rounded,
                                      variant: NeuButtonVariant.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ] else ...[
                                  const Spacer(),
                                ],
                                GestureDetector(
                                  onTap: () => context.push(RouteNames.archiveEditPath(doc.id)),
                                  child: AnimatedContainer(
                                    duration: NeuDecorations.pressDuration,
                                    padding: const EdgeInsets.all(12),
                                    decoration: NeuDecorations.neuFlat(radius: 12, isDark: isDark),
                                    child: Icon(
                                      Icons.edit_rounded,
                                      color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                if (hasPdf) ...[
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _sharePdf(doc),
                                    child: AnimatedContainer(
                                      duration: NeuDecorations.pressDuration,
                                      padding: const EdgeInsets.all(12),
                                      decoration: NeuDecorations.neuFlat(radius: 12, isDark: isDark),
                                      child: Icon(
                                        Icons.share_rounded,
                                        color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('خطأ في جلب الأرشيف: $error', style: const TextStyle(color: NeuColors.priorityCritical)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? FloatingActionButton(
              onPressed: () => context.push(RouteNames.archiveCreate),
              backgroundColor: NeuColors.navyDeep,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}