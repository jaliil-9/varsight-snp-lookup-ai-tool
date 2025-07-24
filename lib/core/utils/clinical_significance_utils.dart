class ClinicalSignificanceUtils {
  static String curateClinicalSignificance(String clinicalSignificance) {
    // Use official ACMG clinical significance terms
    const acmgTerms = [
      'Pathogenic',
      'Likely-pathogenic',
      'Uncertain-significance',
      'Likely-benign',
      'Benign',
      'risk-factor',
      'drug-response',
    ];

    final lower = clinicalSignificance.toLowerCase();
    final found = <String>{}; // Use Set to avoid duplicates

    for (final term in acmgTerms) {
      final termLower = term.toLowerCase();
      // Use word boundary matching with RegExp
      final pattern = RegExp(r'\b' + RegExp.escape(termLower) + r'\b');
      if (pattern.hasMatch(lower)) {
        found.add(term);
      }
    }

    return found.isEmpty ? clinicalSignificance : found.join(', ');
  }
}
