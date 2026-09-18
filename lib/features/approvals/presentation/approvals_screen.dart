import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/neu_colors.dart';

/// RVIOS — Approvals Screen (Phase 8)
///
/// Manages approval requests within the company:
/// - طلبات إجازة (Leave Requests)
/// - طلبات سلفة (Advance Requests)
/// - طلبات شراء (Purchase Requests)
/// - موافقات مالية (Financial Approvals)
class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.surfaceDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color:
                  isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'نظام الموافقات',
          style: TextStyle(
            fontFamily: 'Panorama',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('btn_add_approval'),
            icon: const Icon(Icons.add_rounded, color: NeuColors.primary),
            onPressed: () => _showNewRequestSheet(context),
            tooltip: 'طلب جديد',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: NeuColors.primary,
          unselectedLabelColor:
              isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
          indicatorColor: NeuColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Panorama',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'إجازات'),
            Tab(text: 'سلف'),
            Tab(text: 'مشتريات'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabController,
          children: [
            _ApprovalsList(type: null, isDark: isDark),
            _ApprovalsList(type: ApprovalType.leave, isDark: isDark),
            _ApprovalsList(type: ApprovalType.advance, isDark: isDark),
            _ApprovalsList(type: ApprovalType.purchase, isDark: isDark),
          ],
        ),
      ),
    );
  }

  void _showNewRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewRequestSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// Approvals List
// ─────────────────────────────────────────────

class _ApprovalsList extends StatelessWidget {
  const _ApprovalsList({required this.type, required this.isDark});
  final ApprovalType? type;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Sample data — will be replaced with real DB queries
    final items = _sampleItems
        .where((i) => type == null || i.type == type)
        .toList();

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.approval_outlined,
                size: 64,
                color: isDark ? NeuColors.borderDark : NeuColors.border),
            const SizedBox(height: 12),
            Text(
              'لا توجد طلبات',
              style: TextStyle(
                fontFamily: 'Panorama',
                fontSize: 16,
                color: isDark
                    ? NeuColors.textSecondaryDark
                    : NeuColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _ApprovalCard(item: items[index], isDark: isDark);
      },
    );
  }

  static final _sampleItems = [
    _ApprovalItem(
      id: '1',
      type: ApprovalType.leave,
      requesterName: 'أحمد محمد',
      title: 'طلب إجازة سنوية',
      details: '5 أيام — من 25 يوليو إلى 29 يوليو 2026',
      status: ApprovalStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    _ApprovalItem(
      id: '2',
      type: ApprovalType.advance,
      requesterName: 'سارة العمري',
      title: 'طلب سلفة',
      details: 'مبلغ 2,500 ريال — للاستقطاع على 3 دفعات',
      status: ApprovalStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _ApprovalItem(
      id: '3',
      type: ApprovalType.purchase,
      requesterName: 'خالد الشهري',
      title: 'طلب شراء معدات',
      details: 'شاشة Dell 27 بوصة — 1,800 ريال',
      status: ApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    _ApprovalItem(
      id: '4',
      type: ApprovalType.leave,
      requesterName: 'نورة القحطاني',
      title: 'طلب إجازة مرضية',
      details: '3 أيام — بسبب وعكة صحية',
      status: ApprovalStatus.rejected,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}

// ─────────────────────────────────────────────
// Approval Card
// ─────────────────────────────────────────────

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.item, required this.isDark});
  final _ApprovalItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? NeuColors.borderDark : NeuColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.type.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.type.icon,
                      color: item.type.color, size: 22),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'Panorama',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? NeuColors.textPrimaryDark
                              : NeuColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.requesterName,
                        style: TextStyle(
                          fontFamily: 'Panorama',
                          fontSize: 12,
                          color: NeuColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.details,
                        style: TextStyle(
                          fontFamily: 'Panorama',
                          fontSize: 12,
                          color: isDark
                              ? NeuColors.textSecondaryDark
                              : NeuColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _StatusBadge(status: item.status),
              ],
            ),
          ),

          // Action row (only for pending)
          if (item.status == ApprovalStatus.pending) ...[
            Divider(
              height: 1,
              color: isDark ? NeuColors.borderDark : NeuColors.border,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: Key('btn_reject_${item.id}'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم رفض الطلب',
                                textDirection: TextDirection.rtl),
                            backgroundColor: NeuColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('رفض',
                          style: TextStyle(
                              fontFamily: 'Panorama', fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NeuColors.primary,
                        side: const BorderSide(color: NeuColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      key: Key('btn_approve_${item.id}'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تمت الموافقة على الطلب',
                                textDirection: TextDirection.rtl),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('موافقة',
                          style: TextStyle(
                              fontFamily: 'Panorama', fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.arabicLabel,
        style: TextStyle(
          fontFamily: 'Panorama',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// New Request Sheet
// ─────────────────────────────────────────────

class _NewRequestSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? NeuColors.borderDark : NeuColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'طلب جديد',
            style: TextStyle(
              fontFamily: 'Panorama',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...ApprovalType.values.map((type) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(type.icon, color: type.color, size: 20),
                ),
                title: Text(
                  type.arabicLabel,
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeuColors.textPrimaryDark
                        : NeuColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('إنشاء ${type.arabicLabel}...',
                          textDirection: TextDirection.rtl),
                    ),
                  );
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Data Models & Enums
// ─────────────────────────────────────────────

enum ApprovalType {
  leave('طلب إجازة', Icons.beach_access_rounded, Color(0xFF1565C0)),
  advance('سلفة مالية', Icons.monetization_on_rounded, Color(0xFF2E7D32)),
  purchase('طلب شراء', Icons.shopping_cart_rounded, Color(0xFFE65100));

  const ApprovalType(this.arabicLabel, this.icon, this.color);
  final String arabicLabel;
  final IconData icon;
  final Color color;
}

enum ApprovalStatus {
  pending('قيد المراجعة', Color(0xFFF57C00)),
  approved('موافق عليه', Color(0xFF2E7D32)),
  rejected('مرفوض', Color(0xFF9E2226));

  const ApprovalStatus(this.arabicLabel, this.color);
  final String arabicLabel;
  final Color color;
}

class _ApprovalItem {
  const _ApprovalItem({
    required this.id,
    required this.type,
    required this.requesterName,
    required this.title,
    required this.details,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final ApprovalType type;
  final String requesterName;
  final String title;
  final String details;
  final ApprovalStatus status;
  final DateTime createdAt;
}