import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';
import 'package:varsight/features/snp_search/providers/snp_provider.dart';

class SnpDossierNotifier extends AsyncNotifier<VariantModel?> {
  @override
  Future<VariantModel?> build() async {
    // No initial fetch
    return null;
  }

  Future<bool> _ensureConnected() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveDossierLocally(VariantModel dossier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'dossier_${dossier.snpData.rsId}',
      jsonEncode(dossier.toJson()),
    );
  }

  Future<VariantModel?> loadDossierLocally(String rsId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('dossier_$rsId');
    if (jsonString != null) {
      return VariantModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  Future<void> fetchDossier(String rsId) async {
    state = const AsyncValue.loading();
    final isConnected = await _ensureConnected();
    if (!isConnected) {
      state = AsyncValue.error('No internet connection. Please check your network.', StackTrace.current);
      return;
    }
    try {
      final repo = ref.read(snpRepositoryProvider);
      final dossier = await repo.fetchSnpDossier(rsId);
      state = AsyncValue.data(dossier);
      await saveDossierLocally(dossier);
    } on SocketException {
      state = AsyncValue.error('No internet connection. Please check your network.', StackTrace.current);
    } on TimeoutException {
      state = AsyncValue.error('Request timed out. Please try again later.', StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred. Please try again.', st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
