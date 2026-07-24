import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/calls_table.dart';

part 'calls_dao.g.dart';

@DriftAccessor(tables: [Calls])
class CallsDao extends DatabaseAccessor<AppDatabase> with _$CallsDaoMixin {
  CallsDao(super.db);

  Future<int> insertCall(CallsCompanion call) => into(calls).insert(call);
  Future<List<CallItem>> getAllCalls() =>
      (select(calls)..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .get();
  Stream<List<CallItem>> watchAllCalls() =>
      (select(calls)..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .watch();

  Future<void> softDelete(int id) =>
      (update(calls)..where((c) => c.id.equals(id))).write(
        CallsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<bool> updateCall(CallsCompanion call, int id) =>
      (update(calls)..where((c) => c.id.equals(id)))
          .write(call)
          .then((rows) => rows > 0);
}