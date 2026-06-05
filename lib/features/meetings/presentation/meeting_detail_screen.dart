import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/meetings_provider.dart';
import '../domain/meetings_repository.dart';

/// Meeting Detail Screen — full meeting information view.
class MeetingDetailScreen extends ConsumerWidget {
  const MeetingDetailScreen({super.key, required this.meetingId});

  final int meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingState = ref.watch(meetingDetailProvider(meetingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.meetingsListFull),
        ),
        title: Text(
          'تفاصيل الاجتماع',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ), 
            onPressed: meetingState.valueOrNull != null 
                ? () => context.push(RouteNames.meetingEditPath(meetingId)) 
                : null,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ), 
            onPressed: meetingState.valueOrNull != null 
                ? () => _showMoreOptions(context, ref, meetingState.valueOrNull!) 
                : null,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: meetingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err', style: isDark ? AppTypography.bodyDark : AppTypography.body)),
          data: (meeting) {
            if (meeting == null) {
              return Center(child: Text('الاجتماع غير موجود أو تم حذفه', style: isDark ? AppTypography.bodyDark : AppTypography.body));
            }

            return ListView(
              padding: AppSpacing.screen,
              children: [
                // Title & Status
                NeuCard(
                  showGoldBorder: true,
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meeting.title, 
                              style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                            ),
                          ),
                          StatusBadge.fromMeetingStatus(meeting.status),
                        ],
                      ),
                      AppSpacing.gapMd,
                      _buildInfoRow(
                        context, 
                        Icons.group_work_rounded, 
                        'النوع', 
                        meeting.customMeetingType ?? MeetingType.fromValue(meeting.meetingType).arabicLabel
                      ),
                      AppSpacing.gapSm,
                      _buildInfoRow(context, Icons.calendar_today_rounded, 'التاريخ', meeting.date),
                      AppSpacing.gapSm,
                      _buildInfoRow(context, Icons.access_time_rounded, 'الوقت', meeting.time),
                      AppSpacing.gapSm,
                      _buildInfoRow(
                        context,
                        Icons.location_on_outlined, 
                        'المكان', 
                        meeting.location?.isNotEmpty == true ? meeting.location! : 'غير محدد'
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapMd,

                // Status Selector Block
                NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تحديث حالة الاجتماع',
                        style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                      ),
                      AppSpacing.gapSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: MeetingStatus.values.map((statusVal) {
                            final isSelected = statusVal.value == meeting.status;
                            final color = switch (statusVal) {
                              MeetingStatus.scheduled => NeuColors.info,
                              MeetingStatus.inProgress => NeuColors.warning,
                              MeetingStatus.completed => NeuColors.success,
                              MeetingStatus.postponed => NeuColors.warning,
                              MeetingStatus.cancelled => NeuColors.danger,
                            };
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  if (isSelected) return;
                                  try {
                                    await ref
                                        .read(meetingsRepositoryProvider)
                                        .updateStatus(meetingId, statusVal);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'تم تحديث الحالة إلى: ${statusVal.arabicLabel}',
                                            textDirection: TextDirection.rtl,
                                          ),
                                          backgroundColor: NeuColors.success,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('حدث خطأ: $e'),
                                          backgroundColor: NeuColors.danger,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withAlpha(isDark ? 35 : 25)
                                        : (isDark
                                            ? NeuColors.surfaceDark
                                            : NeuColors.surface),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : (isDark
                                              ? NeuColors.dividerDark
                                              : NeuColors.divider),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: isDark
                                                  ? NeuColors.shadowDarkDark
                                                  : NeuColors.shadowDark,
                                              offset: const Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: isDark
                                                  ? NeuColors.shadowLightDark
                                                  : NeuColors.shadowLight,
                                              offset: const Offset(-2, -2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                  ),
                                  child: Text(
                                    statusVal.arabicLabel,
                                    style: (isDark
                                            ? AppTypography.bodySmallDark
                                            : AppTypography.bodySmall)
                                        .copyWith(
                                      color: isSelected
                                          ? color
                                          : (isDark
                                              ? NeuColors.textSecondaryDark
                                              : NeuColors.textSecondary),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapMd,

                // Objective
                if (meeting.objective?.isNotEmpty == true) ...[
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('هدف الاجتماع', style: isDark ? AppTypography.h4Dark : AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(
                          meeting.objective!, 
                          style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapMd,
                ],

                // Notes
                if (meeting.notes?.isNotEmpty == true) ...[
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ملاحظات', style: isDark ? AppTypography.h4Dark : AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(
                          meeting.notes!, 
                          style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapMd,
                ],

                // الحاضرون
                _buildListSection(
                  context: context,
                  icon: Icons.groups_rounded,
                  title: 'قائمة الحضور',
                  items: _decodeJsonList(meeting.attendees, isAttendee: true),
                  isNumbered: false,
                  isDark: isDark,
                ),

                // جدول الأعمال
                _buildListSection(
                  context: context,
                  icon: Icons.list_alt_rounded,
                  title: 'جدول الأعمال',
                  items: _decodeJsonList(meeting.agenda, isAttendee: false),
                  isNumbered: true,
                  isDark: isDark,
                ),

                // القرارات والتوصيات
                _buildListSection(
                  context: context,
                  icon: Icons.gavel_rounded,
                  title: 'القرارات والتوصيات',
                  items: _decodeJsonList(meeting.decisions, isAttendee: false),
                  isNumbered: true,
                  isDark: isDark,
                  accentColor: NeuColors.goldAccent,
                ),
                AppSpacing.gapXxl,
              ],
            );
          },
        ),
      ),
    );
  }

  List<String> _decodeJsonList(String? jsonStr, {bool isAttendee = false}) {
    if (jsonStr == null || jsonStr.isEmpty || jsonStr == '[]') return [];
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is List) {
        return decoded.map((e) {
          if (e is Map) {
            if (isAttendee) {
              final name = e['name']?.toString() ?? e['description']?.toString() ?? '';
              final role = e['role']?.toString() ?? e['executor']?.toString() ?? '';
              return role.isNotEmpty ? '$name ($role)' : name;
            } else {
              final desc = e['description']?.toString() ?? '';
              final exec = e['executor']?.toString() ?? '';
              return (exec.isNotEmpty && exec != 'غير محدد') ? '$desc [المنفذ: $exec]' : desc;
            }
          }
          return e.toString();
        }).where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {}
    return [];
  }

  Widget _buildListSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<String> items,
    required bool isNumbered,
    required bool isDark,
    Color? accentColor,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final color = accentColor ?? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 25 : 15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  AppSpacing.gapHSm,
                  Text(
                    title,
                    style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                  ),
                ],
              ),
              AppSpacing.gapMd,
              Column(
                children: items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: color.withAlpha(isDark ? 20 : 12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isNumbered
                                ? Text(
                                    '${idx + 1}',
                                    style: AppTypography.caption.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  )
                                : Icon(Icons.person_rounded, size: 12, color: color),
                          ),
                        ),
                        AppSpacing.gapHSm,
                        Expanded(
                          child: Text(
                            item,
                            style: isDark ? AppTypography.bodyDark : AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon, 
          size: 18, 
          color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
        ),
        AppSpacing.gapHSm,
        Text(
          '$label: ', 
          style: isDark ? AppTypography.labelDark : AppTypography.label,
        ),
        Expanded(
          child: Text(
            value, 
            style: isDark ? AppTypography.bodyDark : AppTypography.body,
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, dynamic meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: NeuColors.success),
                title: Text(
                  'تحديد كمكتمل', 
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                ),
                onTap: () {
                  ref.read(meetingsRepositoryProvider).updateStatus(meetingId, MeetingStatus.completed);
                  ctx.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحالة بنجاح')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: NeuColors.warning),
                title: Text(
                  'إلغاء الاجتماع', 
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                ),
                onTap: () {
                  ref.read(meetingsRepositoryProvider).updateStatus(meetingId, MeetingStatus.cancelled);
                  ctx.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الاجتماع')));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: NeuColors.danger),
                title: Text(
                  'حذف الاجتماع', 
                  style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                    color: NeuColors.danger, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  ctx.pop();
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          title: Text(
            'حذف الاجتماع', 
            style: isDark ? AppTypography.h3Dark : AppTypography.h3,
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذا الاجتماع نهائياً؟', 
            style: isDark ? AppTypography.bodyDark : AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(), 
              child: Text(
                'تراجع',
                style: TextStyle(
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                  fontFamily: AppTypography.fontFamilyBody,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(meetingsRepositoryProvider).deleteMeeting(meetingId);
                ctx.pop();
                context.pop(); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الاجتماع بنجاح')));
              },
              child: const Text('حذف', style: TextStyle(color: NeuColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
