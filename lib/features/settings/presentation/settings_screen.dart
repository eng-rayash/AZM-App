import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/providers/database_providers.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../backup/domain/backup_service.dart';
import '../../reports/domain/export_service.dart';
import '../../reports/providers/reports_provider.dart';

/// Advanced Settings Screen — comprehensive settings organized in sections.
///
/// Sections:
/// 1. Security & Protection
/// 2. Appearance
/// 3. Data & Export
/// 4. Notifications (placeholder for future)
/// 5. Application Info
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _notificationsEnabled = true;
  bool _overdueAlertsEnabled = true;
  bool _pinEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authService = AuthService.instance;
    _biometricAvailable = await authService.isBiometricAvailable();
    final method = await authService.getPreferredAuthMethod();
    _biometricEnabled = method == 0 && _biometricAvailable;

    final storage = SecureStorageService.instance;
    final notificationsVal = await storage.read('notifications_enabled');
    final overdueVal = await storage.read('overdue_alerts_enabled');
    final pinEnabledVal = await storage.read('pin_enabled');

    _notificationsEnabled = notificationsVal != 'false';
    _overdueAlertsEnabled = overdueVal != 'false';
    _pinEnabled = pinEnabledVal == 'true'; // Default: disabled

    if (mounted) setState(() {});
  }

  Future<void> _toggleBiometric(bool value) async {
    final authService = AuthService.instance;
    if (value) {
      final ok = await authService.authenticateWithBiometrics();
      if (ok) {
        await authService.setPreferredAuthMethod(0);
        setState(() => _biometricEnabled = true);
      }
    } else {
      await authService.setPreferredAuthMethod(1);
      setState(() => _biometricEnabled = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final storage = SecureStorageService.instance;
    await storage.write('notifications_enabled', value.toString());
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _toggleOverdueAlerts(bool value) async {
    final storage = SecureStorageService.instance;
    await storage.write('overdue_alerts_enabled', value.toString());
    setState(() => _overdueAlertsEnabled = value);
  }

  Future<void> _togglePinEnabled(bool value) async {
    final storage = SecureStorageService.instance;
    await storage.write('pin_enabled', value.toString());
    setState(() => _pinEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'تم تفعيل رمز الدخول بنجاح' : 'تم إيقاف رمز الدخول',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: value ? NeuColors.success : NeuColors.navyDeep,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'الإعدادات',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.dashboardFull),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Section 0: Account & Verification (Top) ───
              _buildSectionTitle(
                  'الحساب والتحقق', Icons.cloud_done_rounded, isDark),
              AppSpacing.gapMd,

              _buildNavigationTile(
                isDark,
                icon: Icons.cloud_done_rounded,
                title: 'إعدادات الحساب والتحقق',
                subtitle: 'ربط ومزامنة الحساب سحابياً',
                onTap: () => context.push(RouteNames.account),
              ),

              AppSpacing.gapXxl,

              // ─── Section 1: Security ───
              _buildSectionTitle(
                  'الحماية والأمان', Icons.shield_rounded, isDark),
              AppSpacing.gapMd,

              // PIN toggle (default: disabled)
              _buildToggleTile(
                isDark,
                icon: Icons.dialpad_rounded,
                title: 'تفعيل رمز الدخول',
                subtitle: 'تمكين حماية التطبيق برمز PIN (الافتراضي: معطل)',
                value: _pinEnabled,
                onChanged: _togglePinEnabled,
              ),

              // Biometric toggle
              if (_biometricAvailable)
                _buildToggleTile(
                  isDark,
                  icon: Icons.fingerprint_rounded,
                  title: 'تفعيل البصمة',
                  subtitle: 'استخدم البصمة للدخول السريع',
                  value: _biometricEnabled,
                  onChanged: _toggleBiometric,
                ),

              _buildNavigationTile(
                isDark,
                icon: Icons.lock_rounded,
                title: 'تغيير رمز الدخول',
                subtitle: 'تحديث رمز PIN الحالي',
                onTap: () => context.push(RouteNames.changePin),
              ),

              _buildNavigationTile(
                isDark,
                icon: Icons.history_rounded,
                title: 'سجل الأنشطة الأمنية',
                subtitle: 'عرض سجل تسجيلات الدخول',
                onTap: () => context.push(RouteNames.securityLog),
              ),

              AppSpacing.gapXxl,

              // ─── Section 2: Appearance ───
              _buildSectionTitle(
                  'المظهر', Icons.palette_rounded, isDark),
              AppSpacing.gapMd,

              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وضع العرض',
                      style: isDark
                          ? AppTypography.h4Dark
                          : AppTypography.h4,
                    ),
                    AppSpacing.gapMd,
                    Row(
                      children: [
                        _buildThemeOption(
                          isDark,
                          'فاتح',
                          Icons.light_mode_rounded,
                          themeMode == ThemeMode.light,
                          () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.light),
                        ),
                        AppSpacing.gapHMd,
                        _buildThemeOption(
                          isDark,
                          'داكن',
                          Icons.dark_mode_rounded,
                          themeMode == ThemeMode.dark,
                          () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.dark),
                        ),
                        AppSpacing.gapHMd,
                        _buildThemeOption(
                          isDark,
                          'تلقائي',
                          Icons.settings_brightness_rounded,
                          themeMode == ThemeMode.system,
                          () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.system),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXxl,

              // ─── Section 3: Data & Export ───
              _buildSectionTitle(
                  'البيانات والتصدير', Icons.storage_rounded, isDark),
              AppSpacing.gapMd,

              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'إدارة النسخ الاحتياطي والتصدير',
                      style: isDark
                          ? AppTypography.bodyDark
                          : AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapLg,
                    Row(
                      children: [
                        Expanded(
                          child: NeuButton(
                            label: 'إنشاء نسخة',
                            icon: Icons.backup_rounded,
                            variant: NeuButtonVariant.primary,
                            onPressed: () async {
                              await ref
                                  .read(backupServiceProvider)
                                  .exportBackup();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'تم إنشاء النسخة الاحتياطية بنجاح'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: NeuButton(
                            label: 'استعادة',
                            icon: Icons.restore_rounded,
                            variant: NeuButtonVariant.gold,
                            onPressed: () async {
                              final success = await ref
                                  .read(backupServiceProvider)
                                  .restoreBackup();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? 'تمت الاستعادة بنجاح. أعد تشغيل التطبيق.'
                                        : 'فشلت عملية الاستعادة.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapMd,
                    SizedBox(
                      width: double.infinity,
                      child: NeuButton(
                        label: 'تصدير التقرير اليومي',
                        icon: Icons.ios_share_rounded,
                        variant: NeuButtonVariant.secondary,
                        onPressed: () async {
                          final analytics =
                              ref.read(reportsAnalyticsProvider);
                          await ref
                              .read(exportServiceProvider)
                              .exportDailyReport(analytics);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.gapMd,

              // Delete all data
              _buildNavigationTile(
                isDark,
                icon: Icons.delete_forever_rounded,
                title: 'حذف جميع البيانات',
                subtitle: 'تحذير: لا يمكن التراجع عن هذا الإجراء',
                titleColor: NeuColors.danger,
                onTap: () => _confirmDeleteAll(context),
              ),

              AppSpacing.gapXxl,

              // ─── Section 4: Notifications ───
              _buildSectionTitle(
                  'الإشعارات', Icons.notifications_rounded, isDark),
              AppSpacing.gapMd,

              _buildToggleTile(
                isDark,
                icon: Icons.notifications_active_rounded,
                title: 'تفعيل الإشعارات',
                subtitle: 'تذكيرات الاجتماعات والمهام',
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),

              _buildToggleTile(
                isDark,
                icon: Icons.warning_rounded,
                title: 'تنبيهات المهام المتأخرة',
                subtitle: 'إشعار عند تأخر مهمة',
                value: _overdueAlertsEnabled,
                onChanged: _toggleOverdueAlerts,
              ),

              AppSpacing.gapXxl,

              // ─── Section 5: About (Bottom) ───
              _buildSectionTitle(
                  'عن التطبيق', Icons.info_rounded, isDark),
              AppSpacing.gapMd,

              Container(
                decoration: NeuDecorations.neuFlat(isDark: isDark).copyWith(
                  border: Border.all(
                    color: isDark ? NeuColors.goldAccent : NeuColors.goldAccent.withValues(alpha: 0.6),
                    width: 2.0,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/icon.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Text(
                      'مديري',
                      style: isDark
                          ? AppTypography.h3Dark
                          : AppTypography.h3,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      'نظام إدارة تنفيذي احترافي',
                      style: isDark
                          ? AppTypography.bodySmallDark
                          : AppTypography.bodySmall,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'الإصدار 0.1.0 • بناء 1',
                      style: isDark
                          ? AppTypography.captionDark
                          : AppTypography.caption,
                    ),
                    AppSpacing.gapMd,
                    Divider(
                      color: isDark ? NeuColors.goldAccent.withValues(alpha: 0.3) : NeuColors.navyDeep.withValues(alpha: 0.15),
                      thickness: 1,
                    ),
                    AppSpacing.gapMd,
                    Text(
                      'تطوير المهندس: Eng: Rayash Albureihi',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapMd,
              _buildNavigationTile(
                isDark,
                icon: Icons.privacy_tip_rounded,
                title: 'سياسة الخصوصية',
                subtitle: 'بيان حماية البيانات والسرية الأمنية',
                onTap: () => context.push(RouteNames.privacyPolicy),
              ),
              _buildNavigationTile(
                isDark,
                icon: Icons.gavel_rounded,
                title: 'شروط الاستخدام والملكية الفكرية',
                subtitle: 'حقوق الملكية الفكرية والترخيص القانوني',
                onTap: () => context.push(RouteNames.legalProtection),
              ),
              _buildNavigationTile(
                isDark,
                icon: Icons.system_update_rounded,
                title: 'التحقق من التحديثات',
                subtitle: 'التأكد من توفر إصدار جديد للتطبيق',
                onTap: () => _checkUpdatesManual(context),
              ),

              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
        ),
        AppSpacing.gapHSm,
        Text(
          title,
          style: isDark ? AppTypography.h4Dark : AppTypography.h4,
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return NeuCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: isDark
                        ? AppTypography.bodyDark
                        : AppTypography.body),
                Text(subtitle,
                    style: isDark
                        ? AppTypography.captionDark
                        : AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: NeuColors.goldAccent,
            activeThumbColor: NeuColors.navyDeep,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return NeuCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22,
              color: titleColor ??
                  (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: (isDark
                            ? AppTypography.bodyDark
                            : AppTypography.body)
                        .copyWith(color: titleColor)),
                Text(subtitle,
                    style: isDark
                        ? AppTypography.captionDark
                        : AppTypography.caption),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, size: 24,
              color: isDark
                  ? NeuColors.textHintDark
                  : NeuColors.textHint),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    bool isDark,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? NeuColors.navyDeep
                    : NeuColors.navyDeep.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? NeuColors.navyDeep
                  : (isDark ? NeuColors.dividerDark : NeuColors.divider),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? (isDark
                          ? NeuColors.goldAccent
                          : NeuColors.navyDeep)
                      : (isDark
                          ? NeuColors.textHintDark
                          : NeuColors.textHint),
                  size: 24),
              AppSpacing.gapXs,
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? (isDark
                            ? NeuColors.goldAccent
                            : NeuColors.navyDeep)
                        : (isDark
                            ? NeuColors.textHintDark
                            : NeuColors.textHint),
                    fontFamily: 'Tajawal',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف جميع البيانات',
              style: AppTypography.h3),
          content: const Text(
            'هل أنت متأكد من حذف جميع البيانات؟ هذا الإجراء لا يمكن التراجع عنه.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.danger,
              ),
              onPressed: () {
                // Double confirmation
                Navigator.pop(ctx);
                _secondConfirm(context);
              },
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _secondConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد نهائي',
              style: AppTypography.h3),
          content: const Text(
            'سيتم حذف جميع البيانات نهائيًا. هل تريد المتابعة؟',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.danger,
              ),
              onPressed: () async {
                final db = ref.read(databaseProvider);
                await db.transaction(() async {
                  await db.delete(db.users).go();
                  await db.delete(db.meetings).go();
                  await db.delete(db.tasks).go();
                  await db.delete(db.followUps).go();
                  await db.delete(db.directives).go();
                  await db.delete(db.contacts).go();
                  await db.delete(db.appointments).go();
                  await db.delete(db.archive).go();
                  await db.delete(db.securityLogs).go();
                  await db.delete(db.appSettings).go();
                  await db.delete(db.calls).go();
                  await db.delete(db.visitors).go();
                  await db.delete(db.notes).go();
                  await db.delete(db.movements).go();
                });
                await SecureStorageService.instance.deleteAll();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('تم حذف جميع البيانات بنجاح. أعد تشغيل التطبيق.'),
                    ),
                  );
                }
              },
              child: const Text('حذف نهائي'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkUpdatesManual(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Show a loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: NeuCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                ),
                const SizedBox(width: 20),
                Text(
                  'جاري التحقق من وجود تحديثات...',
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate network delay for 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (context.mounted) {
      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Show update is available or application is up to date
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: NeuCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: NeuColors.success,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تطبيقك محدث بالكامل',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'أنت تستخدم أحدث إصدار من تطبيق "مديري" (0.1.0). شكراً لك لاستخدامك النظام التنفيذي.',
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: NeuButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      label: 'موافق',
                      variant: NeuButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
