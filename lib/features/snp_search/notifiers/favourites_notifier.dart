import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavouritesNotifier extends AsyncNotifier<List<VariantModel>> {
  static const _prefsKey = 'favourite_dossiers';

  @override
  Future<List<VariantModel>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? [];
    if (saved.isNotEmpty) {
      return saved.map((s) => VariantModel.fromJson(json.decode(s))).toList();
    }
    return [];
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final current =
        state is AsyncData<List<VariantModel>>
            ? (state as AsyncData<List<VariantModel>>).value
            : <VariantModel>[];
    await prefs.setStringList(
      _prefsKey,
      current.map((d) => json.encode(_toJson(d))).toList(),
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

  Map<String, dynamic> _toJson(VariantModel d) {
    // You may want to add a toJson method to VariantDossier for more robust serialization
    return {
      'snpData': {
        'rsId': d.snpData.rsId,
        'gene': d.snpData.gene,
        'clinicalSignificance': d.snpData.clinicalSignificance,
        'phenotypes': d.snpData.phenotypes,
      },
      'pubmedData': [], // Not persisted for brevity
      'gwasData': {
        'rsId': d.gwasData.rsId,
        'significantTraits': d.gwasData.significantTraits,
        'traitCount': d.gwasData.traitCount,
      },
      'aiSummary': d.aiSummary,
    };
  }
}

final favouritesProvider =
    AsyncNotifierProvider<FavouritesNotifier, List<VariantModel>>(
      FavouritesNotifier.new,
    );
