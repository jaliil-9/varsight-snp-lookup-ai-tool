import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';
import 'package:varsight/core/utils/storage.dart';
import 'dart:convert';

class FavouritesNotifier extends AsyncNotifier<List<VariantModel>> {
  static const _prefsKey = 'favourite_dossiers';

  @override
  Future<List<VariantModel>> build() async {
    final saved = JLocalStorage.instance().readData<List<String>>(_prefsKey) ?? [];
    if (saved.isNotEmpty) {
      return saved.map((s) => VariantModel.fromJson(json.decode(s))).toList();
    }
    return [];
  }

  Future<void> _saveToPrefs() async {
    final current =
        state is AsyncData<List<VariantModel>>
            ? (state as AsyncData<List<VariantModel>>).value
            : <VariantModel>[];
    await JLocalStorage.instance().saveData(
      _prefsKey,
      current.map((d) => json.encode(d.toJson())).toList(),
    );
  }

  void addFavourite(VariantModel dossier) {
    final current =
        state is AsyncData<List<VariantModel>>
            ? (state as AsyncData<List<VariantModel>>).value
            : <VariantModel>[];
    if (!current.any((d) => d.snpData.rsId == dossier.snpData.rsId)) {
      final updated = [...current, dossier];
      state = AsyncData(updated);
      _saveToPrefs();
    }
  }

  void removeFavourite(String rsId) {
    final current =
        state is AsyncData<List<VariantModel>>
            ? (state as AsyncData<List<VariantModel>>).value
            : <VariantModel>[];
    final updated = current.where((d) => d.snpData.rsId != rsId).toList();
    state = AsyncData(updated);
    _saveToPrefs();
  }

  bool isFavourite(String rsId) {
    final current =
        state is AsyncData<List<VariantModel>>
            ? (state as AsyncData<List<VariantModel>>).value
            : <VariantModel>[];
    return current.any((d) => d.snpData.rsId == rsId);
  }

  
}

final favouritesProvider =
    AsyncNotifierProvider<FavouritesNotifier, List<VariantModel>>(
      FavouritesNotifier.new,
    );
