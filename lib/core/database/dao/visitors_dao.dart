import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/visitors_table.dart';

part 'visitors_dao.g.dart';

@DriftAccessor(tables: [Visitors])
class VisitorsDao extends DatabaseAccessor<AppDatabase> with _$VisitorsDaoMixin {
  VisitorsDao(super.db);

  Future<int> insertVisitor(VisitorsCompanion visitor) => into(visitors).insert(visitor);
  Future<bool> updateVisitorStatus(int id, int newStatus, String? exitTime) async {
    final result = await (update(visitors)..where((t) => t.id.equals(id))).write(
        VisitorsCompanion(
          status: Value(newStatus),
          exitTime: exitTime != null ? Value(exitTime) : const Value.absent(),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    return result > 0;
  }
  Stream<List<VisitorItem>> watchActiveVisitors() =>
      (select(visitors)..where((t) => t.isDeleted.equals(false) & t.status.isSmallerThanValue(2))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .watch();

  Future<void> softDelete(int id) =>
      (update(visitors)..where((v) => v.id.equals(id))).write(
        VisitorsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<bool> updateVisitor(VisitorsCompanion visitor, int id) =>
      (update(visitors)..where((v) => v.id.equals(id)))
          .write(visitor)
          .then((rows) => rows > 0);
}