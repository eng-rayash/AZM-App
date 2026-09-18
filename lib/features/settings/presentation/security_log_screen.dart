import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/search_filter_bar.dart';

/// Security Log Screen — displays all security log audit trails in a premium neomorphic view.
class SecurityLogScreen extends ConsumerStatefulWidget {
  const SecurityLogScreen({super.key});

  @override
  ConsumerState<SecurityLogScreen> createState() => _SecurityLogScreenState();
}

class _SecurityLogScreenState extends ConsumerState<SecurityLogScreen> {
  String _searchQuery = '';
  String _actionFilter = 'all';

  static final List<FilterOption> _filters = [
    const FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: SecurityAction.login.arabicLabel, value: '0'),
    FilterOption(label: SecurityAction.failedLogin.arabicLabel, value: '1'),
    FilterOption(label: SecurityAction.pinChanged.arabicLabel, value: '4'),
    FilterOption(label: SecurityAction.exportData.arabicLabel, value: '7'),
    FilterOption(label: SecurityAction.deleteRecord.arabicLabel, value: '8'),
    FilterOption(label: SecurityAction.backupRestored.arabicLabel, value: '10'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logsStream = ref.watch(securityLogsDaoProvider).watchAll(limit: 200);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'سجل الأنشطة الأمنية',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Search & Filters Bar
              SearchFilterBar(
                searchHint: 'بحث في سجلات الأمان...',
                onSearchChanged: (q) => setState(() => _searchQuery = q),
                filters: _filters,
                selectedFilter: _actionFilter,
                onFilterChanged: (v) => setState(() => _actionFilter = v),
              ),
              AppSpacing.gapMd,

              // Logs List View
              Expanded(
                child: StreamBuilder<List<SecurityLog>>(
                  stream: logsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: NeuColors.navyMid));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('خطأ: ${snapshot.error}', style: isDark ? AppTypography.bodyDark : AppTypography.body));
                    }

                    final logs = snapshot.data ?? [];
                    var filteredLogs = logs.where((log) {
                      // Action filter
                      if (_actionFilter != 'all') {
                        final actionVal = int.tryParse(_actionFilter);
                        if (actionVal != null && log.action != actionVal) {
                          return false;
                        }
                      }
                      
                      // Search query filter
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        final matchesAction = SecurityAction.fromValue(log.action).arabicLabel.toLowerCase().contains(q);
                        final matchesDetails = (log.details ?? '').toLowerCase().contains(q);
                        final matchesDevice = (log.deviceInfo ?? '').toLowerCase().contains(q);
                        final matchesIp = (log.ipAddress ?? '').toLowerCase().contains(q);
                        if (!matchesAction && !matchesDetails && !matchesDevice && !matchesIp) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();

                    if (filteredLogs.isEmpty) {
                      return EmptyState(
                        icon: Icons.gavel_rounded,
                        title: _searchQuery.isNotEmpty || _actionFilter != 'all'
                            ? 'لا توجد سجلات مطابقة للبحث'
                            : 'سجل الأنشطة الأمنية فارغ',
                        subtitle: _searchQuery.isEmpty && _actionFilter == 'all'
                            ? 'سيتم تسجيل الإجراءات الحساسة (مثل الدخول والتصدير والنسخ الاحتياطي) هنا تلقائياً لضمان التدقيق الأمني.'
                            : null,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final action = SecurityAction.fromValue(log.action);
                        final date = DateTime.fromMillisecondsSinceEpoch(log.createdAt);
                        final dateStr = DateFormat('yyyy-MM-dd | hh:mm a', 'ar').format(date);

                        IconData getActionIcon(SecurityAction action) {
                          switch (action) {
                            case SecurityAction.login:
                              return Icons.login_rounded;
                            case SecurityAction.failedLogin:
                              return Icons.gpp_bad_rounded;
                            case SecurityAction.logout:
                              return Icons.logout_rounded;
                            case SecurityAction.pinSetup:
                            case SecurityAction.pinChanged:
                              return Icons.password_rounded;
                            case SecurityAction.biometricEnabled:
                            case SecurityAction.biometricDisabled:
                              return Icons.fingerprint_rounded;
                            case SecurityAction.exportData:
                              return Icons.ios_share_rounded;
                            case SecurityAction.deleteRecord:
                              return Icons.delete_sweep_rounded;
                            case SecurityAction.backupCreated:
                              return Icons.backup_rounded;
                            case SecurityAction.backupRestored:
                              return Icons.settings_backup_restore_rounded;
                            case SecurityAction.appLocked:
                              return Icons.lock_rounded;
                            case SecurityAction.appUnlocked:
                              return Icons.lock_open_rounded;
                            default:
                              return Icons.info_outline_rounded;
                          }
                        }

                        Color getActionColor(SecurityAction action) {
                          switch (action) {
                            case SecurityAction.failedLogin:
                            case SecurityAction.deleteRecord:
                              return NeuColors.priorityCritical;
                            case SecurityAction.login:
                            case SecurityAction.appUnlocked:
                            case SecurityAction.backupRestored:
                              return NeuColors.success;
                            case SecurityAction.exportData:
                            case SecurityAction.backupCreated:
                            case SecurityAction.pinChanged:
                              return NeuColors.accentMuted;
                            default:
                              return isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary;
                          }
                        }

                        final color = getActionColor(action);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: NeuCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Action Icon Container
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    getActionIcon(action),
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Details Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            action.arabicLabel,
                                            style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            dateStr,
                                            style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (log.details?.isNotEmpty == true) ...[
                                        Text(
                                          log.details!,
                                          style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      Row(
                                        children: [
                                          if (log.deviceInfo?.isNotEmpty == true) ...[
                                            Icon(Icons.phone_android_rounded, size: 12, color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                            const SizedBox(width: 4),
                                            Text(
                                              log.deviceInfo!,
                                              style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(fontSize: 10),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                          if (log.ipAddress?.isNotEmpty == true) ...[
                                            Icon(Icons.lan_rounded, size: 12, color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                                            const SizedBox(width: 4),
                                            Text(
                                              log.ipAddress!,
                                              style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(fontSize: 10),
                                            ),
                                          ],
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
            ],
          ),
        ),
      ),
    );
  }
}