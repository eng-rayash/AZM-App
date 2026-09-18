// Entrypoint compiled to `web/drift_worker.js`.
//
// Drift's web backend runs SQLite inside a web worker. `driftDatabase(...)` in
// lib/core/database/connection/web.dart points at the compiled output of this
// file; without it every query stream hangs forever on the web target.
//
// Rebuild with:
//   dart compile js -O2 -o web/drift_worker.js tool/drift_worker_entry.dart
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
