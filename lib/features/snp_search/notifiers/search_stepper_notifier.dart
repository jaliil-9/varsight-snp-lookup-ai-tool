import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/snp_search/models/search_state.dart';

class SearchStepperNotifier extends StateNotifier<SearchState> {
  SearchStepperNotifier() : super(SearchState.initial());

  void nextStep() {
    if (!state.isLoading || state.currentStep == null) return;

    switch (state.currentStep!) {
      case SearchStep.geneInfo:
        state = SearchState.loading(SearchStep.literature);
        break;
      case SearchStep.literature:
        state = SearchState.loading(SearchStep.synthesis);
        break;
      case SearchStep.synthesis:
        break;
    }
  }

  void startSearch() {
    state = SearchState.loading(SearchStep.geneInfo);
  }

  void complete(dynamic result) {
    if (result is String) {
      state = SearchState.error(result);
    } else {
      state = SearchState.success(result);
    }
  }

  void reset() {
    state = SearchState.initial();
  }
}

final searchStepperProvider =
    StateNotifierProvider<SearchStepperNotifier, SearchState>((ref) {
      return SearchStepperNotifier();
    });
