import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../domain/tasks_repository.dart';

/// Provider for all active tasks
final tasksListProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.watchAll();
});

/// Provider for a single task by ID
final taskDetailProvider = StreamProvider.family<Task?, int>((ref, id) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.watchById(id);
});