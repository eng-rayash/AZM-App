import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';
import '../../../core/database/app_database.dart';

/// Leaves List Screen — manage employee leave requests.
class LeavesListScreen extends ConsumerStatefulWidget {
  const LeavesListScreen({super.key});

  @override
  ConsumerState<LeavesListScreen> createState() => _LeavesListScreenState();
}

class _LeavesListScreenState extends ConsumerState<LeavesListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _tabs = ['الكل', 'معلقة', 'موافق عليها', 'مرفوضة'];

  static const _leaveTypeNames = [
    'سنوية', 'مرضية', 'طارئة', 'أمومة/أبوة', 'غير مدفوعة', 'تعويضية', 'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

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
          'طلبات الإجازة',
          style: AppTypography.headingSmall.copyWith(
            color: textPrimary, fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: NeuColors.info,
          unselectedLabelColor: NeuColors.textHint,
          indicatorColor: NeuColors.info,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _LeaveTabContent(statusFilter: null, isDark: isDark),
            _LeaveTabContent(statusFilter: 0, isDark: isDark),
            _LeaveTabContent(statusFilter: 1, isDark: isDark),
            _LeaveTabContent(statusFilter: 2, isDark: isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateLeaveDialog(context, isDark),
        icon: const Icon(Icons.beach_access_rounded, color: Colors.white),
        label: Text('طلب إجازة',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateLeaveDialog(BuildContext context, bool isDark) {
    int selectedType = 0;
    final empCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final startCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    final endCtrl = TextEditingController(
        text: DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10));
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            title: Text('طلب إجازة جديد',
                style: AppTypography.headingSmall.copyWith(color: textPrimary)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: empCtrl,
                    decoration: const InputDecoration(
                        labelText: 'اسم الموظف', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                        labelText: 'نوع الإجازة', border: OutlineInputBorder()),
                    items: List.generate(_leaveTypeNames.length,
                        (i) => DropdownMenuItem(value: i, child: Text(_leaveTypeNames[i]))),
                    onChanged: (v) => setDialogState(() => selectedType = v ?? 0),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: startCtrl,
                    decoration: const InputDecoration(
                        labelText: 'تاريخ البدء (YYYY-MM-DD)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: endCtrl,
                    decoration: const InputDecoration(
                        labelText: 'تاريخ الانتهاء (YYYY-MM-DD)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'السبب', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (empCtrl.text.isEmpty) return;
                  final start = DateTime.tryParse(startCtrl.text);
                  final end = DateTime.tryParse(endCtrl.text);
                  final days = (start != null && end != null)
                      ? end.difference(start).inDays + 1
                      : 1;
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(hrmRepositoryProvider).createLeaveRequest(
                        employeeId: 1,
                        employeeName: empCtrl.text,
                        leaveType: selectedType,
                        startDate: startCtrl.text,
                        endDate: endCtrl.text,
                        daysCount: days,
                        reason: reasonCtrl.text.isEmpty
                            ? null
                            : reasonCtrl.text,
                      );
                  if (ctx.mounted) ctx.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('تم تقديم طلب الإجازة')),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: NeuColors.info, foregroundColor: Colors.white),
                child: const Text('تقديم'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Inner widget to show leaves per tab ──────────────────────────────

class _LeaveTabContent extends ConsumerWidget {
  const _LeaveTabContent({required this.statusFilter, required this.isDark});
  final int? statusFilter;
  final bool isDark;

  static const _leaveTypeNames = [
    'سنوية', 'مرضية', 'طارئة', 'أمومة/أبوة', 'غير مدفوعة', 'تعويضية', 'أخرى'
  ];
  static const _statusNames = ['معلقة', 'موافق عليها', 'مرفوضة', 'ملغاة'];

  Color _statusColor(int s) {
    switch (s) {
      case 0: return NeuColors.warning;
      case 1: return NeuColors.success;
      case 2: return NeuColors.danger;
      default: return NeuColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final async = ref.watch(pendingLeavesProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final list = statusFilter == null
            ? all
            : all.where((l) => l.status == statusFilter).toList();

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.beach_access_rounded, size: 64, color: NeuColors.textHint),
                const SizedBox(height: 16),
                Text('لا توجد طلبات',
                    style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.screen,
          itemCount: list.length,
          itemBuilder: (_, i) {
            final l = list[i];
            final typeName = l.leaveType < _leaveTypeNames.length
                ? _leaveTypeNames[l.leaveType]
                : 'غير محدد';
            final statusName = l.status < _statusNames.length
                ? _statusNames[l.status]
                : '—';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeuCard(
                isDark: isDark,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _statusColor(l.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.beach_access_rounded,
                          color: _statusColor(l.status), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l.employeeName ?? 'موظف #${l.employeeId}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _statusColor(l.status).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(statusName,
                                    style: AppTypography.labelSmall.copyWith(
                                        color: _statusColor(l.status),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('$typeName  •  ${l.days} يوم',
                              style: AppTypography.bodySmall.copyWith(color: NeuColors.navyDeep)),
                          const SizedBox(height: 2),
                          Text('${l.startDate} ← ${l.endDate}',
                              style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                          if (l.status == 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _updateStatus(ref, context, l, 2),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: NeuColors.danger,
                                        side: BorderSide(color: NeuColors.danger)),
                                    child: const Text('رفض'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(ref, context, l, 1),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: NeuColors.success,
                                        foregroundColor: Colors.white),
                                    child: const Text('موافقة'),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Future<void> _updateStatus(
      WidgetRef ref, BuildContext ctx, LeaveRequest l, int newStatus) async {
    await ref.read(hrmRepositoryProvider).updateLeaveStatus(
          leave: l,
          newStatus: newStatus,
        );
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(newStatus == 1 ? 'تمت الموافقة' : 'تم الرفض'),
        backgroundColor: newStatus == 1 ? NeuColors.success : NeuColors.danger,
      ));
    }
  }
}