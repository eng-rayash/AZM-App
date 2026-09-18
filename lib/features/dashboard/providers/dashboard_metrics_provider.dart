import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../finance/domain/finance_repository.dart';
import '../../followups/providers/follow_ups_provider.dart';

/// Revenue and expenses for a single calendar month.
class MonthlyPoint {
  const MonthlyPoint({
    required this.month,
    required this.label,
    required this.revenue,
    required this.expenses,
  });

  /// First day of the month this point covers.
  final DateTime month;

  /// Short Arabic month name, e.g. `يناير`.
  final String label;

  final double revenue;
  final double expenses;

  double get net => revenue - expenses;
}

/// One weighted contributor to the business health score.
class HealthFactor {
  const HealthFactor({
    required this.label,
    required this.ratio,
    required this.weight,
  });

  /// Arabic name shown in the score breakdown.
  final String label;

  /// Normalised 0..1 performance for this factor.
  final double ratio;

  /// Share of the total score, in points.
  final int weight;

  int get points => (ratio.clamp(0.0, 1.0) * weight).round();
}

/// Every figure the executive dashboard shows, derived from stored records.
///
/// Nothing here is invented: when the underlying tables are empty the metrics
/// report zero and [hasAnyData] is false, so the UI can show an onboarding
/// state instead of numbers that look like real business performance.
class DashboardMetrics {
  const DashboardMetrics({
    required this.series,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.revenueChange,
    required this.expensesChange,
    required this.activeProjects,
    required this.newProjectsThisMonth,
    required this.pendingFollowUps,
    required this.overdueFollowUps,
    required this.dueTodayFollowUps,
    required this.overdueInvoices,
    required this.healthFactors,
    required this.hasAnyData,
  });

  /// Trailing months, oldest first, ending with the current month.
  final List<MonthlyPoint> series;

  final double totalRevenue;
  final double totalExpenses;

  /// Month-over-month change as a fraction, or null when the previous month
  /// has nothing to compare against.
  final double? revenueChange;
  final double? expensesChange;

  final int activeProjects;
  final int newProjectsThisMonth;

  final int pendingFollowUps;
  final int overdueFollowUps;
  final int dueTodayFollowUps;
  final int overdueInvoices;

  final List<HealthFactor> healthFactors;

  /// False when no revenue, expense, project or follow-up has been recorded.
  final bool hasAnyData;

  double get netProfit => totalRevenue - totalExpenses;

  /// Business health, 0–100. Null while there is nothing to score.
  int? get healthScore {
    if (!hasAnyData || healthFactors.isEmpty) return null;
    final earned = healthFactors.fold<int>(0, (sum, f) => sum + f.points);
    final available = healthFactors.fold<int>(0, (sum, f) => sum + f.weight);
    if (available == 0) return null;
    return ((earned / available) * 100).round();
  }

  String? get healthLabel {
    final score = healthScore;
    if (score == null) return null;
    if (score >= 85) return 'ممتاز';
    if (score >= 70) return 'جيد';
    if (score >= 50) return 'مقبول';
    return 'يحتاج معالجة';
  }
}

