import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_input.dart';
import '../../../core/database/app_database.dart';
import '../domain/finance_repository.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../core/design/azm_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bank Accounts Screen
// ─────────────────────────────────────────────────────────────────────────────

class BankAccountsScreen extends ConsumerStatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  ConsumerState<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends ConsumerState<BankAccountsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tp = NeuColors.textPrimaryFor(context.brightness);

    return Scaffold(
      backgroundColor: NeuColors.background(context.brightness),
      appBar: AppBar(
        backgroundColor: NeuColors.background(context.brightness),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tp),
          onPressed: () => context.pop(),
        ),
        title: Text('البنوك والشيكات',
            style: AppTypography.h3.copyWith(color: tp)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
            onPressed: () => _tab.index == 0
                ? _showAddBankSheet(context)
                : _showAddCheckSheet(context),
            tooltip: 'إضافة',
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          unselectedLabelColor:
              isDark ? NeuColors.textHintDark : NeuColors.textHint,
          indicatorColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          labelStyle: AppTypography.labelMedium
              .copyWith(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_rounded), text: 'الحسابات البنكية'),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'الشيكات'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tab,
          children: [
            _BankAccountsTab(onAdd: () => _showAddBankSheet(context)),
            _ChecksTab(onAdd: () => _showAddCheckSheet(context)),
          ],
        ),
      ),
    );
  }

  // ─── Add Bank Account Sheet ─────────────────────────────────────────────

  void _showAddBankSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddBankAccountSheet(
        onSaved: (entry) async {
          await ref
              .read(financeRepositoryProvider)
              .insertBankAccountEntry(entry);
        },
      ),
    );
  }

  // ─── Add Check Sheet ────────────────────────────────────────────────────

  void _showAddCheckSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddCheckSheet(
        onSaved: (entry) async {
          await ref
              .read(financeRepositoryProvider)
              .insertCheckEntry(entry);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bank Accounts Tab
// ─────────────────────────────────────────────────────────────────────────────

class _BankAccountsTab extends ConsumerWidget {
  const _BankAccountsTab({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsAsync = ref.watch(bankAccountsProvider);
    final fmt = NumberFormat('#,##0.00');

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(error: e),
      data: (accounts) {
        // Summary
        final totalBalance = accounts.fold<double>(
            0, (s, a) => s + a.currentBalance);

        return Column(
          children: [
            // ── Summary Card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: NeuCard(
                isDark: isDark,
                radius: AzmRadius.sm,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [NeuColors.navyDeep, NeuColors.navyMid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.account_balance_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('إجمالي الأرصدة',
                              style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? NeuColors.textSecondaryDark
                                      : NeuColors.textSecondary)),
                          Text(fmt.format(totalBalance),
                              style: AppTypography.statNumber.copyWith(
                                  color: isDark
                                      ? NeuColors.accentMuted
                                      : NeuColors.navyDeep,
                                  fontSize: 24)),
                          Text('${accounts.length} حساب بنكي',
                              style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? NeuColors.textHintDark
                                      : NeuColors.textHint)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Accounts List ─────────────────────────────────────────
            Expanded(
              child: accounts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_rounded,
                              size: 64,
                              color: isDark
                                  ? NeuColors.textHintDark
                                  : NeuColors.textHint),
                          const SizedBox(height: 16),
                          Text('لا توجد حسابات بنكية',
                              style: AppTypography.body.copyWith(
                                  color: isDark
                                      ? NeuColors.textHintDark
                                      : NeuColors.textHint)),
                          const SizedBox(height: 20),
                          NeuButton(
                            label: 'إضافة حساب بنكي',
                            onPressed: onAdd,
                            icon: Icons.add_rounded,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: accounts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final acc = accounts[i];
                        final currency = AppCurrencies.fromCode(acc.currency);
                        final pct = totalBalance > 0
                            ? (acc.currentBalance / totalBalance)
                            : 0.0;

                        return NeuCard(
                          isDark: isDark,
                          radius: AzmRadius.sm,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Bank Logo / Icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _bankColor(acc.bankName),
                                          _bankColor(acc.bankName)
                                              .withValues(alpha: 0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        acc.bankName.isNotEmpty
                                            ? acc.bankName[0]
                                            : 'B',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Panorama'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(acc.bankName,
                                            style: AppTypography.h4.copyWith(
                                                color: isDark
                                                    ? NeuColors.textPrimaryDark
                                                    : NeuColors.textPrimary)),
                                        if (acc.accountName != null)
                                          Text(acc.accountName!,
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                      color: isDark
                                                          ? NeuColors
                                                              .textSecondaryDark
                                                          : NeuColors
                                                              .textSecondary)),
                                      ],
                                    ),
                                  ),
                                  // Balance
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${fmt.format(acc.currentBalance)} ${currency.symbol}',
                                        style: AppTypography.h4.copyWith(
                                          color: acc.currentBalance >= 0
                                              ? NeuColors.success
                                              : NeuColors.danger,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text('الرصيد الحالي',
                                          style: AppTypography.caption.copyWith(
                                              color: isDark
                                                  ? NeuColors.textHintDark
                                                  : NeuColors.textHint)),
                                    ],
                                  ),
                                ],
                              ),
                              if (acc.accountNumber != null ||
                                  acc.iban != null) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (acc.accountNumber != null)
                                      _InfoChip(
                                        icon: Icons.tag_rounded,
                                        label: acc.accountNumber!,
                                        isDark: isDark,
                                        onCopy: () => _copy(
                                            context, acc.accountNumber!),
                                      ),
                                    if (acc.accountNumber != null &&
                                        acc.iban != null)
                                      const SizedBox(width: 8),
                                    if (acc.iban != null)
                                      Expanded(
                                        child: _InfoChip(
                                          icon: Icons.account_balance_wallet_rounded,
                                          label: acc.iban!,
                                          isDark: isDark,
                                          onCopy: () =>
                                              _copy(context, acc.iban!),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              // Balance bar
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct.clamp(0.0, 1.0),
                                  backgroundColor: isDark
                                      ? NeuColors.surfaceDark
                                      : NeuColors.surface,
                                  valueColor: AlwaysStoppedAnimation(
                                      _bankColor(acc.bankName)),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(pct * 100).toStringAsFixed(1)}% من إجمالي الأرصدة',
                                style: AppTypography.caption.copyWith(
                                    color: isDark
                                        ? NeuColors.textHintDark
                                        : NeuColors.textHint),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Color _bankColor(String bankName) {
    final hash = bankName.hashCode;
    final colors = [
      NeuColors.navyDeep,
      NeuColors.navyMid,
      NeuColors.success,
      NeuColors.moduleDelivery,
      const Color(0xFFE17055),
      NeuColors.goldDark,
      NeuColors.info,
    ];
    return colors[hash.abs() % colors.length];
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ النص ✓', textDirection: TextDirection.rtl),
        backgroundColor: NeuColors.success,
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checks Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ChecksTab extends ConsumerStatefulWidget {
  const _ChecksTab({required this.onAdd});
  final VoidCallback onAdd;

  @override
  ConsumerState<_ChecksTab> createState() => _ChecksTabState();
}

class _ChecksTabState extends ConsumerState<_ChecksTab> {
  int _filterType = -1; // -1=all, 0=incoming, 1=outgoing
  int _filterStatus = -1; // -1=all, 0=pending, 1=deposited, 2=cleared, 3=bounced

  // الحالة يحملها النصّ واللون في `_statusColors` تحته مباشرة،
  // فالإيموجي طبقة ثالثة تقول الشيء نفسه بخطّ النظام لا بخطّ التطبيق.
  static const _statusLabels = ['معلق', 'مُودَع', 'محصَّل', 'مرتجع', 'ملغي'];
  static final _statusColors = [
    NeuColors.warning,
    NeuColors.info,
    NeuColors.success,
    NeuColors.danger,
    NeuColors.textHint,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checksAsync = ref.watch(pendingChecksProvider);
    final fmt = NumberFormat('#,##0.00');

    return checksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(error: e),
      data: (allChecks) {
        var checks = allChecks.toList();
        if (_filterType >= 0) {
          checks = checks.where((c) => c.type == _filterType).toList();
        }
        if (_filterStatus >= 0) {
          checks = checks.where((c) => c.status == _filterStatus).toList();
        }

        final totalIncoming = allChecks
            .where((c) => c.type == 0)
            .fold<double>(0, (s, c) => s + c.amount);
        final totalOutgoing = allChecks
            .where((c) => c.type == 1)
            .fold<double>(0, (s, c) => s + c.amount);

        return Column(
          children: [
            // ── Summary Row ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                Expanded(
                  child: _MiniStat(
                    label: 'شيكات مستلمة',
                    value: fmt.format(totalIncoming),
                    color: NeuColors.success,
                    icon: Icons.south_west_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'شيكات مصدرة',
                    value: fmt.format(totalOutgoing),
                    color: NeuColors.danger,
                    icon: Icons.north_east_rounded,
                    isDark: isDark,
                  ),
                ),
              ]),
            ),

            // ── Filters ──────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'الكل',
                      selected: _filterType == -1,
                      onTap: () => setState(() => _filterType = -1),
                      color: NeuColors.navyDeep,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'مستلمة',
                      selected: _filterType == 0,
                      onTap: () => setState(() => _filterType = 0),
                      color: NeuColors.success,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'مصدرة',
                      selected: _filterType == 1,
                      onTap: () => setState(() => _filterType = 1),
                      color: NeuColors.danger,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 16),
                    _FilterChip(
                      label: 'معلقة',
                      selected: _filterStatus == 0,
                      onTap: () => setState(
                          () => _filterStatus = _filterStatus == 0 ? -1 : 0),
                      color: NeuColors.warning,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'محصّلة',
                      selected: _filterStatus == 2,
                      onTap: () => setState(
                          () => _filterStatus = _filterStatus == 2 ? -1 : 2),
                      color: NeuColors.success,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'مرتجعة',
                      selected: _filterStatus == 3,
                      onTap: () => setState(
                          () => _filterStatus = _filterStatus == 3 ? -1 : 3),
                      color: NeuColors.danger,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // ── Checks List ──────────────────────────────────────────
            Expanded(
              child: checks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 64,
                              color: isDark
                                  ? NeuColors.textHintDark
                                  : NeuColors.textHint),
                          const SizedBox(height: 16),
                          Text('لا توجد شيكات',
                              style: AppTypography.body.copyWith(
                                  color: isDark
                                      ? NeuColors.textHintDark
                                      : NeuColors.textHint)),
                          const SizedBox(height: 20),
                          NeuButton(
                            label: 'إضافة شيك',
                            onPressed: widget.onAdd,
                            icon: Icons.add_rounded,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: checks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final check = checks[i];
                        final isIncoming = check.type == 0;
                        final statusIdx = check.status.clamp(0, 4);
                        final statusColor = _statusColors[statusIdx];
                        final dueDate = DateTime.tryParse(check.dueDate);
                        final isOverdue = dueDate != null &&
                            dueDate.isBefore(DateTime.now()) &&
                            check.status == 0;
                        final currency = AppCurrencies.fromCode(check.currency);

                        return NeuCard(
                          isDark: isDark,
                          radius: AzmRadius.sm,
                          padding: const EdgeInsets.all(14),
                          statusColor: isIncoming
                              ? NeuColors.success
                              : NeuColors.danger,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                // Direction Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isIncoming
                                            ? NeuColors.success
                                            : NeuColors.danger)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isIncoming
                                            ? Icons.south_west_rounded
                                            : Icons.north_east_rounded,
                                        size: 12,
                                        color: isIncoming
                                            ? NeuColors.success
                                            : NeuColors.danger,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isIncoming ? 'مستلم' : 'مصدر',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isIncoming
                                              ? NeuColors.success
                                              : NeuColors.danger,
                                          fontFamily: 'Panorama',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusLabels[statusIdx],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                      fontFamily: 'Panorama',
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('رقم: ${check.checkNumber}',
                                          style: AppTypography.h4.copyWith(
                                              color: isDark
                                                  ? NeuColors.textPrimaryDark
                                                  : NeuColors.textPrimary)),
                                      if (check.bankName != null)
                                        Text(check.bankName!,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                    color: isDark
                                                        ? NeuColors
                                                            .textSecondaryDark
                                                        : NeuColors
                                                            .textSecondary)),
                                      if (check.partyName != null)
                                        Row(children: [
                                          Icon(Icons.person_rounded,
                                              size: 12,
                                              color: isDark
                                                  ? NeuColors.textHintDark
                                                  : NeuColors.textHint),
                                          const SizedBox(width: 4),
                                          Text(check.partyName!,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                      color: isDark
                                                          ? NeuColors
                                                              .textHintDark
                                                          : NeuColors
                                                              .textHint)),
                                        ]),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${NumberFormat('#,##0.00').format(check.amount)} ${currency.symbol}',
                                      style: AppTypography.h4.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isIncoming
                                            ? NeuColors.success
                                            : NeuColors.danger,
                                      ),
                                    ),
                                    Row(children: [
                                      Icon(Icons.event_rounded,
                                          size: 12,
                                          color: isOverdue
                                              ? NeuColors.danger
                                              : (isDark
                                                  ? NeuColors.textHintDark
                                                  : NeuColors.textHint)),
                                      const SizedBox(width: 4),
                                      Text(
                                        check.dueDate,
                                        style: AppTypography.caption.copyWith(
                                          color: isOverdue
                                              ? NeuColors.danger
                                              : (isDark
                                                  ? NeuColors.textHintDark
                                                  : NeuColors.textHint),
                                          fontWeight: isOverdue
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                      if (isOverdue) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                            Icons.error_outline_rounded,
                                            size: 12,
                                            color: NeuColors.danger),
                                      ],
                                    ]),
                                  ],
                                ),
                              ]),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Bank Account Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddBankAccountSheet extends ConsumerStatefulWidget {
  const _AddBankAccountSheet({required this.onSaved});
  final Future<void> Function(BankAccountsCompanion) onSaved;

  @override
  ConsumerState<_AddBankAccountSheet> createState() =>
      _AddBankAccountSheetState();
}

