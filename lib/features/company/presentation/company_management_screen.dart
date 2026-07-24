import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/code_generator_service.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/company_providers.dart';

/// RVIOS — Company Management Screen
///
/// لوحة إدارة الشركة — متاحة للمسؤولين فقط (Admin+)
/// تعرض:
///   - معلومات الشركة والباقة
///   - قائمة الأعضاء
///   - إدارة الدعوات
///   - إحصائيات سريعة
class CompanyManagementScreen extends ConsumerStatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  ConsumerState<CompanyManagementScreen> createState() =>
      _CompanyManagementScreenState();
}

class _CompanyManagementScreenState
    extends ConsumerState<CompanyManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final company = ref.watch(activeCompanyProvider);
    final role = ref.watch(activeMemberRoleProvider);

    if (company == null) {
      return const Scaffold(
        body: Center(child: Text('لا توجد شركة نشطة')),
      );
    }

    final plan = PlanType.fromValue(company.planType);
    final subsStatus = SubscriptionStatus.fromValue(company.subscriptionStatus);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        title: Text('إدارة الشركة', style: AppTypography.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor:
            isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
        actions: [
          if (role.canManageUsers)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'دعوة موظف',
              onPressed: () => _showInviteSheet(context, company, ref),
            ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: NeuColors.primary,
          unselectedLabelColor:
              isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
          indicatorColor: NeuColors.primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontFamily: 'Panorama',
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'الشركة'),
            Tab(text: 'الأعضاء'),
            Tab(text: 'الدعوات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // â”€â”€ Tab 1: Company Info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _CompanyInfoTab(
              company: company, plan: plan, subsStatus: subsStatus),

          // â”€â”€ Tab 2: Members â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _MembersTab(company: company, currentRole: role),

          // â”€â”€ Tab 3: Invitations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _InvitationsTab(company: company),
        ],
      ),
    );
  }

  void _showInviteSheet(
      BuildContext context, Company company, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteEmployeeSheet(company: company),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Tab 1: Company Info
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CompanyInfoTab extends ConsumerWidget {
  const _CompanyInfoTab({
    required this.company,
    required this.plan,
    required this.subsStatus,
  });

  final Company company;
  final PlanType plan;
  final SubscriptionStatus subsStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // â”€â”€ Company Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [NeuColors.primary, NeuColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.business_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: const TextStyle(
                              fontFamily: 'Panorama',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            company.companyCode,
                            style: TextStyle(
                              fontFamily: 'Panorama',
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _PlanChip(plan: plan),
                    const SizedBox(width: 10),
                    _StatusChip(status: subsStatus),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  'app.rvios.com/${company.workspaceSlug}',
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // â”€â”€ Info Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _InfoTile(
                label: 'الدولة',
                value: company.country ?? '—',
                icon: Icons.location_on_outlined,
              ),
              _InfoTile(
                label: 'العملة',
                value: company.currency ?? '—',
                icon: Icons.currency_exchange_outlined,
              ),
              _InfoTile(
                label: 'القطاع',
                value: company.industry ?? '—',
                icon: Icons.category_outlined,
              ),
              _InfoTile(
                label: 'الحد الأقصى',
                value: plan.isUnlimited ? 'غير محدود' : '${plan.maxUsers} مستخدم',
                icon: Icons.group_outlined,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // â”€â”€ Company Code Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeuColors.goldTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NeuColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.vpn_key_outlined,
                    color: NeuColors.gold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company ID للدعوات',
                        style: TextStyle(
                          fontFamily: 'Panorama',
                          fontSize: 11,
                          color: NeuColors.goldDark,
                        ),
                      ),
                      Text(
                        company.companyCode,
                        style: const TextStyle(
                          fontFamily: 'Panorama',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: NeuColors.goldDark,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      color: NeuColors.gold, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ Company ID'),
                        backgroundColor: NeuColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Tab 2: Members
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MembersTab extends ConsumerWidget {
  const _MembersTab({required this.company, required this.currentRole});
  final Company company;
  final UserRole currentRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(companyMembersStreamProvider);

    return membersAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: NeuColors.primary)),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (members) => members.isEmpty
          ? _EmptyState(
              icon: Icons.people_outline,
              message: 'لا يوجد أعضاء بعد',
              hint: 'ادعظڈ موظفين للانضمام من أيقونة الإضافة',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final m = members[i];
                final role = UserRole.fromValue(m.role);
                return _MemberTile(
                  member: m,
                  role: role,
                  canManage: currentRole.canManageUsers && !role.isOwner,
                );
              },
            ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Tab 3: Invitations
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _InvitationsTab extends ConsumerWidget {
  const _InvitationsTab({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsAsync = ref.watch(pendingInvitationsProvider);

    return invitationsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: NeuColors.primary)),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (invitations) => invitations.isEmpty
          ? _EmptyState(
              icon: Icons.mail_outline_rounded,
              message: 'لا توجد دعوات معلقة',
              hint: 'ادعظڈ موظفاً جديداً بالضغط على أيقونة الإضافة',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: invitations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final inv = invitations[i];
                return _InvitationTile(invitation: inv);
              },
            ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Invite Employee Bottom Sheet
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _InviteEmployeeSheet extends ConsumerStatefulWidget {
  const _InviteEmployeeSheet({required this.company});
  final Company company;

  @override
  ConsumerState<_InviteEmployeeSheet> createState() =>
      _InviteEmployeeSheetState();
}

class _InviteEmployeeSheetState
    extends ConsumerState<_InviteEmployeeSheet> {
  final _nameCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.employee;
  bool _isGenerating = false;

  // Result
  String? _generatedEmployeeCode;
  String? _generatedTempPassword;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isGenerating = true);

    final empCode = CodeGeneratorService.generateEmployeeCode(1);
    final tempPw = CodeGeneratorService.generateTempPassword();

    setState(() {
      _generatedEmployeeCode = empCode;
      _generatedTempPassword = tempPw;
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? NeuColors.borderDark : NeuColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('دعوة موظف جديد', style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            'سيتم توليد كودات الدخول تلقائياً',
            style: AppTypography.body
                .copyWith(color: NeuColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Name field
          Container(
            decoration: BoxDecoration(
              color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? NeuColors.borderDark : NeuColors.border),
            ),
            child: TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم الموظف',
                prefixIcon: Icon(Icons.person_outline,
                    color: NeuColors.primary, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Role picker
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            decoration: InputDecoration(
              labelText: 'الدور',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color:
                        isDark ? NeuColors.borderDark : NeuColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color:
                        isDark ? NeuColors.borderDark : NeuColors.border),
              ),
            ),
            items: [
              UserRole.admin,
              UserRole.hrManager,
              UserRole.financeManager,
              UserRole.deptManager,
              UserRole.teamLeader,
              UserRole.employee,
              UserRole.guest,
            ]
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.arabicLabel),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedRole = v!),
          ),

          const SizedBox(height: 20),

          // Result card (shown after generation)
          if (_generatedEmployeeCode != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NeuColors.primaryTint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NeuColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: NeuColors.success, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'أكواد الدخول جاهزة — أرسلها للموظف',
                        style: TextStyle(
                          fontFamily: 'Panorama',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: NeuColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CodeRow(
                      label: 'Company ID', value: widget.company.companyCode),
                  const SizedBox(height: 6),
                  _CodeRow(
                      label: 'Employee Code', value: _generatedEmployeeCode!),
                  const SizedBox(height: 6),
                  _CodeRow(
                      label: 'كلمة المرور المؤقتة',
                      value: _generatedTempPassword!),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generate,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.generating_tokens_outlined,
                      color: Colors.white),
              label: Text(
                _generatedEmployeeCode == null
                    ? 'توليد كودات الدخول'
                    : 'توليد كودات جديدة',
                style: const TextStyle(
                  fontFamily: 'Panorama',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Helper Widgets
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.plan});
  final PlanType plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: NeuColors.gold, size: 14),
          const SizedBox(width: 4),
          Text(
            plan.arabicLabel,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Panorama',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final SubscriptionStatus status;

  Color get _color {
    switch (status) {
      case SubscriptionStatus.active:
        return NeuColors.success;
      case SubscriptionStatus.trial:
        return NeuColors.info;
      case SubscriptionStatus.suspended:
        return NeuColors.warning;
      case SubscriptionStatus.cancelled:
        return NeuColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.arabicLabel,
        style: TextStyle(
          color: _color,
          fontFamily: 'Panorama',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? NeuColors.borderDark : NeuColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: NeuColors.primary, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Panorama',
              fontSize: 11,
              color: isDark
                  ? NeuColors.textSecondaryDark
                  : NeuColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Panorama',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? NeuColors.textPrimaryDark
                  : NeuColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.role,
    required this.canManage,
  });
  final CompanyMember member;
  final UserRole role;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? NeuColors.borderDark : NeuColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: NeuColors.primaryTint,
            child: Text(
              role.arabicLabel.substring(0, 1),
              style: const TextStyle(
                color: NeuColors.primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Panorama',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.userSyncId.substring(0, 8), // temp — will show name
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark
                        ? NeuColors.textPrimaryDark
                        : NeuColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role.arabicLabel,
                  style: const TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 12,
                    color: NeuColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: member.isActive ? NeuColors.success : NeuColors.textHint,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationTile extends StatelessWidget {
  const _InvitationTile({required this.invitation});
  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = InvitationStatus.fromValue(invitation.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? NeuColors.borderDark : NeuColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NeuColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mail_outline,
                color: NeuColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.employeeCode ??
                      invitation.email ??
                      'دعوة بدون اسم',
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark
                        ? NeuColors.textPrimaryDark
                        : NeuColors.textPrimary,
                  ),
                ),
                Text(
                  'تنتهي: ${invitation.expiresAt.day}/${invitation.expiresAt.month}/${invitation.expiresAt.year}',
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 11,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: NeuColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.arabicLabel,
              style: const TextStyle(
                color: NeuColors.warning,
                fontSize: 11,
                fontFamily: 'Panorama',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeRow extends StatelessWidget {
  const _CodeRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'Panorama',
            fontSize: 12,
            color: NeuColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Panorama',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NeuColors.primaryDark,
              letterSpacing: 1,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('تم النسخ'))),
          child: const Icon(Icons.copy_outlined,
              size: 14, color: NeuColors.primary),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.hint,
  });
  final IconData icon;
  final String message;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: NeuColors.textHint),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Panorama',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NeuColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Panorama',
              fontSize: 12,
              color: NeuColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}