import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../domain/follow_ups_repository.dart';

/// Provider for all active follow-ups
final followUpsListProvider = StreamProvider<List<FollowUp>>((ref) {
  final repository = ref.watch(followUpsRepositoryProvider);
  return repository.watchAll();
});