class _AddBankAccountSheetState extends ConsumerState<_AddBankAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _openingBalanceCtrl = TextEditingController(text: '0');
  String _currency = 'SAR';
  bool _isLoading = false;

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ibanCtrl.dispose();
    _branchCtrl.dispose();
    _openingBalanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final now = DateTime.now().millisecondsSinceEpoch;
    final bal =
        double.tryParse(_openingBalanceCtrl.text.replaceAll(',', '')) ?? 0;
    try {
      await widget.onSaved(BankAccountsCompanion.insert(
        syncId: const Uuid().v4(),
        bankName: _bankNameCtrl.text.trim(),
        accountName: drift.Value(_accountNameCtrl.text.trim().isEmpty
            ? null
            : _accountNameCtrl.text.trim()),
        accountNumber: drift.Value(_accountNumberCtrl.text.trim().isEmpty
            ? null
            : _accountNumberCtrl.text.trim()),
        iban: drift.Value(
            _ibanCtrl.text.trim().isEmpty ? null : _ibanCtrl.text.trim()),
        currency: drift.Value(_currency),
        branch: drift.Value(
            _branchCtrl.text.trim().isEmpty ? null : _branchCtrl.text.trim()),
        openingBalance: drift.Value(bal),
        currentBalance: drift.Value(bal),
        isActive: const drift.Value(true),
        createdAt: now,
        updatedAt: now,
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('تمت إضافة الحساب ✓', textDirection: TextDirection.rtl),
          backgroundColor: NeuColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ: $e', textDirection: TextDirection.rtl),
          backgroundColor: NeuColors.danger,
        ));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(
          color:
              isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? NeuColors.dividerDark
                          : NeuColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('إضافة حساب بنكي',
                    style: AppTypography.h3.copyWith(
                        color: isDark
                            ? NeuColors.textPrimaryDark
                            : NeuColors.textPrimary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),

                NeuInput(
                  controller: _bankNameCtrl,
                  label: 'اسم البنك *',
                  hint: 'مثال: البنك الأهلي',
                  prefixIcon: Icons.account_balance_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 14),
                NeuInput(
                  controller: _accountNameCtrl,
                  label: 'اسم الحساب',
                  hint: 'مثال: الحساب الجاري الرئيسي',
                  prefixIcon: Icons.badge_rounded,
                ),
                const SizedBox(height: 14),
                NeuInput(
                  controller: _accountNumberCtrl,
                  label: 'رقم الحساب',
                  hint: '0000000000',
                  prefixIcon: Icons.tag_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                NeuInput(
                  controller: _ibanCtrl,
                  label: 'رقم الآيبان (IBAN)',
                  hint: 'SA0000000000000000000000',
                  prefixIcon: Icons.credit_card_rounded,
                ),
                const SizedBox(height: 14),
                NeuInput(
                  controller: _branchCtrl,
                  label: 'الفرع',
                  hint: 'مثال: فرع الرياض',
                  prefixIcon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 14),

                // Currency picker
                Text('العملة',
                    style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? NeuColors.textSecondaryDark
                            : NeuColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: AppCurrencies.all.map((c) {
                    final sel = _currency == c.code;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currency = c.code),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: sel
                                ? NeuColors.navyDeep
                                : (isDark
                                    ? NeuColors.surfaceDark
                                    : NeuColors.surface),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: sel
                                    ? NeuColors.navyDeep
                                    : NeuColors.divider),
                          ),
                          child: Column(
                            children: [
                              Text(c.symbol,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: sel
                                          ? Colors.white
                                          : (isDark
                                              ? NeuColors.textPrimaryDark
                                              : NeuColors.textPrimary))),
                              Text(c.code,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: sel
                                          ? Colors.white70
                                          : (isDark
                                              ? NeuColors.textHintDark
                                              : NeuColors.textHint),
                                      fontFamily: 'Panorama')),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                NeuInput(
                  controller: _openingBalanceCtrl,
                  label: 'الرصيد الافتتاحي',
                  hint: '0.00',
                  prefixIcon: Icons.account_balance_wallet_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 28),
                NeuButton(
                  label: 'حفظ الحساب',
                  onPressed: _isLoading ? null : _save,
                  isLoading: _isLoading,
                  icon: Icons.save_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Check Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddCheckSheet extends ConsumerStatefulWidget {
  const _AddCheckSheet({required this.onSaved});
  final Future<void> Function(ChecksCompanion) onSaved;

  @override
  ConsumerState<_AddCheckSheet> createState() => _AddCheckSheetState();
}

class _AddCheckSheetState extends ConsumerState<_AddCheckSheet> {
  final _formKey = GlobalKey<FormState>();
  final _checkNumberCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _partyNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _type = 0; // 0=incoming, 1=outgoing
  final String _currency = 'SAR';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _issueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _checkNumberCtrl.dispose();
    _bankNameCtrl.dispose();
    _amountCtrl.dispose();
    _partyNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final now = DateTime.now().millisecondsSinceEpoch;
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    try {
      await widget.onSaved(ChecksCompanion.insert(
        syncId: const Uuid().v4(),
        checkNumber: _checkNumberCtrl.text.trim(),
        bankName: drift.Value(_bankNameCtrl.text.trim().isEmpty
            ? null
            : _bankNameCtrl.text.trim()),
        amount: drift.Value(amount),
        currency: drift.Value(_currency),
        issueDate: drift.Value(_issueDate?.toIso8601String().split('T').first),
        dueDate: _dueDate.toIso8601String().split('T').first,
        partyName: drift.Value(_partyNameCtrl.text.trim().isEmpty
            ? null
            : _partyNameCtrl.text.trim()),
        type: _type,
        status: const drift.Value(0), // pending
        notes: drift.Value(
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        createdAt: now,
        updatedAt: now,
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('تمت إضافة الشيك ✓', textDirection: TextDirection.rtl),
          backgroundColor: NeuColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ: $e', textDirection: TextDirection.rtl),
          backgroundColor: NeuColors.danger,
        ));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = DateFormat('yyyy/MM/dd', 'ar');

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(
          color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? NeuColors.dividerDark : NeuColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('إضافة شيك',
                    style: AppTypography.h3.copyWith(
                        color: isDark
                            ? NeuColors.textPrimaryDark
                            : NeuColors.textPrimary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),

                // Type selector
                Text('نوع الشيك',
                    style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? NeuColors.textSecondaryDark
                            : NeuColors.textSecondary)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 0
                              ? NeuColors.success.withValues(alpha: 0.15)
                              : (isDark
                                  ? NeuColors.surfaceDark
                                  : NeuColors.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _type == 0
                                ? NeuColors.success
                                : NeuColors.divider,
                            width: _type == 0 ? 1.5 : 1,
                          ),
                        ),
                        child: Column(children: [
                          Icon(Icons.south_west_rounded,
                              color: _type == 0
                                  ? NeuColors.success
                                  : NeuColors.textHint),
                          const SizedBox(height: 4),
                          Text('مستلم',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _type == 0
                                      ? NeuColors.success
                                      : NeuColors.textHint,
                                  fontFamily: 'Panorama')),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 1
                              ? NeuColors.danger.withValues(alpha: 0.15)
                              : (isDark
                                  ? NeuColors.surfaceDark
                                  : NeuColors.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _type == 1
                                ? NeuColors.danger
                                : NeuColors.divider,
                            width: _type == 1 ? 1.5 : 1,
                          ),
                        ),
                        child: Column(children: [
                          Icon(Icons.north_east_rounded,
                              color: _type == 1
                                  ? NeuColors.danger
                                  : NeuColors.textHint),
                          const SizedBox(height: 4),
                          Text('مصدر',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _type == 1
                                      ? NeuColors.danger
                                      : NeuColors.textHint,
                                  fontFamily: 'Panorama')),
                        ]),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                NeuInput(
                  controller: _checkNumberCtrl,
                  label: 'رقم الشيك *',
                  hint: '0001234',
                  prefixIcon: Icons.tag_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                NeuInput(
                  controller: _bankNameCtrl,
                  label: 'البنك',
                  hint: 'اسم البنك',
                  prefixIcon: Icons.account_balance_rounded,
                ),
                const SizedBox(height: 12),
                NeuInput(
                  controller: _amountCtrl,
                  label: 'المبلغ *',
                  hint: '0.00',
                  prefixIcon: Icons.monetization_on_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                NeuInput(
                  controller: _partyNameCtrl,
                  label: 'اسم الجهة',
                  hint: 'عميل / مورد / موظف',
                  prefixIcon: Icons.person_rounded,
                ),
                const SizedBox(height: 14),

                // Due Date
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      locale: const Locale('ar'),
                    );
                    if (d != null) setState(() => _dueDate = d);
                  },
                  child: NeuCard(
                    isDark: isDark,
                    margin: EdgeInsets.zero,
                    radius: 12,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Icon(Icons.event_rounded,
                          size: 18,
                          color: isDark
                              ? NeuColors.accentMuted
                              : NeuColors.navyMid),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تاريخ الاستحقاق *',
                              style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? NeuColors.textHintDark
                                      : NeuColors.textHint)),
                          Text(fmt.format(_dueDate),
                              style: AppTypography.body.copyWith(
                                  color: isDark
                                      ? NeuColors.textPrimaryDark
                                      : NeuColors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                NeuInput(
                  controller: _notesCtrl,
                  label: 'ملاحظات',
                  hint: 'ملاحظات إضافية',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 28),
                NeuButton(
                  label: 'حفظ الشيك',
                  onPressed: _isLoading ? null : _save,
                  isLoading: _isLoading,
                  icon: Icons.save_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onCopy,
  });
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCopy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isDark ? NeuColors.dividerDark : NeuColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12,
                color:
                    isDark ? NeuColors.textHintDark : NeuColors.textHint),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.copy_rounded,
                size: 10,
                color:
                    isDark ? NeuColors.textHintDark : NeuColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      isDark: isDark,
      radius: AzmRadius.sm,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.caption.copyWith(
                      color: isDark
                          ? NeuColors.textHintDark
                          : NeuColors.textHint)),
              Text(value,
                  style: AppTypography.h4.copyWith(
                      color: color, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.isDark,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color
              : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? Colors.white
                : (isDark ? NeuColors.textSecondaryDark : color),
            fontFamily: 'Panorama',
          ),
        ),
      ),
    );
  }
}

// Extension
extension _BrightnessExt on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
}