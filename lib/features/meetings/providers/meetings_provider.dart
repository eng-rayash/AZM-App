import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../domain/meetings_repository.dart';

/// Provider for all active meetings
final meetingsListProvider = StreamProvider<List<Meeting>>((ref) {
  final repository = ref.watch(meetingsRepositoryProvider);
  return repository.watchAll();
});

/// Provider for today's meetings (used in dashboard)
final todayMeetingsProvider = StreamProvider<List<Meeting>>((ref) {
  final repository = ref.watch(meetingsRepositoryProvider);
  return repository.watchToday();
});

/// Provider for upcoming meetings (used in dashboard)
final upcomingMeetingsProvider = StreamProvider<List<Meeting>>((ref) {
  final repository = ref.watch(meetingsRepositoryProvider);
  return repository.watchUpcoming();
});

/// Provider for a single meeting by ID
final meetingDetailProvider = StreamProvider.family<Meeting?, int>((ref, id) {
  final repository = ref.watch(meetingsRepositoryProvider);
  return repository.watchById(id);
});