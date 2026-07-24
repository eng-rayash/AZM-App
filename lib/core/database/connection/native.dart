// Native-only database connection — compiled ONLY when dart.library.io is available.
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor connectDb(String dbName) {
  return driftDatabase(name: dbName);
}