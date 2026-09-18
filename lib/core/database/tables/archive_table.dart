import 'package:drift/drift.dart';

import 'base_table.dart';
import 'tenant_scoped.dart';

/// Archive table — stores metadata for important documents and records.
class Archive extends Table with BaseTableMixin, TenantScoped {
  /// Document title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Reference or document number (صادر / وارد)
  TextColumn get referenceNumber => text().nullable()();

  /// Date of the document in Hijri calendar
  TextColumn get hijriDate => text().nullable()();

  /// Date of the document in Gregorian calendar
  TextColumn get documentDate => text().nullable()();

  /// Directed entity / Destination
  TextColumn get directedEntity => text().nullable()();

  /// Category (e.g., Financial, Administrative, Secret / Memo Type)
  TextColumn get category => text().nullable()();

  /// Local file path for offline access
  TextColumn get localFilePath => text().nullable()();

  /// Comma-separated tags for fast search
  TextColumn get tags => text().nullable()();

  /// General memo notes
  TextColumn get notes => text().nullable()();
  
  /// Is highly confidential?
  BoolColumn get isConfidential => boolean().withDefault(const Constant(false))();
}