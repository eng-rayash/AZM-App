import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design/azm_tokens.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/help_tips.dart';
import '../../store_app/store_routes.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/services/remote_config_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/azm_list.dart';
import '../../../shared/widgets/azm_screen.dart';
import '../../backup/domain/backup_service.dart';

/// AZM — الإعدادات
///
/// كانت ستة أقسام بلا منطق يجمعها: «الحساب والتحقق» يجاور «حذف جميع
/// البيانات» يجاور «سياسة الخصوصية». والمستخدم الباحث عن إعداد لا يعرف
/// أين يبدأ، فيمسح الشاشة كلها في كل مرة.
///
/// الأقسام السبعة هنا مرتّبة من **الأقرب إليك** إلى **الأبعد عنك**:
/// أنت، ثم مكان عملك، ثم ما يحرسه، ثم ما يقاطعك، ثم ما تراه، ثم ما
/// تملكه، ثم البرنامج نفسه. ومن بحث عن إعداد يعرف من اسم القسم وحده
/// إن كان فيه أو لا.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
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
    _pinEnabled = pinEnabledVal == 'true';

    if (mounted) setState(() {});
  }

  Future<void> _toggleBiometric(bool value) async {
    final authService = AuthService.instance;
    if (value) {
      // البصمة تُفعَّل بالبصمة: تفعيلٌ بلا إثبات يقفل الحساب على من
      // لا يملك الإصبع المسجَّل.
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
    await SecureStorageService.instance.write(
      'notifications_enabled',
      value.toString(),
    );
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _toggleOverdueAlerts(bool value) async {
    await SecureStorageService.instance.write(
      'overdue_alerts_enabled',
      value.toString(),
    );
    setState(() => _overdueAlertsEnabled = value);
  }

  Future<void> _togglePinEnabled(bool value) async {
    await SecureStorageService.instance.write('pin_enabled', value.toString());
    setState(() => _pinEnabled = value);
    _say(value ? 'تم تفعيل رمز الدخول' : 'تم إيقاف رمز الدخول');
  }

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final themeMode = ref.watch(themeProvider);

    return AzmScreen(
      title: 'الإعدادات',
      caption: 'ما يضبط التطبيق وحسابك',
      leading: AzmIconAction(
        // `arrow_back` تُعكس تلقائيًا مع اتجاه النص فتشير يمينًا في
        // RTL — وهو اتجاه «رجوع» هنا. و`arrow_forward` تشير يسارًا،
        // أي إلى الأمام، عكس ما يفعله الزرّ.
        icon: Icons.arrow_back_rounded,
        tooltip: 'رجوع',
        onTap: () => context.canPop()
            ? context.pop()
            : context.go(StoreRoutes.home),
      ),
      slivers: [
        // ── ١ · الحساب ───────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الحساب',
            caption: 'من أنت في هذا التطبيق',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الملف الشخصي',
                subtitle: 'الاسم والبريد وحالة التحقق',
                icon: Icons.person_outline_rounded,
                onTap: () => context.push(RouteNames.account),
              ),
            ],
          ),
        ),

        // ── ٢ · متجري ────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'متجري',
            caption: 'الباقة والفريق والدفع',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(
            rows: [
              AzmNavRow(
                title: 'الباقة والاشتراك',
                subtitle: 'باقتك الحالية والترقية والفواتير',
                icon: Icons.workspace_premium_outlined,
                onTap: () => context.push(StoreRoutes.billing),
              ),
              AzmNavRow(
                title: 'فريق المتجر',
                subtitle: 'من يدير المتجر معك',
                icon: Icons.groups_outlined,
                onTap: () => context.push(StoreRoutes.team),
              ),
              AzmNavRow(
                title: 'طرق الدفع',
                subtitle: 'حسابات دفع اشتراكات RVIOS',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => context.push(StoreRoutes.pay),
              ),
              AzmNavRow(
                title: 'إعادة الإرشادات',
                subtitle: 'أظهر نوافذ التعليمات في كل شاشة من جديد',
                icon: Icons.tips_and_updates_outlined,
                onTap: () async {
                  await HelpTips.resetAll();
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ستظهر الإرشادات من جديد')));
                },
              ),
            ],
          ),
        ),

        // ── ٣ · الأمان ───────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'الأمان',
            caption: 'ما يمنع غيرك من فتح التطبيق',
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              AzmSwitchRow(
                title: 'رمز الدخول',
                subtitle: 'يُطلب عند كل فتح للتطبيق',
                icon: Icons.pin_outlined,
                value: _pinEnabled,
                onChanged: _togglePinEnabled,
              ),
              AzmNavRow(
                title: 'تغيير رمز الدخول',
                subtitle: 'تحديث الرمز الحالي',
                icon: Icons.password_outlined,
                enabled: _pinEnabled,
                onTap: () => context.push(RouteNames.changePin),
              ),
              AzmSwitchRow(
                title: 'البصمة',
                subtitle: _biometricAvailable
                    ? 'الدخول بالبصمة بدل كتابة الرمز'
                    : 'غير متاحة على هذا الجهاز',
                icon: Icons.fingerprint_rounded,
                value: _biometricEnabled,
                enabled: _biometricAvailable,
                onChanged: _toggleBiometric,
              ),
            ],
          ),
        ),

        // ── ٤ · التنبيهات ────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'التنبيهات',
            caption: 'متى يقاطعك التطبيق',
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              AzmSwitchRow(
                title: 'الإشعارات',
                subtitle: 'تنبيهات الطلبات والروتين اليومي',
                icon: Icons.notifications_none_rounded,
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
              AzmSwitchRow(
                title: 'تنبيه المتأخّر',
                subtitle: 'إشعار حين يتجاوز التزامٌ موعده',
                icon: Icons.running_with_errors_outlined,
                value: _overdueAlertsEnabled,
                // التنبيه فرعٌ من الإشعارات: إطفاء الأصل يطفئ الفرع،
                // فلا يبقى مفتاحٌ مفعّل لا أثر له.
                enabled: _notificationsEnabled,
                showDivider: false,
                onChanged: _toggleOverdueAlerts,
              ),
            ],
          ),
        ),

        // ── ٥ · المظهر ───────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(title: 'المظهر', caption: 'كيف يبدو التطبيق'),
        ),
        SliverToBoxAdapter(
          child: AzmSegmented<ThemeMode>(
            label: 'السمة',
            value: themeMode,
            options: const [
              (ThemeMode.light, 'فاتح'),
              (ThemeMode.dark, 'داكن'),
              (ThemeMode.system, 'تلقائي'),
            ],
            showDivider: false,
            onChanged: (mode) =>
                ref.read(themeProvider.notifier).setTheme(mode),
          ),
        ),

        // ── ٦ · البيانات ─────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'البيانات',
            caption: 'ما تملكه، ونسخه وإخراجه ومحوه',
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              AzmNavRow(
                title: 'نسخة احتياطية',
                subtitle: 'احفظ كل بياناتك في ملف واحد',
                icon: Icons.backup_outlined,
                onTap: _exportBackup,
              ),
              AzmNavRow(
                title: 'استعادة نسخة',
                subtitle: 'استرجع البيانات من ملف نسخة',
                icon: Icons.restore_outlined,
                onTap: _restoreBackup,
              ),
              AzmNavRow(
                title: 'حذف جميع البيانات',
                subtitle: 'لا يمكن التراجع — يُطلب تأكيدان',
                icon: Icons.delete_forever_outlined,
                badge: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: p.danger,
                ),
                showDivider: false,
                onTap: _confirmDeleteAll,
              ),
            ],
          ),
        ),

        // ── ٧ · عن التطبيق ───────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'عن التطبيق',
            caption: 'الإصدار والحقوق والدعم',
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              AzmNavRow(
                title: 'التحقق من التحديثات',
                subtitle: 'الإصدار الحالي ${AppConstants.appVersion}',
                icon: Icons.system_update_outlined,
                onTap: _checkUpdates,
              ),
              AzmNavRow(
                title: 'سياسة الخصوصية',
                subtitle: 'كيف تُحفظ بياناتك ومن يصل إليها',
                icon: Icons.privacy_tip_outlined,
                onTap: () => context.push(RouteNames.privacyPolicy),
              ),
              AzmNavRow(
                title: 'شروط الاستخدام',
                subtitle: 'الترخيص والملكية الفكرية',
                icon: Icons.gavel_outlined,
                showDivider: false,
                onTap: () => context.push(RouteNames.legalProtection),
              ),
            ],
          ),
        ),

        // ختام هادئ — العلامة وإصدارها، بلا إطار ولا بطاقة.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: AzmSpace.xxl),
            child: Center(
              child: Text(
                'عزم · ${AppConstants.appVersion}',
                style: AppTypography.caption.copyWith(color: p.inkGhost),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // البيانات
  // ─────────────────────────────────────────────────────────

  Future<void> _exportBackup() async {
    try {
      await ref.read(backupServiceProvider).exportBackup();
      _say('تم إنشاء النسخة الاحتياطية');
    } catch (e) {
      _say('تعذّر إنشاء النسخة: $e');
    }
  }

  Future<void> _restoreBackup() async {
    try {
      await ref.read(backupServiceProvider).restoreBackup();
      _say('تمت الاستعادة — أعد تشغيل التطبيق');
    } catch (e) {
      _say('تعذّرت الاستعادة: $e');
    }
  }

  /// حذف كل البيانات — تأكيدان لا واحد.
  ///
  /// الأول يسأل عن النيّة، والثاني يسأل بعد أن تُقرأ العاقبة. فعلٌ لا
  /// رجعة فيه لا يصحّ أن يبعد عن الإصبع ضغطةً واحدة.
  void _confirmDeleteAll() {
    _ask(
      title: 'حذف جميع البيانات',
      body: 'سيُحذف كل ما سجّلته في هذا الجهاز. لا يمكن التراجع.',
      confirmLabel: 'متابعة',
      onConfirm: () => _ask(
        title: 'تأكيد نهائي',
        body: 'هذه آخر فرصة للتراجع. هل تريد الحذف؟',
        confirmLabel: 'احذف نهائيًا',
        onConfirm: _wipe,
      ),
    );
  }

  Future<void> _wipe() async {
    await ref.read(backupServiceProvider).wipeAllData();
    await SecureStorageService.instance.deleteAll();
    _say('حُذفت البيانات — أعد تشغيل التطبيق');
  }

  void _ask({
    required String title,
    required String body,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    final p = AzmPalette.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: AzmRadius.control),
        title: Text(title, style: AppTypography.h4.copyWith(color: p.ink)),
        content: Text(
          body,
          style: AppTypography.body.copyWith(color: p.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: TextStyle(color: p.inkMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(confirmLabel, style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // التحديثات
  // ─────────────────────────────────────────────────────────

  /// يسأل الخادم فعلًا عن الإصدار.
  ///
  /// الصيغة السابقة كانت تُظهر مؤشّر تحميل ١٫٥ ثانية بـ`Future.delayed`
  /// ثم تُعلن النتيجة بلا أن تسأل أحدًا — واجهةٌ تمثّل العمل ولا تعمله.
  Future<void> _checkUpdates() async {
    _say('جارٍ التحقق…');
    await RemoteConfigService.instance.fetchConfigs();
    if (!mounted) return;

    final latest = RemoteConfigService.instance.latestVersion;
    final outdated = RemoteConfigService.instance.isVersionOlder(
      AppConstants.appVersion,
      latest,
    );
    _say(outdated ? 'يتوفّر إصدار أحدث: $latest' : 'تطبيقك محدَّث');
  }
}
