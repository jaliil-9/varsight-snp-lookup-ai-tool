import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/utils/storage.dart';

class RecentSearchesNotifier extends Notifier<List<String>> {
  static const _prefsKey = 'recent_searches';

  @override
  List<String> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final saved =
        JLocalStorage.instance().readData<List<String>>(_prefsKey) ?? [];
    if (saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> _saveToPrefs() async {
    await JLocalStorage.instance().saveData(_prefsKey, state);
  }

  void addSearch(String rsId) {
    if (rsId.isEmpty) return;
    // Remove duplicates and maintain order
    if (state.contains(rsId)) {
      state = state.where((id) => id != rsId).toList();
    }
    // Add the new search at the start
    // Limit to the last 10 searches
    if (state.length >= 10) {
      state.removeLast();
    }
    // Add the new search at the start
    state = [rsId, ...state.where((id) => id != rsId)].take(10).toList();
    _saveToPrefs();
  }

  void removeSearch(String rsId) {
    state = state.where((id) => id != rsId).toList();
    _saveToPrefs();
  }

  void clearAll() {
    state = [];
    _saveToPrefs();
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
      RecentSearchesNotifier.new,
    );
