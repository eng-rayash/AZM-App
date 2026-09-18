import 'package:drift/drift.dart';
import 'base_table.dart';
import 'tenant_scoped.dart';

/// أنواع الكيانات في الربط الشامل معرَّفة في `EntityLinkType`
/// داخل `core/constants/enums.dart` — وهي المرجع الوحيد.
///
/// كان السرد هنا نسخةً ثانية من الترقيم تتخلّف عن التعداد.

/// Universal Entity Links table.
///
/// Allows ANY record to be linked to ANY other record.
/// This powers the "Smart Relations" feature across all modules.
class EntityLinks extends Table with BaseTableMixin, TenantScoped {
  /// Source entity type (see enum above)
  IntColumn get sourceType => integer()();

  /// Source entity ID
  IntColumn get sourceId => integer()();

  /// Target entity type (see enum above)
  IntColumn get targetType => integer()();

  /// Target entity ID
  IntColumn get targetId => integer()();

  /// Optional: description of the relationship
  TextColumn get relation => text().nullable()();

  /// Optional: cached label of source (for display without extra query)
  TextColumn get sourceLabel => text().nullable()();

  /// Optional: cached label of target (for display without extra query)
  TextColumn get targetLabel => text().nullable()();

  /// Who created this link
  @override
  TextColumn get createdBy => text().nullable()();
}