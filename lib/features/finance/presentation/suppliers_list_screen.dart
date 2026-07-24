import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';

/// Suppliers List Screen — قائمة الموردين.
class SuppliersListScreen extends ConsumerWidget {
  const SuppliersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final suppliersAsync = ref.watch(_suppliersStreamProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('الموردون',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: suppliersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (suppliers) {
            if (suppliers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 64, color: NeuColors.textHint),
                    const SizedBox(height: 16),
                    Text('لا يوجد موردون مسجلون',
                        style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
                    const SizedBox(height: 8),
                    Text('أضف الموردين الذين تتعامل معهم',
                        style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: suppliers.length,
              itemBuilder: (_, i) {
                final s = suppliers[i];
                final initials = s.name.isNotEmpty
                    ? s.name.trim().split(' ').take(2).map((w) => w[0]).join()
                    : '؟';
                final balance = s.currentBalance;
                final balanceColor = balance >= 0 ? NeuColors.success : NeuColors.danger;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeuCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFFE17055), const Color(0xFFFF7675)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(initials,
                                style: AppTypography.headingSmall.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(s.name,
                                        style: AppTypography.bodyMedium.copyWith(
                                            color: textPrimary, fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text('${balance.toStringAsFixed(2)} ر.س',
                                      style: AppTypography.bodySmall.copyWith(
                                          color: balanceColor, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              if (s.phone != null)
                                Row(children: [
                                  Icon(Icons.phone_rounded, size: 13, color: NeuColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(s.phone!, style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                                ]),
                              if (s.city != null || s.category != null)
                                Text(
                                  [s.city, s.category].where((v) => v != null).join('  •  '),
                                  style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, isDark, ref),
        backgroundColor: const Color(0xFFE17055),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('مورد جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, bool isDark, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
          title: Text('إضافة مورد جديد',
              style: AppTypography.headingSmall.copyWith(color: textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'الاسم *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'الهاتف', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(
                      labelText: 'المدينة', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                      labelText: 'الفئة (مواد، خدمات...)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final db = ref.read(databaseProvider);
                await db.financeDao.insertSupplier(SuppliersCompanion(
                  name: Value(nameCtrl.text),
                  phone: Value(phoneCtrl.text.isEmpty ? null : phoneCtrl.text),
                  email: Value(emailCtrl.text.isEmpty ? null : emailCtrl.text),
                  city: Value(cityCtrl.text.isEmpty ? null : cityCtrl.text),
                  category: Value(categoryCtrl.text.isEmpty ? null : categoryCtrl.text),
                  isActive: const Value(true),
                  currentBalance: const Value(0.0),
                ));
                if (ctx.mounted) ctx.pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE17055), foregroundColor: Colors.white),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

final _suppliersStreamProvider = StreamProvider<List<Supplier>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.financeDao.watchSuppliers();
});