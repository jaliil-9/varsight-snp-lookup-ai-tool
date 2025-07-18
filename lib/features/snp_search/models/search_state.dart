import 'package:flutter/material.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';

enum SearchStep {
  geneInfo('Fetching gene information'),
  literature('Analyzing research literature'),
  synthesis('Synthesizing results');

  final String label;
  const SearchStep(this.label);
}

@immutable
class SearchState {
  final bool isLoading;
  final String? error;
  final VariantModel? dossier;
  final SearchStep? currentStep;
  final DateTime? stepStartTime;

  const SearchState({
    this.isLoading = false,
    this.error,
    this.dossier,
    this.currentStep,
    this.stepStartTime,
  });

  SearchState copyWith({
    bool? isLoading,
    String? error,
    VariantModel? dossier,
    SearchStep? currentStep,
    DateTime? stepStartTime,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dossier: dossier ?? this.dossier,
      currentStep: currentStep,
      stepStartTime: stepStartTime ?? this.stepStartTime,
    );
  }

  factory SearchState.initial() {
    return const SearchState();
  }

  factory SearchState.loading(SearchStep step) {
    return SearchState(
      isLoading: true,
      currentStep: step,
      stepStartTime: DateTime.now(),
    );
  }

  factory SearchState.error(String message) {
    return SearchState(error: message, isLoading: false);
  }

  factory SearchState.success(VariantModel dossier) {
    return SearchState(isLoading: false, dossier: dossier);
  }
}
