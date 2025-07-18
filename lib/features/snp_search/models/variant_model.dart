// Main dossier model
class VariantModel {
  final SnpData snpData;
  final List<PubmedArticle> pubmedData;
  final GwasData gwasData;
  final String aiSummary;

  VariantModel({
    required this.snpData,
    required this.pubmedData,
    required this.gwasData,
    required this.aiSummary,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      snpData: SnpData.fromJson(json['snp_data']),
      pubmedData: List<PubmedArticle>.from(
        json['pubmed_data'].map((x) => PubmedArticle.fromJson(x)),
      ),
      gwasData: GwasData.fromJson(json['gwas_data']),
      aiSummary: json['ai_summary'],
    );
  }

  Map<String, dynamic> toJson() => {
    'snp_data': snpData.toJson(),
    'pubmed_data': pubmedData.map((x) => x.toJson()).toList(),
    'gwas_data': gwasData.toJson(),
    'ai_summary': aiSummary,
  };
}

// Sub-models
class SnpData {
  final String rsId;
  final String gene;
  final String clinicalSignificance;
  final List<String> phenotypes;

  SnpData({
    required this.rsId,
    required this.gene,
    required this.clinicalSignificance,
    required this.phenotypes,
  });

  factory SnpData.fromJson(Map<String, dynamic> json) {
    return SnpData(
      rsId: json['rs_id'] ?? 'not specified',
      gene: json['gene'] ?? 'not specified',
      clinicalSignificance: json['clinical_significance'] ?? 'not specified',
      phenotypes: List<String>.from(json['phenotypes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'rs_id': rsId,
    'gene': gene,
    'clinical_significance': clinicalSignificance,
    'phenotypes': phenotypes,
  };
}

class PubmedArticle {
  final String pmid;
  final String title;
  final String journal;
  final String authors;
  final String year;
  final String url;

  PubmedArticle({
    required this.pmid,
    required this.title,
    required this.journal,
    required this.authors,
    required this.year,
    required this.url,
  });

  factory PubmedArticle.fromJson(Map<String, dynamic> json) {
    return PubmedArticle(
      pmid: json['pmid'] ?? 'not specified',
      title: json['title'] ?? 'not specified',
      journal: json['journal'] ?? 'not specified',
      authors: json['authors'] ?? 'not specified',
      year: json['year'] ?? 'not specified',
      url: json['url'] ?? 'not specified',
    );
  }

  Map<String, dynamic> toJson() => {
    'pmid': pmid,
    'title': title,
    'journal': journal,
    'authors': authors,
    'year': year,
    'url': url,
  };
}

class GwasData {
  final String rsId;
  final List<String> significantTraits;
  final int traitCount;

  GwasData({
    required this.rsId,
    required this.significantTraits,
    required this.traitCount,
  });

  factory GwasData.fromJson(Map<String, dynamic> json) {
    return GwasData(
      rsId: json['rs_id'],
      significantTraits: List<String>.from(json['significant_traits']),
      traitCount: json['trait_count'] ?? 'not specified',
    );
  }

  Map<String, dynamic> toJson() => {
    'rs_id': rsId,
    'significant_traits': significantTraits,
    'trait_count': traitCount,
  };
}
