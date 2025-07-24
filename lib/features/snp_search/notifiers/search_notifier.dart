import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/snp_search/models/search_state.dart';
import 'package:varsight/features/snp_search/models/search_step.dart';
import 'package:varsight/core/services/network.dart';

import 'package:varsight/features/snp_search/providers/snp_provider.dart';

class SearchNotifier extends AsyncNotifier<SearchState> {
  late final NetworkService _networkService;

  @override
  Future<SearchState> build() async {
    _networkService = ref.read(networkServiceProvider);
    return SearchState.initial();
  }

  Future<void> search(String rsId) async {
    final isConnected = await _networkService.isConnected();
    if (!isConnected) {
      state = AsyncValue.error('No internet connection', StackTrace.current);
      return;
    }

    // Use a Completer to signal when the background fetch is done
    final completer = Completer<void>();

    // Immediately start showing the stepper UI
    state = AsyncValue.data(SearchState.loading(SearchStep.geneInfo));

    // Run the actual fetch in the background
    _fetchDataInBackground(rsId, completer);

    // Update the stepper UI based on time, independent of the fetch
    await _updateStepper();

    // Wait for the background fetch to complete before finishing
    await completer.future;
  }

  Future<void> _updateStepper() async {
    await Future.delayed(const Duration(seconds: 2));
    if (state.value?.isLoading == true) {
      state = AsyncValue.data(SearchState.loading(SearchStep.literature));
    }

    await Future.delayed(const Duration(seconds: 3));
    if (state.value?.isLoading == true) {
      state = AsyncValue.data(SearchState.loading(SearchStep.synthesis));
    }
  }

  Future<void> _fetchDataInBackground(
    String rsId,
    Completer<void> completer,
  ) async {
    try {
      final repo = ref.read(snpRepositoryProvider);
      final dossier = await repo.fetchSnpDossier(rsId);

      // If the UI is still loading, update it with the success state
      if (state.value?.isLoading == true) {
        state = AsyncValue.data(SearchState.success(dossier));
      }
    } catch (e, st) {
      // If the UI is still loading, update it with the error state
      if (state.value?.isLoading == true) {
        state = AsyncValue.error(e, st);
      }
    } finally {
      // Signal that the background work is done
      completer.complete();
    }
  }

  void clear() {
    state = AsyncValue.data(SearchState.initial());
  }
}
