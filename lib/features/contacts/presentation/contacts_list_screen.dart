import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/export_button.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../reports/domain/export_service.dart';
import '../../../shared/widgets/sort_menu.dart';

import '../domain/contacts_repository.dart';

/// Screen displaying the list of executive contacts with search & filter.
class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() =>
      _ContactsListScreenState();
}

class _ContactsListScreenState
    extends ConsumerState<ContactsListScreen> {
  String _searchQuery = '';
  String _vipFilter = 'all';
  final Set<int> _selectedIds = {};
  int _selectedSortIndex = 0;

  static final List<SortOption> _sortOptions = [
    SortOption(
      'الاسم (أبجدي)',
      (a, b) => a.name.compareTo(b.name),
    ),
    SortOption(
      'الجهة (أبجدي)',
      (a, b) => (a.company ?? '').compareTo(b.company ?? ''),
    ),
    SortOption(
      'الأهمية (VIP أولاً)',
      (a, b) => (b.isVip ? 1 : 0).compareTo(a.isVip ? 1 : 0),
    ),
    SortOption(
      'المضاف حديثاً',
      (a, b) => b.id.compareTo(a.id),
    ),
    SortOption(
      'المضاف قديماً',
      (a, b) => a.id.compareTo(b.id),
    ),
  ];


  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'VIP', value: 'vip', icon: Icons.star_rounded),
    FilterOption(label: 'عادي', value: 'normal'),
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
                    'هل أنت متأكد من رغبتك في حذف جهات الاتصال المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
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
      final repo = ref.read(contactsRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteContact(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف جهات الاتصال المحددة بنجاح', textDirection: TextDirection.rtl),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contactsAsync = ref.watch(contactsListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: _selectedIds.isEmpty,
        leading: _selectedIds.isEmpty
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: Icon(Icons.close_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => setState(() => _selectedIds.clear()),
              ),
        title: _selectedIds.isEmpty
            ? Text('جهات الاتصال',
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

                contactsAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (contacts) {
                    var filtered = contacts.toList();
                    if (_vipFilter == 'vip') {
                      filtered = filtered.where((c) => c.isVip).toList();
                    } else if (_vipFilter == 'normal') {
                      filtered = filtered.where((c) => !c.isVip).toList();
                    }
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((c) {
                        return c.name.toLowerCase().contains(q) ||
                            (c.position ?? '').toLowerCase().contains(q) ||
                            (c.company ?? '').toLowerCase().contains(q) ||
                            (c.phoneNumber ?? '').contains(q) ||
                            (c.email ?? '').toLowerCase().contains(q);
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
                            final exportService = ref.read(exportServiceProvider);
                            exportService.exportDataList(
                              context: context,
                              title: 'جهات الاتصال المحددة',
                              items: selectedItems,
                              headers: [
                                'م',
                                'الاسم',
                                'المسمى الوظيفي',
                                'الشركة / الجهة',
                                'رقم الهاتف',
                                'البريد الإلكتروني',
                                'VIP'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final c = entry.value;
                                return [
                                  i.toString(),
                                  c.name,
                                  c.position ?? 'غير محدد',
                                  c.company ?? 'غير محدد',
                                  c.phoneNumber ?? 'غير محدد',
                                  c.email ?? 'غير محدد',
                                  c.isVip ? 'نعم' : 'لا',
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
              searchHint: 'بحث في جهات الاتصال...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _vipFilter,
              onFilterChanged: (v) =>
                  setState(() => _vipFilter = v),
            ),
            AppSpacing.gapMd,

            // Contacts List
            Expanded(
              child: contactsAsync.when(
                data: (contacts) {
                  var filtered = contacts.toList();

                  // VIP filter
                  if (_vipFilter == 'vip') {
                    filtered = filtered
                        .where((c) => c.isVip)
                        .toList();
                  } else if (_vipFilter == 'normal') {
                    filtered = filtered
                        .where((c) => !c.isVip)
                        .toList();
                  }

                  // Search
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((c) {
                      return c.name
                              .toLowerCase()
                              .contains(q) ||
                          (c.position ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (c.company ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (c.phoneNumber ?? '').contains(q) ||
                          (c.email ?? '')
                              .toLowerCase()
                              .contains(q);
                    }).toList();
                  }

                  filtered.sort(_sortOptions[_selectedSortIndex].comparator);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ||
                                _vipFilter != 'all'
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد جهات اتصال مضافة حتى الآن',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.screen,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final contact = filtered[index];
                      final isSelected = _selectedIds.contains(contact.id);

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 16),
                        child: NeuCard(
                          onTap: () {
                            if (_selectedIds.isNotEmpty) {
                              _toggleSelection(contact.id);
                            }
                          },
                          onLongPress: () => _toggleSelection(contact.id),
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
                              CircleAvatar(
                                backgroundColor: isDark
                                    ? NeuColors.surfaceDark
                                    : NeuColors.surface,
                                radius: 24,
                                child: Text(
                                  contact.name.characters.first,
                                  style: TextStyle(
                                    color: contact.isVip
                                        ? NeuColors
                                            .priorityCritical
                                        : (isDark
                                            ? NeuColors
                                                .goldAccent
                                            : NeuColors
                                                .navyDeep),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            contact.name,
                                            style: (isDark
                                                    ? AppTypography
                                                        .h3Dark
                                                    : AppTypography
                                                        .h3)
                                                .copyWith(
                                                    fontSize:
                                                        18),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                          ),
                                        ),
                                        if (contact.isVip)
                                          const Icon(
                                              Icons
                                                  .star_rounded,
                                              color: NeuColors
                                                  .priorityCritical,
                                              size: 18),
                                      ],
                                    ),
                                    if (contact.position !=
                                            null ||
                                        contact.company !=
                                            null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${contact.position ?? ''} ${contact.company != null ? '- ${contact.company}' : ''}',
                                        style: (isDark
                                                ? AppTypography
                                                    .bodySmallDark
                                                : AppTypography
                                                    .bodySmall)
                                            .copyWith(
                                          color: isDark
                                              ? NeuColors
                                                  .textSecondaryDark
                                              : NeuColors
                                                  .textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
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
                                  onPressed: () => context.push(RouteNames.contactEditPath(contact.id)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (error, _) => Center(
                    child: Text(
                        'خطأ في جلب جهات الاتصال: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? FloatingActionButton(
              onPressed: () =>
                  context.push(RouteNames.contactCreate),
              backgroundColor: NeuColors.navyDeep,
              child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white),
            )
          : null,
    );
  }
}