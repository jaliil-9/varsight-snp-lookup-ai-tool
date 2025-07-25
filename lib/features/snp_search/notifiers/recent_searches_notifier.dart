import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/utils/storage.dart';

class RecentSearchesNotifier extends AsyncNotifier<List<String>> {
  static const _prefsKey = 'recent_searches';

  @override
  Future<List<String>> build() async {
    return _loadFromPrefs();
  }

  Future<List<String>> _loadFromPrefs() async {
    final saved =
        JLocalStorage.instance().readData<List<String>>(_prefsKey) ?? [];
    return saved;
  }

  Future<void> _saveToPrefs() async {
    await JLocalStorage.instance().saveData(_prefsKey, state);
  }

  void addSearch(String rsId) {
    if (rsId.isEmpty) return;
    state.whenData((currentList) {
      final newList = [rsId, ...currentList.where((id) => id != rsId)].take(10).toList();
      state = AsyncValue.data(newList);
      _saveToPrefs();
    });
  }

  void removeSearch(String rsId) {
    state.whenData((currentList) {
      final newList = currentList.where((id) => id != rsId).toList();
      state = AsyncValue.data(newList);
      _saveToPrefs();
    });
  }

  void clearAll() {
    state = const AsyncValue.data([]);
    _saveToPrefs();
  }
}

final recentSearchesProvider =
    AsyncNotifierProvider<RecentSearchesNotifier, List<String>>(
      RecentSearchesNotifier.new,
    );
