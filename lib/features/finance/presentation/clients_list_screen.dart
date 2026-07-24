import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/finance_repository.dart';

/// Clients List Screen — shows all active clients with search.
class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _typeFilter = -1; // -1 = all

  static const _typeLabels = ['الكل', 'فرد', 'شركة', 'حكومي', 'منظمة'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final clientsAsync = ref.watch(clientsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text(
          'العملاء',
          style: AppTypography.headingSmall.copyWith(
            color: textPrimary, fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.clientCreate),
            icon: Icon(Icons.person_add_rounded, color: const Color(0xFF00B894)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: NeuCard(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'بحث عن عميل...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: NeuColors.textHint),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); },
                          icon: const Icon(Icons.clear_rounded),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Type Filter ──────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _typeLabels.length,
              itemBuilder: (context, i) {
                final selected = (i == 0 && _typeFilter == -1) ||
                    (i > 0 && _typeFilter == i - 1);
                return GestureDetector(
                  onTap: () => setState(() => _typeFilter = i == 0 ? -1 : i - 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF00B894)
                          : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _typeLabels[i],
                      style: AppTypography.labelSmall.copyWith(
                        color: selected ? Colors.white
                            : NeuColors.textSecondaryFor(isDark ? Brightness.dark : Brightness.light),
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: clientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('خطأ: $e',
                    style: AppTypography.bodyMedium.copyWith(color: NeuColors.danger)),
              ),
              data: (clients) {
                var filtered = clients.where((c) {
                  final matchQ = _query.isEmpty ||
                      c.name.toLowerCase().contains(_query.toLowerCase()) ||
                      (c.phone?.contains(_query) ?? false) ||
                      (c.email?.toLowerCase().contains(_query.toLowerCase()) ?? false);
                  final matchType = _typeFilter == -1 || c.type == _typeFilter;
                  return matchQ && matchType;
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyClients(isDark: isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _ClientCard(
                    client: filtered[i],
                    isDark: isDark,
                    onTap: () => context.push(
                      RouteNames.clientDetailPath(filtered[i].id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.clientCreate),
        backgroundColor: const Color(0xFF00B894),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('عميل جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }
}

// ── Client Card ────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.isDark,
    required this.onTap,
  });
  final Client client;
  final bool isDark;
  final VoidCallback onTap;

  static const _typeIcons = [
    Icons.person_rounded,
    Icons.business_rounded,
    Icons.account_balance_rounded,
    Icons.volunteer_activism_rounded,
  ];

  String get _initials {
    final parts = client.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0].isNotEmpty ? parts[0][0] : '?';
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final typeIdx = client.type.clamp(0, 3);

    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: client.type == 1
                    ? Icon(_typeIcons[typeIdx], color: Colors.white, size: 22)
                    : Text(_initials,
                        style: AppTypography.headingSmall.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700,
                        )),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name,
                      style: AppTypography.bodyMedium.copyWith(
                          color: textPrimary, fontWeight: FontWeight.w700)),
                  if (client.phone != null) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.phone_rounded, size: 12, color: NeuColors.textHint),
                      const SizedBox(width: 4),
                      Text(client.phone!,
                          style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                    ]),
                  ],
                  if (client.city != null) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.location_on_rounded, size: 12, color: NeuColors.textHint),
                      const SizedBox(width: 4),
                      Text(client.city!,
                          style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
                    ]),
                  ],
                ],
              ),
            ),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (client.currentBalance != 0)
                  Text(
                    '${client.currentBalance.toStringAsFixed(0)} ر',
                    style: AppTypography.labelMedium.copyWith(
                      color: client.currentBalance > 0
                          ? NeuColors.success
                          : NeuColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right_rounded,
                    color: NeuColors.textHint, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyClients extends StatelessWidget {
  const _EmptyClients({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.supervisor_account_rounded,
                size: 56, color: const Color(0xFF00B894).withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 20),
          Text('لا يوجد عملاء',
              style: AppTypography.headingSmall.copyWith(color: NeuColors.textHint)),
          const SizedBox(height: 8),
          Text('أضف أول عميل بالضغط على الزر أدناه',
              style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
        ],
      ),
    );
  }
}