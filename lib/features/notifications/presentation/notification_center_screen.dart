import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification Model (local — no backend needed yet)
// ─────────────────────────────────────────────────────────────────────────────
enum NotifCategory { followup, invoice, hrm, project, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.time,
    this.isRead = false,
    this.actionPath,
  });

  final int id;
  final String title;
  final String body;
  final NotifCategory category;
  final DateTime time;
  final bool isRead;
  final String? actionPath;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id, title: title, body: body,
    category: category, time: time,
    isRead: isRead ?? this.isRead,
    actionPath: actionPath,
  );

  Color get color {
    switch (category) {
      case NotifCategory.followup: return NeuColors.navyDeep;
      case NotifCategory.invoice: return const Color(0xFF00CEC9);
      case NotifCategory.hrm: return const Color(0xFF6C5CE7);
      case NotifCategory.project: return const Color(0xFFE17055);
      case NotifCategory.system: return NeuColors.textHint;
    }
  }

  IconData get icon {
    switch (category) {
      case NotifCategory.followup: return Icons.replay_rounded;
      case NotifCategory.invoice: return Icons.receipt_long_rounded;
      case NotifCategory.hrm: return Icons.badge_rounded;
      case NotifCategory.project: return Icons.work_rounded;
      case NotifCategory.system: return Icons.info_rounded;
    }
  }

  String get categoryLabel {
    switch (category) {
      case NotifCategory.followup: return 'متابعات';
      case NotifCategory.invoice: return 'فواتير';
      case NotifCategory.hrm: return 'موارد بشرية';
      case NotifCategory.project: return 'مشاريع';
      case NotifCategory.system: return 'النظام';
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return 'منذ أسبوع';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Provider
// ─────────────────────────────────────────────────────────────────────────────
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(_sampleNotifications());

  static List<AppNotification> _sampleNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 1,
        title: 'متابعة متأخرة',
        body: 'لديك متابعة مع عميل "شركة النور" متأخرة منذ يومين',
        category: NotifCategory.followup,
        time: now.subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        id: 2,
        title: 'فاتورة مستحقة',
        body: 'فاتورة #INV-2024-058 لعميل "مؤسسة الرياض" مستحقة اليوم',
        category: NotifCategory.invoice,
        time: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 3,
        title: 'عقد موظف يقترب من الانتهاء',
        body: 'عقد الموظف "أحمد محمد" ينتهي خلال 30 يوماً',
        category: NotifCategory.hrm,
        time: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 4,
        title: 'مشروع متأخر',
        body: 'مشروع "تطوير الموقع الإلكتروني" تجاوز الموعد المحدد',
        category: NotifCategory.project,
        time: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 5,
        title: 'نسخة احتياطية',
        body: 'تمت النسخة الاحتياطية التلقائية بنجاح',
        category: NotifCategory.system,
        time: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  void markAsRead(int id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void deleteNotification(int id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() => state = [];

  int get unreadCount => state.where((n) => !n.isRead).length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Center Screen
// ─────────────────────────────────────────────────────────────────────────────
class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  NotifCategory? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? NeuColors.bgColorDark : NeuColors.bgColor;
    final notifier = ref.read(notificationsProvider.notifier);
    final notifications = ref.watch(notificationsProvider);

    final unread = notifications.where((n) => !n.isRead).toList();
    final all = notifications;

    final displayList = _tabCtrl.index == 0 ? unread : all;
    final filtered = _categoryFilter == null
        ? displayList
        : displayList.where((n) => n.category == _categoryFilter).toList();

    return Scaffold(
      backgroundColor: bg,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 130,
              backgroundColor:
                  isDark ? NeuColors.bgColorDark : NeuColors.navyDeep,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                TextButton(
                  onPressed: () => notifier.markAllAsRead(),
                  child: const Text('قراءة الكل',
                      style: TextStyle(color: Colors.white70,
                          fontFamily: 'Cairo', fontSize: 13)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                  onPressed: () => _confirmClearAll(context, notifier),
                  tooltip: 'مسح الكل',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1A2436), const Color(0xFF22549E)]
                          : [NeuColors.navyDeep, NeuColors.navyMid],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.notifications_rounded,
                              color: Colors.white, size: 26),
                          const SizedBox(width: 10),
                          Text('مركز الإشعارات',
                              style: AppTypography.h3.copyWith(color: Colors.white)),
                          const Spacer(),
                          if (unread.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: NeuColors.danger,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${unread.length} جديد',
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 12, fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700)),
                            ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabCtrl,
                onTap: (_) => setState(() {}),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: NeuColors.goldAccent,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  Tab(text: 'غير مقروءة (${unread.length})'),
                  Tab(text: 'الكل (${all.length})'),
                ],
              ),
            ),

            // Category filter
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  _CatChip(label: 'الكل', selected: _categoryFilter == null,
                      color: NeuColors.navyDeep, isDark: isDark,
                      onTap: () => setState(() => _categoryFilter = null)),
                  ...NotifCategory.values.map((cat) {
                    final n = AppNotification(
                      id: 0, title: '', body: '',
                      category: cat, time: DateTime.now(),
                    );
                    return _CatChip(
                      label: n.categoryLabel,
                      selected: _categoryFilter == cat,
                      color: n.color, isDark: isDark,
                      onTap: () => setState(() =>
                          _categoryFilter = _categoryFilter == cat ? null : cat),
                    );
                  }),
                ]),
              ),
            ),
          ],
          body: filtered.isEmpty
              ? _EmptyNotifications(isDark: isDark,
                  isUnread: _tabCtrl.index == 0)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final notif = filtered[i];
                    return _NotifTile(
                      notif: notif,
                      isDark: isDark,
                      onTap: () {
                        notifier.markAsRead(notif.id);
                        if (notif.actionPath != null) {
                          context.push(notif.actionPath!);
                        }
                      },
                      onDismiss: () => notifier.deleteNotification(notif.id),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, NotificationsNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مسح كل الإشعارات؟',
            textDirection: TextDirection.rtl),
        content: const Text('سيتم حذف جميع الإشعارات نهائياً.',
            textDirection: TextDirection.rtl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.clearAll();
            },
            child: const Text('مسح', style: TextStyle(color: NeuColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Tile
// ─────────────────────────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notif;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final ts = isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary;
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;

    return Dismissible(
      key: Key('notif_${notif.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: NeuColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: NeuColors.danger),
      ),
      onDismissed: (_) => onDismiss(),
      child: NeuCard(
        isDark: isDark, radius: 16,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: notif.isRead
                  ? Colors.transparent
                  : notif.color.withOpacity(isDark ? 0.06 : 0.04),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicator + icon
                Stack(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: notif.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(notif.icon, color: notif.color, size: 22),
                  ),
                  if (!notif.isRead)
                    Positioned(
                      top: 0, left: 0,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: NeuColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                              width: 2),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(width: 12),
                // Content
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: notif.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(notif.categoryLabel,
                            style: TextStyle(
                              fontSize: 10, fontFamily: 'Cairo',
                              color: notif.color,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      const Spacer(),
                      Text(notif.timeAgo,
                          style: AppTypography.caption.copyWith(color: th)),
                    ]),
                    const SizedBox(height: 5),
                    Text(notif.title, style: AppTypography.body.copyWith(
                        color: tp,
                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(notif.body,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(color: ts)),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label, required this.selected,
    required this.color, required this.isDark, required this.onTap,
  });

  final String label;
  final bool selected, isDark;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? color : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: selected ? color : color.withOpacity(0.3), width: 1.2),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 12, fontFamily: 'Cairo',
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? Colors.white : color,
      )),
    ),
  );
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.isDark, required this.isUnread});
  final bool isDark, isUnread;

  @override
  Widget build(BuildContext context) {
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(
        isUnread ? Icons.notifications_off_rounded : Icons.notifications_none_rounded,
        size: 64,
        color: (isDark ? NeuColors.goldAccent : NeuColors.navyDeep).withOpacity(0.25),
      ),
      const SizedBox(height: 16),
      Text(isUnread ? 'لا توجد إشعارات جديدة ✓' : 'لا توجد إشعارات',
          style: AppTypography.bodySmall.copyWith(color: th)),
    ]));
  }
}
