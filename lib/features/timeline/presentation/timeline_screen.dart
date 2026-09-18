import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../providers/timeline_provider.dart';

/// Timeline Screen — Phase 4
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final events = ref.watch(timelineProvider);

    IconData getEventIcon(String type) {
      switch (type) {
        case 'meeting': return Icons.groups_rounded;
        case 'visitor': return Icons.badge_rounded;
        case 'movement': return Icons.directions_car_rounded;
        case 'appointment': return Icons.calendar_month_rounded;
        case 'task': return Icons.task_alt_rounded;
        case 'call': return Icons.phone_in_talk_rounded;
        case 'directive': return Icons.campaign_rounded;
        default: return Icons.event_note_rounded;
      }
    }

    Color getEventColor(String type) {
      switch (type) {
        case 'meeting': return NeuColors.info;
        case 'visitor': return NeuColors.warning;
        case 'movement': return NeuColors.accentMuted;
        case 'appointment': return NeuColors.success;
        case 'task': return NeuColors.navyLight;
        case 'call': return NeuColors.info;
        case 'directive': return NeuColors.danger;
        default: return NeuColors.accentMuted;
      }
    }

    String getEventTypeName(String type) {
      switch (type) {
        case 'meeting': return 'اجتماع';
        case 'visitor': return 'لقاء / زيارة';
        case 'movement': return 'تحرك خارجي';
        case 'appointment': return 'موعد';
        case 'task': return 'مهمة عمل';
        case 'call': return 'مكالمة هاتفية';
        case 'directive': return 'توجيه تنفيذي';
        default: return 'حدث';
      }
    }

    void handleEventTap(BuildContext context, TimelineEvent event) {
      if (event.id == null) return;
      switch (event.type) {
        case 'meeting':
          context.push(RouteNames.meetingDetailPath(event.id!));
          break;
        case 'task':
          context.push(RouteNames.taskDetailPath(event.id!));
          break;
        case 'directive':
          context.push(RouteNames.directiveDetailPath(event.id!));
          break;
        case 'appointment':
          context.push(RouteNames.appointmentsList);
          break;
        case 'call':
          context.push(RouteNames.callsList);
          break;
        case 'visitor':
          context.push(RouteNames.visitorsList);
          break;
        case 'movement':
          context.push(RouteNames.movementsList);
          break;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'المخطط الزمني لليوم',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: events.isEmpty
            ? Center(
                child: Text(
                  'لا توجد أحداث مجدولة لليوم',
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                ),
              )
            : ListView.builder(
                padding: AppSpacing.screen,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final color = getEventColor(event.type);
                  final icon = getEventIcon(event.type);
                  final typeName = getEventTypeName(event.type);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Column
                        SizedBox(
                          width: 60,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              event.time,
                              style: (isDark ? AppTypography.h4Dark : AppTypography.h4).copyWith(
                                color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        // Timeline line & dot
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 18),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: event.isCompleted ? NeuColors.success : color,
                                border: Border.all(
                                  color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            if (index != events.length - 1)
                              Container(
                                width: 2,
                                height: 75,
                                color: isDark ? NeuColors.dividerDark : NeuColors.divider,
                              ),
                          ],
                        ),

                        AppSpacing.gapHMd,

                        // Event Card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => handleEventTap(context, event),
                              child: NeuCard(
                                padding: const EdgeInsets.all(16),
                                margin: EdgeInsets.zero,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        icon,
                                        color: event.isCompleted ? NeuColors.success : color,
                                        size: 22,
                                      ),
                                    ),
                                    AppSpacing.gapHMd,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          AppSpacing.gapXs,
                                          Text(
                                            typeName,
                                            style: (isDark ? AppTypography.captionDark : AppTypography.caption),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (event.isCompleted)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: NeuColors.success,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}