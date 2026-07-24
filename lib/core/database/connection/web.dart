// Web-only database connection — compiled ONLY when dart.library.html is available.
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor connectDb(String dbName) {
  return driftDatabase(
    name: dbName,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}