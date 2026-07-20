import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../followups/providers/follow_ups_provider.dart';
import '../../hrm/domain/hrm_repository.dart';
import '../../finance/domain/finance_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/neu_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search Result Model
// ─────────────────────────────────────────────────────────────────────────────
enum SearchResultType { followup, employee, client, project, invoice, meeting }

class SearchResult {
  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final SearchResultType type;
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Global Search Screen
// ─────────────────────────────────────────────────────────────────────────────
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  SearchResultType? _typeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    _ctrl.addListener(() => setState(() => _query = _ctrl.text.trim()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<SearchResult> _buildResults({
    required List<FollowUp> followups,
    required List<Employee> employees,
    required List<Client> clients,
    required List<Project> projects,
    required List<Invoice> invoices,
  }) {
    if (_query.length < 2) return [];
    final q = _query.toLowerCase();
    final results = <SearchResult>[];

    // Follow-ups
    for (final f in followups) {
      if (f.title.toLowerCase().contains(q) ||
          (f.notes?.toLowerCase().contains(q) ?? false)) {
        if (_typeFilter == null || _typeFilter == SearchResultType.followup) {
          results.add(SearchResult(
            type: SearchResultType.followup, id: f.id,
            title: f.title, subtitle: f.notes ?? '',
            icon: Icons.replay_rounded, color: NeuColors.navyDeep,
          ));
        }
      }
    }

    // Employees
    for (final e in employees) {
      if (e.name.toLowerCase().contains(q) ||
          (e.positionName?.toLowerCase().contains(q) ?? false) ||
          (e.phone?.contains(q) ?? false)) {
        if (_typeFilter == null || _typeFilter == SearchResultType.employee) {
          results.add(SearchResult(
            type: SearchResultType.employee, id: e.id,
            title: e.name,
            subtitle: e.positionName ?? e.departmentName ?? 'موظف',
            icon: Icons.badge_rounded, color: const Color(0xFF6C5CE7),
          ));
        }
      }
    }

    // Clients
    for (final c in clients) {
      if (c.name.toLowerCase().contains(q) ||
          (c.phone?.contains(q) ?? false) ||
          (c.email?.toLowerCase().contains(q) ?? false)) {
        if (_typeFilter == null || _typeFilter == SearchResultType.client) {
          results.add(SearchResult(
            type: SearchResultType.client, id: c.id,
            title: c.name,
            subtitle: c.phone ?? c.email ?? 'عميل',
            icon: Icons.supervisor_account_rounded, color: const Color(0xFF00B894),
          ));
        }
      }
    }

    // Projects
    for (final p in projects) {
      if (p.name.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false)) {
        if (_typeFilter == null || _typeFilter == SearchResultType.project) {
          results.add(SearchResult(
            type: SearchResultType.project, id: p.id,
            title: p.name,
            subtitle: p.description ?? 'مشروع',
            icon: Icons.work_rounded, color: const Color(0xFFE17055),
          ));
        }
      }
    }

    // Invoices
    for (final i in invoices) {
      final numStr = i.invoiceNumber ?? '';
      final clientStr = i.clientName ?? '';
      if (numStr.toLowerCase().contains(q) || clientStr.toLowerCase().contains(q)) {
        if (_typeFilter == null || _typeFilter == SearchResultType.invoice) {
          results.add(SearchResult(
            type: SearchResultType.invoice, id: i.id,
            title: numStr.isNotEmpty ? 'فاتورة رقم $numStr' : 'فاتورة #${i.id}',
            subtitle: i.clientName ?? 'فاتورة مبيعات',
            icon: Icons.receipt_long_rounded, color: const Color(0xFF00CEC9),
          ));
        }
      }
    }

    return results.take(50).toList();
  }

  void _navigate(SearchResult result) {
    switch (result.type) {
      case SearchResultType.followup:
        context.push(RouteNames.followupDetailPath(result.id));
        break;
      case SearchResultType.employee:
        context.push(RouteNames.employeeDetailPath(result.id));
        break;
      case SearchResultType.client:
        context.push(RouteNames.clientDetailPath(result.id));
        break;
      case SearchResultType.project:
        context.push(RouteNames.projectDetailPath(result.id));
        break;
      case SearchResultType.invoice:
        context.push(RouteNames.invoiceDetailPath(result.id));
        break;
      case SearchResultType.meeting:
        context.push(RouteNames.meetingDetailPath(result.id));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? NeuColors.bgColorDark : NeuColors.bgColor;

    final followups = ref.watch(followUpsListProvider).valueOrNull ?? [];
    final employees = ref.watch(employeesListProvider).valueOrNull ?? [];
    final clients = ref.watch(clientsListProvider).valueOrNull ?? [];
    final projects = ref.watch(projectsListProvider).valueOrNull ?? [];
    final invoices = ref.watch(invoicesListProvider).valueOrNull ?? [];

    final results = _buildResults(
      followups: followups,
      employees: employees,
      clients: clients,
      projects: projects,
      invoices: invoices,
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── Search Bar ────────────────────────────────────
              Container(
                color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark ? NeuColors.dividerDark : NeuColors.divider),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Icon(Icons.search_rounded, color: isDark
                                ? NeuColors.goldAccent : NeuColors.navyDeep, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                focusNode: _focusNode,
                                textDirection: TextDirection.rtl,
                                style: AppTypography.body.copyWith(
                                    color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'ابحث في كل شيء...',
                                  hintStyle: AppTypography.body.copyWith(
                                      color: isDark
                                          ? NeuColors.textHintDark
                                          : NeuColors.textHint),
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) {},
                              ),
                            ),
                            if (_query.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _ctrl.clear();
                                  setState(() => _query = '');
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Type Filter Strip ─────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  _FilterChip(
                    label: 'الكل',
                    icon: Icons.apps_rounded,
                    selected: _typeFilter == null,
                    color: NeuColors.navyDeep,
                    isDark: isDark,
                    onTap: () => setState(() => _typeFilter = null),
                  ),
                  _FilterChip(
                    label: 'متابعات',
                    icon: Icons.replay_rounded,
                    selected: _typeFilter == SearchResultType.followup,
                    color: NeuColors.navyDeep,
                    isDark: isDark,
                    onTap: () => setState(() => _typeFilter =
                        _typeFilter == SearchResultType.followup
                            ? null : SearchResultType.followup),
                  ),
                  _FilterChip(
                    label: 'موظفون',
                    icon: Icons.badge_rounded,
                    selected: _typeFilter == SearchResultType.employee,
                    color: const Color(0xFF6C5CE7),
                    isDark: isDark,
                    onTap: () => setState(() => _typeFilter =
                        _typeFilter == SearchResultType.employee
                            ? null : SearchResultType.employee),
                  ),
                  _FilterChip(
                    label: 'عملاء',
                    icon: Icons.supervisor_account_rounded,
                    selected: _typeFilter == SearchResultType.client,
                    color: const Color(0xFF00B894),
                    isDark: isDark,
                    onTap: () => setState(() => _typeFilter =
                        _typeFilter == SearchResultType.client
                            ? null : SearchResultType.client),
                  ),
                  _FilterChip(
                    label: 'مشاريع',
                    icon: Icons.work_rounded,
                    selected: _typeFilter == SearchResultType.project,
                    color: const Color(0xFFE17055),
                    isDark: isDark,
                    onTap: () => setState(() => _typeFilter =
                        _typeFilter == SearchResultType.project
                            ? null : SearchResultType.project),
                  ),
                  _FilterChip(
                    label: 'فواتير',
                    icon: Icons.receipt_long_rounded,
                    selected: _typeFilter == SearchResultType.invoice,
                    color: const Color(0xFF00CEC9),
                    isDark: isDark,
                    onTap: () => setState(() => _typeFilter =
                        _typeFilter == SearchResultType.invoice
                            ? null : SearchResultType.invoice),
                  ),
                ]),
              ),

              // ── Results Counter ───────────────────────────────
              if (_query.length >= 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${results.length} نتيجة',
                      style: AppTypography.caption.copyWith(
                          color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                    ),
                  ),
                ),

