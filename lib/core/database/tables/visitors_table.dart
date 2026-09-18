import 'package:drift/drift.dart';
import 'base_table.dart';
import 'tenant_scoped.dart';

/// Visitors Table — Phase 4
/// Manages visitor access to the executive office.
@DataClassName('VisitorItem')
class Visitors extends Table with BaseTableMixin, TenantScoped {
  TextColumn get visitorName => text()();
  TextColumn get company => text().nullable()();
  TextColumn get purpose => text().nullable()();
  
  TextColumn get appointmentId => text().nullable()();
  
  TextColumn get entryTime => text().nullable()();
  TextColumn get exitTime => text().nullable()();
  
  /// 0: Waiting, 1: Inside, 2: Left
  IntColumn get status => integer().withDefault(const Constant(0))();
}