import 'package:drift/drift.dart';
import '../base_table.dart';

/// Performance Evaluations table.
class PerformanceEvaluations extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  /// evaluationPeriod: e.g. "Q1-2025", "سنوي-2025"
  TextColumn get period => text()();
  TextColumn get periodStartDate => text().nullable()();
  TextColumn get periodEndDate => text().nullable()();
  IntColumn get evaluatorId => integer().nullable()();
  TextColumn get evaluatorName => text().nullable()(); // cached
  /// scores: JSON [{criteria, weight, score, maxScore}]
  TextColumn get scores => text().nullable()();
  RealColumn get totalScore => real().nullable()();
  RealColumn get maxPossibleScore => real().nullable()();
  RealColumn get percentage => real().nullable()();
  /// grade: 0=exceptional, 1=excellent, 2=good, 3=satisfactory, 4=needs-improvement
  IntColumn get grade => integer().nullable()();
  TextColumn get strengths => text().nullable()();
  TextColumn get areasForImprovement => text().nullable()();
  TextColumn get recommendations => text().nullable()();
  TextColumn get goals => text().nullable()(); // JSON array
  /// status: 0=draft, 1=submitted, 2=acknowledged
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get evaluationDate => text().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Training Records table.
class TrainingRecords extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  TextColumn get trainingName => text().withLength(min: 1, max: 200)();
  TextColumn get provider => text().nullable()();
  /// trainingType: 0=internal, 1=external, 2=online, 3=conference
  IntColumn get trainingType => integer().withDefault(const Constant(0))();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  IntColumn get hours => integer().nullable()();
  TextColumn get location => text().nullable()();
  RealColumn get cost => real().nullable()();
  TextColumn get certificate => text().nullable()(); // file path
  TextColumn get certificateExpiry => text().nullable()();
  /// status: 0=planned, 1=in-progress, 2=completed, 3=cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get skills => text().nullable()(); // JSON array of skills gained
  TextColumn get notes => text().nullable()();
}

/// Employee Assets (assigned company assets) table.
class EmployeeAssets extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  TextColumn get assetName => text().withLength(min: 1, max: 200)();
  TextColumn get assetCode => text().nullable()();
  /// assetType: 0=laptop, 1=phone, 2=vehicle, 3=equipment, 4=other
  IntColumn get assetType => integer().withDefault(const Constant(4))();
  TextColumn get assignedDate => text()();
  TextColumn get returnDate => text().nullable()();
  TextColumn get returnCondition => text().nullable()();
  /// condition: 0=new, 1=good, 2=fair, 3=poor, 4=damaged
  IntColumn get condition => integer().withDefault(const Constant(1))();
  /// status: 0=assigned, 1=returned, 2=lost, 3=damaged
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get serialNumber => text().nullable()();
  RealColumn get value => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
}

/// Rewards and Penalties table.
class RewardsPenalties extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  /// type: 0=reward/bonus, 1=penalty/deduction
  IntColumn get type => integer().withDefault(const Constant(0))();
  TextColumn get reason => text()();
  RealColumn get amount => real().nullable()();
  TextColumn get date => text()();
  IntColumn get issuedById => integer().nullable()();
  TextColumn get issuedByName => text().nullable()(); // cached
  /// status: 0=pending, 1=approved, 2=applied
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get attachments => text().nullable()(); // JSON
  TextColumn get notes => text().nullable()();
}