const _arabicMonths = <String>[
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// Number of trailing months plotted on the performance chart.
const int kDashboardSeriesMonths = 6;

DateTime _monthKey(DateTime d) => DateTime(d.year, d.month);

double? _change(double current, double previous) {
  if (previous <= 0) return null;
  return (current - previous) / previous;
}

/// Live executive metrics. Recomputes whenever any source table changes.
final dashboardMetricsProvider = Provider<AsyncValue<DashboardMetrics>>((ref) {
  final revenuesAsync = ref.watch(revenuesListProvider);
  final expensesAsync = ref.watch(expensesListProvider);
  final projectsAsync = ref.watch(activeProjectsProvider);
  final followUpsAsync = ref.watch(followUpsListProvider);
  final invoicesAsync = ref.watch(overdueInvoicesProvider);

  // Surface the first real failure rather than papering over it.
  for (final async in [
    revenuesAsync,
    expensesAsync,
    projectsAsync,
    followUpsAsync,
    invoicesAsync,
  ]) {
    if (async.hasError) {
      return AsyncValue.error(async.error!, async.stackTrace ?? StackTrace.current);
    }
  }

  final revenues = revenuesAsync.valueOrNull;
  final expenses = expensesAsync.valueOrNull;
  final projects = projectsAsync.valueOrNull;
  final followUps = followUpsAsync.valueOrNull;
  final overdueInvoices = invoicesAsync.valueOrNull;

  if (revenues == null ||
      expenses == null ||
      projects == null ||
      followUps == null ||
      overdueInvoices == null) {
    return const AsyncValue.loading();
  }

  final now = DateTime.now();
  final thisMonth = _monthKey(now);

  // ── Monthly series ────────────────────────────────────────────────────
  final months = List<DateTime>.generate(
    kDashboardSeriesMonths,
    (i) => DateTime(now.year, now.month - (kDashboardSeriesMonths - 1 - i)),
  );

  final revenueByMonth = <DateTime, double>{};
  for (final r in revenues) {
    final d = DateTime.tryParse(r.date);
    if (d == null) continue;
    final key = _monthKey(d);
    revenueByMonth[key] = (revenueByMonth[key] ?? 0) + r.amount;
  }

  final expenseByMonth = <DateTime, double>{};
  for (final e in expenses) {
    final d = DateTime.tryParse(e.date);
    if (d == null) continue;
    final key = _monthKey(d);
    expenseByMonth[key] = (expenseByMonth[key] ?? 0) + e.amount;
  }

  final series = [
    for (final m in months)
      MonthlyPoint(
        month: m,
        label: _arabicMonths[m.month - 1],
        revenue: revenueByMonth[m] ?? 0,
        expenses: expenseByMonth[m] ?? 0,
      ),
  ];

  final totalRevenue = revenues.fold<double>(0, (sum, r) => sum + r.amount);
  final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);

  final previousMonth = DateTime(now.year, now.month - 1);
  final revenueChange = _change(
    revenueByMonth[thisMonth] ?? 0,
    revenueByMonth[previousMonth] ?? 0,
  );
  final expensesChange = _change(
    expenseByMonth[thisMonth] ?? 0,
    expenseByMonth[previousMonth] ?? 0,
  );

  // ── Projects ──────────────────────────────────────────────────────────
  final newProjectsThisMonth = projects.where((p) {
    final created = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
    return _monthKey(created) == thisMonth;
  }).length;

  // ── Follow-ups ────────────────────────────────────────────────────────
  // status: 0 new · 1 in progress · 2 awaiting response · 3 done · 4 overdue
  final completedFollowUps = followUps.where((f) => f.status == 3).length;
  final overdueFollowUps = followUps.where((f) => f.status == 4).length;
  final pendingFollowUps = followUps.where((f) => f.status != 3).length;

  final today = DateTime(now.year, now.month, now.day);
  final dueTodayFollowUps = followUps.where((f) {
    if (f.status == 3) return false;
    final due =
        f.targetDate == null ? null : DateTime.tryParse(f.targetDate!);
    if (due == null) return false;
    return DateTime(due.year, due.month, due.day) == today;
  }).length;

  // ── Health factors ────────────────────────────────────────────────────
  // Each factor is only scored when its input actually exists, so an empty
  // module never drags the score down or props it up.
  final factors = <HealthFactor>[];

  if (totalRevenue > 0) {
    factors.add(HealthFactor(
      label: 'هامش الربح',
      // A 25% net margin counts as full marks.
      ratio: ((totalRevenue - totalExpenses) / totalRevenue) / 0.25,
      weight: 30,
    ));
  }
  if (followUps.isNotEmpty) {
    factors.add(HealthFactor(
      label: 'إنجاز المتابعات',
      ratio: completedFollowUps / followUps.length,
      weight: 25,
    ));
    factors.add(HealthFactor(
      label: 'الالتزام بالمواعيد',
      ratio: 1 - (overdueFollowUps / followUps.length),
      weight: 25,
    ));
  }
  if (overdueInvoices.isNotEmpty || totalRevenue > 0) {
    final overdueValue =
        overdueInvoices.fold<double>(0, (sum, i) => sum + (i.total - i.paidAmount));
    factors.add(HealthFactor(
      label: 'التحصيل',
      ratio: totalRevenue <= 0 ? 0 : 1 - (overdueValue / totalRevenue),
      weight: 20,
    ));
  }

  final hasAnyData = revenues.isNotEmpty ||
      expenses.isNotEmpty ||
      projects.isNotEmpty ||
      followUps.isNotEmpty;

  return AsyncValue.data(DashboardMetrics(
    series: series,
    totalRevenue: totalRevenue,
    totalExpenses: totalExpenses,
    revenueChange: revenueChange,
    expensesChange: expensesChange,
    activeProjects: projects.length,
    newProjectsThisMonth: newProjectsThisMonth,
    pendingFollowUps: pendingFollowUps,
    overdueFollowUps: overdueFollowUps,
    dueTodayFollowUps: dueTodayFollowUps,
    overdueInvoices: overdueInvoices.length,
    healthFactors: factors,
    hasAnyData: hasAnyData,
  ));
});
