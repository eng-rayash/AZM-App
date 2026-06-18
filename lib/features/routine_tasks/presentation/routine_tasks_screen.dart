import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/routine_task_model.dart';
import '../providers/routine_tasks_provider.dart';

// ─────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────

class RoutineTasksScreen extends ConsumerStatefulWidget {
  const RoutineTasksScreen({super.key});

  @override
  ConsumerState<RoutineTasksScreen> createState() =>
      _RoutineTasksScreenState();
}

class _RoutineTasksScreenState extends ConsumerState<RoutineTasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  static const _tabCount = 3; // اليوم / الأسبوع / إدارة المهام

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(routineTasksProvider);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ── Header ──
            _RoutineHeader(isDark: isDark),

            // ── Tab Bar ──
            _buildTabBar(isDark),

            // ── Tab Views ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TodayTab(isDark: isDark),
                  _WeekTab(isDark: isDark),
                  _ManageTab(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index < 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddTaskSheet(context, isDark),
              backgroundColor:
                  isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'إضافة مهمة',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? NeuColors.shadowDarkDark
                    : NeuColors.shadowDark,
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTab(isDark, 0, '☀️ اليوم'),
              _buildTab(isDark, 1, '📅 الأسبوع'),
              _buildTab(isDark, 2, '⚙️ الإدارة'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(bool isDark, int index, String label) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Tajawal',
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark
                      ? NeuColors.textSecondaryDark
                      : NeuColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRoutineTaskSheet(isDark: isDark),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────

class _RoutineHeader extends ConsumerWidget {
  final bool isDark;

  const _RoutineHeader({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineTasksProvider);
    final today = DateTime.now();
    final ratio = state.completionRatioForDate(today);
    final completed = state.completedForDate(today);
    final total = state.totalForDate(today);
    final streak = state.streakForToday();

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    NeuColors.navyDeep,
                    const Color(0xFF1A3A6B),
                  ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'روتيني اليومي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE، d MMMM', 'ar').format(today),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Streak badge
                if (streak > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$streak يوم',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress section
            Row(
              children: [
                // Progress circle
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 7,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ratio >= 0.8
                              ? const Color(0xFF4CAF50)
                              : ratio >= 0.4
                                  ? const Color(0xFFFFB300)
                                  : const Color(0xFFEF5350),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${(ratio * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total == 0
                            ? 'لا توجد مهام اليوم'
                            : 'أنجزت $completed من $total مهمة',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ratio >= 1.0
                            ? '🎉 أحسنت! أكملت روتينك اليوم!'
                            : ratio >= 0.8
                                ? '💪 رائع، أنت قريب من الإنجاز!'
                                : ratio >= 0.4
                                    ? '⚡ استمر، لديك مهام تنتظر!'
                                    : total == 0
                                        ? 'أضف مهامك الروتينية'
                                        : '🎯 ابدأ بأهم مهمة الآن',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ratio >= 0.8
                      ? const Color(0xFF4CAF50)
                      : ratio >= 0.4
                          ? const Color(0xFFFFB300)
                          : const Color(0xFFEF5350),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Today Tab
// ─────────────────────────────────────────────────────────────────

class _TodayTab extends ConsumerWidget {
  final bool isDark;
  const _TodayTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineTasksProvider);
    final today = DateTime.now();
    final tasks = state.tasksForDate(today);

    if (tasks.isEmpty) {
      return _EmptyRoutineState(
        isDark: isDark,
        message: 'لا توجد مهام روتينية لليوم',
        subtitle: 'اذهب إلى تبويب "الإدارة" لإضافة مهامك',
        icon: Icons.sunny,
      );
    }

    // Group by category
    final Map<RoutineCategory, List<RoutineTask>> grouped = {};
    for (final task in tasks) {
      grouped.putIfAbsent(task.category, () => []).add(task);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in grouped.entries) ...[
          _CategoryHeader(category: entry.key, isDark: isDark),
          const SizedBox(height: 8),
          for (final task in entry.value)
            _RoutineTaskTile(
              task: task,
              isCompleted: state.isCompletedOn(task.id, today),
              isDark: isDark,
              date: today,
            ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Week Tab
// ─────────────────────────────────────────────────────────────────

class _WeekTab extends ConsumerStatefulWidget {
  final bool isDark;
  const _WeekTab({required this.isDark});

  @override
  ConsumerState<_WeekTab> createState() => _WeekTabState();
}

class _WeekTabState extends ConsumerState<_WeekTab> {
  late DateTime _selectedDay;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _weekDays = _getWeekDays(DateTime.now());
  }

  List<DateTime> _getWeekDays(DateTime any) {
    final monday = any.subtract(Duration(days: any.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routineTasksProvider);
    final tasks = state.tasksForDate(_selectedDay);
    final isDark = widget.isDark;

    return Column(
      children: [
        // Week day selector
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: _weekDays.map((day) {
              final isSelected = _isSameDay(day, _selectedDay);
              final isToday = _isSameDay(day, DateTime.now());
              final dayTasks = state.tasksForDate(day);
              final ratio = state.completionRatioForDate(day);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? NeuColors.goldAccent
                              : NeuColors.navyDeep)
                          : (isDark
                              ? NeuColors.surfaceDark
                              : NeuColors.surface),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: isDark
                                  ? NeuColors.goldAccent
                                  : NeuColors.navyDeep,
                              width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _arabicDay(day.weekday),
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Tajawal',
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : (isDark
                                    ? NeuColors.textSecondaryDark
                                    : NeuColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : (isDark
                                    ? NeuColors.textPrimaryDark
                                    : NeuColors.textPrimary),
                          ),
                        ),
                        if (dayTasks.isNotEmpty)
                          Container(
                            width: 28,
                            height: 3,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: ratio >= 1.0
                                  ? const Color(0xFF4CAF50)
                                  : ratio > 0
                                      ? const Color(0xFFFFB300)
                                      : Colors.grey.withValues(alpha: 0.4),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Tasks for selected day
        Expanded(
          child: tasks.isEmpty
              ? _EmptyRoutineState(
                  isDark: isDark,
                  message: 'لا توجد مهام في هذا اليوم',
                  subtitle: 'اضغط على الإدارة لإضافة مهام روتينية',
                  icon: Icons.event_available_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    return _RoutineTaskTile(
                      task: task,
                      isCompleted:
                          state.isCompletedOn(task.id, _selectedDay),
                      isDark: isDark,
                      date: _selectedDay,
                    );
                  },
                ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _arabicDay(int weekday) {
    const abbr = ['', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
    return abbr[weekday];
  }
}

// ─────────────────────────────────────────────────────────────────
// Manage Tab
// ─────────────────────────────────────────────────────────────────

class _ManageTab extends ConsumerWidget {
  final bool isDark;
  const _ManageTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineTasksProvider);
    final tasks = state.tasks;

    if (tasks.isEmpty) {
      return _EmptyRoutineState(
        isDark: isDark,
        message: 'لا توجد مهام روتينية بعد',
        subtitle: 'اضغط على زر + لإضافة مهمتك الأولى',
        icon: Icons.add_task_rounded,
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      onReorder: (oldIndex, newIndex) {
        final reordered = [...tasks];
        if (newIndex > oldIndex) newIndex--;
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);
        ref.read(routineTasksProvider.notifier).reorderTasks(reordered);
      },
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        return _ManageTaskTile(
          key: ValueKey(task.id),
          task: task,
          isDark: isDark,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Task Tile (Today & Week tabs)
// ─────────────────────────────────────────────────────────────────

class _RoutineTaskTile extends ConsumerWidget {
  final RoutineTask task;
  final bool isCompleted;
  final bool isDark;
  final DateTime date;

  const _RoutineTaskTile({
    required this.task,
    required this.isCompleted,
    required this.isDark,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = _priorityColor(task.priority);

    return GestureDetector(
      onTap: () =>
          ref.read(routineTasksProvider.notifier).toggleTask(task.id, date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCompleted
              ? (isDark
                  ? NeuColors.surfaceDark.withValues(alpha: 0.5)
                  : NeuColors.surface.withValues(alpha: 0.5))
              : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isCompleted
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? NeuColors.shadowDarkDark
                        : NeuColors.shadowDark,
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                  BoxShadow(
                    color: isDark
                        ? NeuColors.shadowLightDark
                        : NeuColors.shadowLight,
                    blurRadius: 6,
                    offset: const Offset(-2, -2),
                  ),
                ],
          border: Border(
            right: BorderSide(
              color: isCompleted
                  ? const Color(0xFF4CAF50)
                  : priorityColor,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF4CAF50)
                      : (isDark ? NeuColors.dividerDark : NeuColors.divider),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? (isDark
                              ? NeuColors.textSecondaryDark
                              : NeuColors.textSecondary)
                          : (isDark
                              ? NeuColors.textPrimaryDark
                              : NeuColors.textPrimary),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Tajawal',
                        color: isDark
                            ? NeuColors.textHintDark
                            : NeuColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Time & Category
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (task.time != null)
                  Text(
                    task.time!,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Tajawal',
                      color: isDark
                          ? NeuColors.goldAccent
                          : NeuColors.navyMid,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  task.category.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(RoutinePriority p) {
    switch (p) {
      case RoutinePriority.critical:
        return NeuColors.priorityCritical;
      case RoutinePriority.high:
        return NeuColors.danger;
      case RoutinePriority.medium:
        return NeuColors.warning;
      case RoutinePriority.low:
        return NeuColors.success;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// Manage Task Tile
// ─────────────────────────────────────────────────────────────────

class _ManageTaskTile extends ConsumerWidget {
  final RoutineTask task;
  final bool isDark;

  const _ManageTaskTile({
    super.key,
    required this.task,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeuCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Drag handle
          Icon(Icons.drag_handle_rounded,
              color: isDark
                  ? NeuColors.textHintDark
                  : NeuColors.textHint,
              size: 20),
          const SizedBox(width: 10),

          // Category emoji
          Text(task.category.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeuColors.textPrimaryDark
                        : NeuColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _SmallBadge(
                      label: task.repeat.arabicLabel,
                      color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _SmallBadge(
                      label: task.category.arabicLabel,
                      color: NeuColors.info,
                      isDark: isDark,
                    ),
                    if (task.time != null) ...[
                      const SizedBox(width: 6),
                      _SmallBadge(
                        label: task.time!,
                        color: NeuColors.success,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
              size: 20,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            onSelected: (value) async {
              if (value == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      _AddRoutineTaskSheet(isDark: isDark, editTask: task),
                );
              } else if (value == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded,
                        size: 16,
                        color: isDark
                            ? NeuColors.textPrimaryDark
                            : NeuColors.textPrimary),
                    const SizedBox(width: 8),
                    const Text('تعديل',
                        style: TextStyle(fontFamily: 'Tajawal')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        size: 16, color: NeuColors.priorityCritical),
                    const SizedBox(width: 8),
                    const Text('حذف',
                        style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: NeuColors.priorityCritical)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف المهمة',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
          content: Text('هل تريد حذف مهمة "${task.title}"؟',
              style: const TextStyle(fontFamily: 'Tajawal')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref
                    .read(routineTasksProvider.notifier)
                    .deleteTask(task.id);
              },
              child: const Text('حذف',
                  style: TextStyle(
                      color: NeuColors.priorityCritical,
                      fontFamily: 'Tajawal')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _SmallBadge(
      {required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'Tajawal',
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Category Header
// ─────────────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final RoutineCategory category;
  final bool isDark;

  const _CategoryHeader({required this.category, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(category.emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          category.arabicLabel,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            color: isDark
                ? NeuColors.textSecondaryDark
                : NeuColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: isDark ? NeuColors.dividerDark : NeuColors.divider,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────

class _EmptyRoutineState extends StatelessWidget {
  final bool isDark;
  final String message;
  final String subtitle;
  final IconData icon;

  const _EmptyRoutineState({
    required this.isDark,
    required this.message,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
            ),
            AppSpacing.gapLg,
            Text(
              message,
              style: (isDark ? AppTypography.h4Dark : AppTypography.h4)
                  .copyWith(
                color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              subtitle,
              style: (isDark
                      ? AppTypography.captionDark
                      : AppTypography.caption)
                  .copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Add / Edit Task Sheet
// ─────────────────────────────────────────────────────────────────

class _AddRoutineTaskSheet extends ConsumerStatefulWidget {
  final bool isDark;
  final RoutineTask? editTask;

  const _AddRoutineTaskSheet({required this.isDark, this.editTask});

  @override
  ConsumerState<_AddRoutineTaskSheet> createState() =>
      _AddRoutineTaskSheetState();
}

class _AddRoutineTaskSheetState
    extends ConsumerState<_AddRoutineTaskSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late RoutineCategory _category;
  late RoutinePriority _priority;
  late RoutineRepeat _repeat;
  late List<int> _daysOfWeek;
  String? _time;

  @override
  void initState() {
    super.initState();
    final task = widget.editTask;
    _titleCtrl = TextEditingController(text: task?.title ?? '');
    _descCtrl = TextEditingController(text: task?.description ?? '');
    _category = task?.category ?? RoutineCategory.personal;
    _priority = task?.priority ?? RoutinePriority.medium;
    _repeat = task?.repeat ?? RoutineRepeat.daily;
    _daysOfWeek = task?.daysOfWeek.toList() ?? [];
    _time = task?.time;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isEditing = widget.editTask != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 20,
          right: 20,
          left: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? NeuColors.dividerDark : NeuColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isEditing ? 'تعديل المهمة' : 'مهمة روتينية جديدة',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3,
              ),
              const SizedBox(height: 16),

              // Task name
              _buildTextField(
                controller: _titleCtrl,
                label: 'اسم المهمة *',
                hint: 'مثال: قراءة البريد، رياضة الصباح...',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Description
              _buildTextField(
                controller: _descCtrl,
                label: 'وصف المهمة (اختياري)',
                hint: 'تفاصيل إضافية...',
                isDark: isDark,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Category
              _SectionLabel(label: 'الفئة', isDark: isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RoutineCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? NeuColors.goldAccent
                                : NeuColors.navyDeep)
                            : (isDark
                                ? NeuColors.surfaceDark
                                : NeuColors.surface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                  ? NeuColors.dividerDark
                                  : NeuColors.divider),
                        ),
                      ),
                      child: Text(
                        '${cat.emoji} ${cat.arabicLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark
                                  ? NeuColors.textSecondaryDark
                                  : NeuColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Priority & Repeat in row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: 'الأولوية', isDark: isDark),
                        const SizedBox(height: 8),
                        _buildDropdown<RoutinePriority>(
                          value: _priority,
                          items: RoutinePriority.values,
                          labelOf: (p) => p.arabicLabel,
                          onChanged: (v) => setState(() => _priority = v!),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: 'التكرار', isDark: isDark),
                        const SizedBox(height: 8),
                        _buildDropdown<RoutineRepeat>(
                          value: _repeat,
                          items: RoutineRepeat.values,
                          labelOf: (r) => r.arabicLabel,
                          onChanged: (v) => setState(() => _repeat = v!),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Weekly day selector
              if (_repeat == RoutineRepeat.weekly) ...[
                const SizedBox(height: 16),
                _SectionLabel(label: 'أيام الأسبوع', isDark: isDark),
                const SizedBox(height: 8),
                _WeekDayPicker(
                  selected: _daysOfWeek,
                  isDark: isDark,
                  onChanged: (days) => setState(() => _daysOfWeek = days),
                ),
              ],

              const SizedBox(height: 16),

              // Time
              _SectionLabel(label: 'الوقت (اختياري)', isDark: isDark),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time != null
                        ? TimeOfDay(
                            hour: int.parse(_time!.split(':')[0]),
                            minute: int.parse(_time!.split(':')[1]),
                          )
                        : TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _time =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark ? NeuColors.dividerDark : NeuColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: isDark
                            ? NeuColors.goldAccent
                            : NeuColors.navyMid,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _time ?? 'اختر الوقت',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: _time != null
                              ? (isDark
                                  ? NeuColors.textPrimaryDark
                                  : NeuColors.textPrimary)
                              : (isDark
                                  ? NeuColors.textHintDark
                                  : NeuColors.textHint),
                        ),
                      ),
                      if (_time != null) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _time = null),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                    foregroundColor:
                        isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'حفظ التعديلات' : 'إضافة المهمة',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label, isDark: isDark),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
            ),
            filled: true,
            fillColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: isDark ? NeuColors.dividerDark : NeuColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: isDark ? NeuColors.dividerDark : NeuColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? NeuColors.dividerDark : NeuColors.divider,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
          ),
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
          dropdownColor:
              isDark ? NeuColors.surfaceDark : NeuColors.surface,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelOf(item),
                        style: const TextStyle(fontFamily: 'Tajawal')),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(routineTasksProvider.notifier);

    if (widget.editTask != null) {
      notifier.updateTask(widget.editTask!.copyWith(
        title: title,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        category: _category,
        priority: _priority,
        repeat: _repeat,
        time: _time,
        daysOfWeek: _daysOfWeek,
      ));
    } else {
      notifier.addTask(buildNewRoutineTask(
        title: title,
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        category: _category,
        priority: _priority,
        repeat: _repeat,
        time: _time,
        daysOfWeek: _daysOfWeek,
      ));
    }

    Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────────────────
// Week Day Picker
// ─────────────────────────────────────────────────────────────────

class _WeekDayPicker extends StatelessWidget {
  final List<int> selected;
  final bool isDark;
  final ValueChanged<List<int>> onChanged;

  const _WeekDayPicker({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  static const _labels = ['', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = selected.contains(day);
        return GestureDetector(
          onTap: () {
            final updated = [...selected];
            if (isSelected) {
              updated.remove(day);
            } else {
              updated.add(day);
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                  : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? NeuColors.dividerDark : NeuColors.divider),
              ),
            ),
            child: Center(
              child: Text(
                _labels[day],
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Tajawal',
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark
                          ? NeuColors.textSecondaryDark
                          : NeuColors.textSecondary),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontFamily: 'Tajawal',
        fontWeight: FontWeight.bold,
        color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
      ),
    );
  }
}
