import 'package:drift/drift.dart';
import 'base_table.dart';
import 'tenant_scoped.dart';

/// Calls Table — Phase 4
/// Records incoming, outgoing, and missed calls.
@DataClassName('CallItem')
class Calls extends Table with BaseTableMixin, TenantScoped {
  TextColumn get callerName => text()();
  TextColumn get phoneNumber => text().nullable()();
  
  /// 0: Incoming, 1: Outgoing, 2: Missed
  IntColumn get callType => integer().withDefault(const Constant(0))();
  
  TextColumn get date => text()();
  TextColumn get time => text()();
  TextColumn get summary => text().nullable()();
  BoolColumn get isImportant => boolean().withDefault(const Constant(false))();
}