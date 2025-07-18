import 'dart:async';
import 'dart:io';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/snp_search/models/search_state.dart';
import 'package:varsight/features/snp_search/providers/snp_provider.dart';
import 'package:varsight/core/services/network.dart';

class SearchNotifier extends AsyncNotifier<SearchState> {
  late final NetworkService _networkService;

  @override
  Future<SearchState> build() async {
    _networkService = ref.read(networkServiceProvider);
    return SearchState.initial();
  }

  Future<void> search(String rsId) async {
    state = await AsyncValue.guard(() async {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }

      // Step 1: Gene Information (2 seconds)
      final geneInfoState = SearchState.loading(SearchStep.geneInfo);
      state = AsyncValue.data(geneInfoState);
      await Future.delayed(const Duration(seconds: 2));

      // Step 2: Literature Analysis (2 seconds)
      final literatureState = SearchState.loading(SearchStep.literature);
      state = AsyncValue.data(literatureState);
      await Future.delayed(const Duration(seconds: 2));

      // Step 3: Results Synthesis (start showing, but continue until response is ready)
      final synthesisState = SearchState.loading(SearchStep.synthesis);
      state = AsyncValue.data(synthesisState);
      final startTime = DateTime.now();

      final repo = ref.read(snpRepositoryProvider);
      final dossier = await repo.fetchSnpDossier(rsId);

      // If the response came back in less than 3 seconds since starting step 3,
      // wait for the remaining time
      final elapsedTime = DateTime.now().difference(startTime);
      if (elapsedTime < const Duration(seconds: 3)) {
        await Future.delayed(const Duration(seconds: 3) - elapsedTime);
      }

      // Save the result
      final snpNotifier = ref.read(snpDossierProvider.notifier);
      await snpNotifier.saveDossierLocally(dossier);

      return SearchState.success(dossier);
    });
  }

  void clear() {
    state = AsyncValue.data(SearchState.initial());
  }
}
