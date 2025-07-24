enum SearchStep {
  geneInfo,
  literature,
  synthesis;

  String get label {
    switch (this) {
      case SearchStep.geneInfo:
        return 'Gathering data';
      case SearchStep.literature:
        return 'Analyzing literature';
      case SearchStep.synthesis:
        return 'Generating insights';
    }
  }
}
