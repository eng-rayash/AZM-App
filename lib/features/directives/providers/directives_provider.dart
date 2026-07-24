import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../domain/directives_repository.dart';

/// Provider for all active directives
final directivesListProvider = StreamProvider<List<Directive>>((ref) {
  final repository = ref.watch(directivesRepositoryProvider);
  return repository.watchAll();
});