import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../core/database/app_database.dart';
import '../domain/finance_repository.dart';

/// Chart of Accounts Screen — دليل الحسابات المحاسبية.
class ChartOfAccountsScreen extends ConsumerWidget {
  const ChartOfAccountsScreen({super.key});

  static const _typeNames = ['أصول', 'خصوم', 'حقوق الملكية', 'إيرادات', 'مصروفات'];
  static const _typeColors = [
    Color(0xFF3B82F6), // أصول - أزرق
    Color(0xFFD62828), // خصوم - أحمر
    NeuColors.moduleDelivery, // حقوق - بنفسجي
    Color(0xFF2E8B57), // إيرادات - أخضر
    Color(0xFFF4A261), // مصروفات - برتقالي
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final async = ref.watch(chartOfAccountsProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('دليل الحسابات',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (accounts) {
            if (accounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_tree_rounded, size: 64, color: NeuColors.textHint),
                    const SizedBox(height: 16),
                    Text('دليل الحسابات فارغ',
                        style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
                    const SizedBox(height: 8),
                    Text('ابدأ بإضافة الحسابات الرئيسية لمؤسستك',
                        style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }

            // Group by type
            final grouped = <int, List<ChartOfAccount>>{};
            for (final a in accounts) {
              grouped.putIfAbsent(a.type, () => []).add(a);
            }

            return ListView(
              padding: AppSpacing.screen,
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: entry.key < _typeColors.length
                                ? _typeColors[entry.key]
                                : NeuColors.navyDeep,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key < _typeNames.length ? _typeNames[entry.key] : '—',
                          style: AppTypography.headingSmall.copyWith(
                              color: entry.key < _typeColors.length
                                  ? _typeColors[entry.key]
                                  : NeuColors.navyDeep,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Text('(${entry.value.length})',
                            style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
                      ],
                    ),
                  ),
                  ...entry.value.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: NeuCard(
                      isDark: isDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (entry.key < _typeColors.length
                                      ? _typeColors[entry.key]
                                      : NeuColors.navyDeep)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(a.code,
                                style: AppTypography.labelSmall.copyWith(
                                    color: entry.key < _typeColors.length
                                        ? _typeColors[entry.key]
                                        : NeuColors.navyDeep,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: textPrimary, fontWeight: FontWeight.w600)),
                                if (!a.isActive)
                                  Text('غير نشط',
                                      style: AppTypography.labelSmall.copyWith(
                                          color: NeuColors.danger)),
                              ],
                            ),
                          ),
                          Text(
                            '${a.currentBalance.toStringAsFixed(2)} ر.س',
                            style: AppTypography.bodySmall.copyWith(
                                color: a.currentBalance >= 0 ? NeuColors.success : NeuColors.danger,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAccountDialog(context, isDark, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('حساب جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, bool isDark, WidgetRef ref) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    int type = 0;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            title: Text('إضافة حساب جديد',
                style: AppTypography.headingSmall.copyWith(color: textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'رقم الحساب', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'اسم الحساب', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: type,
                  decoration: const InputDecoration(
                      labelText: 'نوع الحساب', border: OutlineInputBorder()),
                  items: List.generate(_typeNames.length,
                      (i) => DropdownMenuItem(value: i, child: Text(_typeNames[i]))),
                  onChanged: (v) => setState(() => type = v ?? 0),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                  await ref.read(financeRepositoryProvider).createAccount(
                        code: codeCtrl.text,
                        name: nameCtrl.text,
                        type: type,
                      );
                  if (ctx.mounted) ctx.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: NeuColors.navyDeep, foregroundColor: Colors.white),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
