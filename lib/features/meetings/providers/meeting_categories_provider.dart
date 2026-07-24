import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'meeting_categories_provider.g.dart';

const _kMeetingCategoriesKey = 'meeting_categories_list';

final _defaultCategories = [
  'عام',
  'إداري',
  'طارئ',
  'مراجعة',
  'تخطيط',
  'متابعة',
  'استثنائي',
];

@riverpod
class MeetingCategories extends _$MeetingCategories {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_kMeetingCategoriesKey);
    
    if (savedList != null && savedList.isNotEmpty) {
      return savedList;
    }
    
    // Save defaults if empty
    await prefs.setStringList(_kMeetingCategoriesKey, _defaultCategories);
    return _defaultCategories;
  }

  Future<void> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;

    final currentState = state.value ?? _defaultCategories;
    
    // If it already exists (case-insensitive), do not add
    if (currentState.any((e) => e.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }

    final newList = List<String>.from(currentState)..add(trimmed);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kMeetingCategoriesKey, newList);
    
    state = AsyncData(newList);
  }

  Future<void> removeCategory(String category) async {
    final currentState = state.value ?? _defaultCategories;
    final newList = currentState.where((e) => e != category).toList();
    
    // Fallback: don't let it be completely empty, restore defaults
    if (newList.isEmpty) {
      newList.addAll(_defaultCategories);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kMeetingCategoriesKey, newList);
    
    state = AsyncData(newList);
  }
}