              // ── Results ───────────────────────────────────────
              Expanded(
                child: _query.length < 2
                    ? _EmptyState(isDark: isDark)
                    : results.isEmpty
                        ? _NoResults(query: _query, isDark: isDark)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final r = results[i];
                              return _ResultTile(
                                result: r,
                                isDark: isDark,
                                query: _query,
                                onTap: () => _navigate(r),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chip
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label, required this.icon,
    required this.selected, required this.color,
    required this.isDark, required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected, isDark;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : color.withOpacity(0.3), width: 1.2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: selected ? Colors.white : color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(
            fontSize: 12, fontFamily: 'Cairo',
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : color,
          )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result, required this.isDark,
    required this.query, required this.onTap,
  });

  final SearchResult result;
  final bool isDark;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final ts = isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary;

    return NeuCard(
      isDark: isDark, radius: 14,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: result.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(result.icon, color: result.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HighlightedText(
                text: result.title, query: query,
                style: AppTypography.body.copyWith(
                    color: tp, fontWeight: FontWeight.w600),
                highlightColor: result.color,
              ),
              if (result.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(result.subtitle,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: ts)),
              ],
            ],
          )),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Highlighted Text — bolds the matching query
// ─────────────────────────────────────────────────────────────────────────────
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text, required this.query,
    required this.style, required this.highlightColor,
  });

  final String text, query;
  final TextStyle style;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    if (index < 0) return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);

    return Text.rich(
      TextSpan(
        children: [
          if (index > 0) TextSpan(text: text.substring(0, index), style: style),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: style.copyWith(
              color: highlightColor,
              fontWeight: FontWeight.w800,
              backgroundColor: highlightColor.withOpacity(0.12),
            ),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length), style: style),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty & No-results states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.manage_search_rounded, size: 64,
          color: (isDark ? NeuColors.goldAccent : NeuColors.navyDeep).withOpacity(0.3)),
      const SizedBox(height: 16),
      Text('ابدأ الكتابة للبحث', style: AppTypography.bodySmall.copyWith(color: th)),
      const SizedBox(height: 6),
      Text('يبحث في المتابعات، الموظفين، العملاء، المشاريع والفواتير',
          style: AppTypography.caption.copyWith(color: th), textAlign: TextAlign.center),
    ]));
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.isDark});
  final String query;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search_off_rounded, size: 64,
          color: (isDark ? NeuColors.goldAccent : NeuColors.navyDeep).withOpacity(0.3)),
      const SizedBox(height: 16),
      Text('لا توجد نتائج لـ "$query"',
          style: AppTypography.bodySmall.copyWith(color: th)),
      const SizedBox(height: 6),
      Text('جرّب كلمات أخرى أو تحقق من التهجئة',
          style: AppTypography.caption.copyWith(color: th)),
    ]));
  }
}
