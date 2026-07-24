import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';

/// Branches Screen — manage company branches and offices.
class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final branchesAsync = ref.watch(branchesListProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('الفروع والمكاتب',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: branchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (branches) {
            if (branches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_city_rounded, size: 64, color: NeuColors.textHint),
                    const SizedBox(height: 16),
                    Text('لا توجد فروع مسجلة',
                        style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
                    const SizedBox(height: 8),
                    Text('أضف الفروع والمكاتب لتنظيم هيكل المؤسسة',
                        style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: branches.length,
              itemBuilder: (_, i) {
                final b = branches[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeuCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: b.isMainBranch == true
                                  ? [NeuColors.goldDark, NeuColors.goldAccent]
                                  : [NeuColors.navyDeep, NeuColors.navyMid],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            b.isMainBranch == true
                                ? Icons.star_rounded
                                : Icons.location_city_rounded,
                            color: Colors.white,
                            size: 22,
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
                                    child: Text(b.name,
                                        style: AppTypography.bodyMedium.copyWith(
                                            color: textPrimary, fontWeight: FontWeight.w700)),
                                  ),
                                  if (b.isMainBranch == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: NeuColors.goldDark.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: NeuColors.goldDark.withValues(alpha: 0.4)),
                                      ),
                                      child: Text('الرئيسي',
                                          style: AppTypography.labelSmall.copyWith(
                                              color: NeuColors.goldDark,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                ],
                              ),
                              if (b.city != null) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        size: 14, color: NeuColors.textHint),
                                    const SizedBox(width: 4),
                                    Text(b.city!,
                                        style: AppTypography.bodySmall.copyWith(
                                            color: textSecondary)),
                                  ],
                                ),
                              ],
                              if (b.address != null) ...[
                                const SizedBox(height: 2),
                                Text(b.address!,
                                    style: AppTypography.bodySmall.copyWith(
                                        color: NeuColors.textHint),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                              if (b.phone != null)
                                Row(
                                  children: [
                                    Icon(Icons.phone_rounded,
                                        size: 13, color: NeuColors.textHint),
                                    const SizedBox(width: 4),
                                    Text(b.phone!,
                                        style: AppTypography.bodySmall.copyWith(
                                            color: NeuColors.textHint)),
                                  ],
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
        onPressed: () => _showCreateBranchDialog(context, isDark, ref),
        backgroundColor: const Color(0xFF74B9FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('فرع جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateBranchDialog(BuildContext context, bool isDark, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool isMain = false;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            title: Text('إضافة فرع جديد',
                style: AppTypography.headingSmall.copyWith(color: textPrimary)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'اسم الفرع *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(
                        labelText: 'المدينة', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                        labelText: 'العنوان', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'رقم الهاتف', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: isMain,
                    onChanged: (v) => setState(() => isMain = v ?? false),
                    title: const Text('الفرع الرئيسي'),
                    activeColor: NeuColors.goldDark,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  final repo = ref.read(hrmRepositoryProvider);
                  await repo.createBranch(
                    name: nameCtrl.text,
                    city: cityCtrl.text.isEmpty ? null : cityCtrl.text,
                    address: addressCtrl.text.isEmpty ? null : addressCtrl.text,
                    phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                    isMain: isMain,
                  );
                  if (ctx.mounted) ctx.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF74B9FF), foregroundColor: Colors.white),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}