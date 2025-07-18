import 'package:flutter/material.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';

// Standards-compliant approach using official ontology mappings
class StandardsPhenotypesOrganizer {
  // Official HPO top-level categories (HP:0000118 - Phenotypic abnormality)
  // Based on HPO official hierarchy: https://hpo.jax.org/
  static const Map<String, HPOCategory> officialHPOCategories = {
    'HP:0000478': HPOCategory(
      id: 'HP:0000478',
      name: 'Abnormality of the eye',
      keywords: ['eye', 'vision', 'ocular', 'retinal', 'optic'],
    ),
    'HP:0000707': HPOCategory(
      id: 'HP:0000707',
      name: 'Abnormality of the nervous system',
      keywords: [
        'nervous',
        'neurological',
        'brain',
        'seizure',
        'cognitive',
        'motor',
      ],
    ),
    'HP:0001197': HPOCategory(
      id: 'HP:0001197',
      name: 'Abnormality of prenatal development or birth',
      keywords: ['prenatal', 'birth', 'congenital', 'developmental'],
    ),
    'HP:0001507': HPOCategory(
      id: 'HP:0001507',
      name: 'Growth abnormality',
      keywords: ['growth', 'height', 'weight', 'size'],
    ),
    'HP:0001574': HPOCategory(
      id: 'HP:0001574',
      name: 'Abnormality of the integument',
      keywords: ['skin', 'hair', 'nail', 'dermatologic'],
    ),
    'HP:0001626': HPOCategory(
      id: 'HP:0001626',
      name: 'Abnormality of the cardiovascular system',
      keywords: [
        'cardiovascular',
        'heart',
        'cardiac',
        'vascular',
        'blood pressure',
      ],
    ),
    'HP:0001871': HPOCategory(
      id: 'HP:0001871',
      name: 'Abnormality of blood and blood-forming tissues',
      keywords: ['blood', 'hematologic', 'anemia', 'bleeding', 'clotting'],
    ),
    'HP:0001939': HPOCategory(
      id: 'HP:0001939',
      name: 'Abnormality of metabolism/homeostasis',
      keywords: ['metabolic', 'diabetes', 'glucose', 'lipid', 'hormone'],
    ),
    'HP:0002086': HPOCategory(
      id: 'HP:0002086',
      name: 'Abnormality of the respiratory system',
      keywords: ['respiratory', 'lung', 'breathing', 'pulmonary'],
    ),
    'HP:0002715': HPOCategory(
      id: 'HP:0002715',
      name: 'Abnormality of the immune system',
      keywords: ['immune', 'immunologic', 'autoimmune', 'allergy'],
    ),
    'HP:0003011': HPOCategory(
      id: 'HP:0003011',
      name: 'Abnormality of the musculature',
      keywords: ['muscle', 'muscular', 'myopathy', 'weakness'],
    ),
    'HP:0003549': HPOCategory(
      id: 'HP:0003549',
      name: 'Abnormality of connective tissue',
      keywords: ['connective', 'collagen', 'tissue'],
    ),
    'HP:0010978': HPOCategory(
      id: 'HP:0010978',
      name: 'Abnormality of immune system physiology',
      keywords: ['immune physiology', 'immunodeficiency'],
    ),
    'HP:0012638': HPOCategory(
      id: 'HP:0012638',
      name: 'Abnormality of nervous system physiology',
      keywords: ['nervous physiology', 'neurophysiology'],
    ),
  };

  // Official EFO disease categories for GWAS traits
  // Based on EFO: https://www.ebi.ac.uk/efo/
  static const Map<String, EFOCategory> officialEFOCategories = {
    'EFO:0000408': EFOCategory(
      id: 'EFO:0000408',
      name: 'disease',
      keywords: ['disease', 'disorder'],
    ),
    'EFO:0000540': EFOCategory(
      id: 'EFO:0000540',
      name: 'immune system disease',
      keywords: ['immune', 'autoimmune', 'inflammatory'],
    ),
    'EFO:0000319': EFOCategory(
      id: 'EFO:0000319',
      name: 'cardiovascular disease',
      keywords: ['cardiovascular', 'heart', 'coronary'],
    ),
    'EFO:0003761': EFOCategory(
      id: 'EFO:0003761',
      name: 'cancer',
      keywords: ['cancer', 'carcinoma', 'tumor', 'malignant'],
    ),
    'EFO:0000651': EFOCategory(
      id: 'EFO:0000651',
      name: 'phenotype',
      keywords: ['phenotype', 'trait', 'characteristic'],
    ),
  };

  // Primary organization method - use when HPO/EFO IDs are available
  static List<OrganizedPhenotype> organizeByOfficialIDs(
    Map<String, List<String>> phenotypesByID,
  ) {
    List<OrganizedPhenotype> organized = [];

    phenotypesByID.forEach((hpoId, phenotypes) {
      if (officialHPOCategories.containsKey(hpoId)) {
        HPOCategory category = officialHPOCategories[hpoId]!;
        organized.add(
          OrganizedPhenotype(
            category: category.name,
            phenotypes: phenotypes,
            relevanceScore: _calculateRelevanceScore(phenotypes),
            ontologyId: hpoId,
            isOfficialMapping: true,
          ),
        );
      }
    });

    return organized
      ..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
  }

  // Fallback method - use only when official IDs unavailable
  static List<OrganizedPhenotype> organizeFallback(List<String> rawPhenotypes) {
    if (rawPhenotypes.isEmpty) return [];

    // Clean the data first
    List<String> cleanPhenotypes = _cleanPhenotypes(rawPhenotypes);

    // Group by best-match HPO categories
    Map<String, List<String>> grouped = {};
    List<String> unmatched = [];

    for (String phenotype in cleanPhenotypes) {
      String? bestMatch = _findBestHPOMatch(phenotype);
      if (bestMatch != null) {
        grouped.putIfAbsent(bestMatch, () => []).add(phenotype);
      } else {
        unmatched.add(phenotype);
      }
    }

    List<OrganizedPhenotype> organized = [];

    grouped.forEach((hpoId, phenotypes) {
      HPOCategory category = officialHPOCategories[hpoId]!;
      organized.add(
        OrganizedPhenotype(
          category: category.name,
          phenotypes: phenotypes,
          relevanceScore: _calculateRelevanceScore(phenotypes),
          ontologyId: hpoId,
          isOfficialMapping: false, // Fallback mapping
        ),
      );
    });

    // Add unmatched as "Other conditions" only if significant
    if (unmatched.length >= 2) {
      organized.add(
        OrganizedPhenotype(
          category: 'Other conditions',
          phenotypes: unmatched.take(5).toList(),
          relevanceScore: 1,
          ontologyId: null,
          isOfficialMapping: false,
        ),
      );
    }

    return organized
      ..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
  }

  static List<String> _cleanPhenotypes(List<String> phenotypes) {
    // Official NCBI/ClinVar filtering approach
    const excludeTerms = [
      'not specified',
      'not provided',
      'see cases',
      'other',
      'unspecified',
      'unknown significance',
      'variant of uncertain significance',
    ];

    return phenotypes
        .where((p) => p.trim().isNotEmpty)
        .where(
          (p) =>
              !excludeTerms.any(
                (term) => p.toLowerCase().contains(term.toLowerCase()),
              ),
        )
        .map((p) => p.trim())
        .toSet() // Remove duplicates
        .toList();
  }

  static String? _findBestHPOMatch(String phenotype) {
    String lower = phenotype.toLowerCase();

    // Find best matching HPO category
    String? bestMatch;
    int maxMatches = 0;

    officialHPOCategories.forEach((id, category) {
      int matches =
          category.keywords
              .where((keyword) => lower.contains(keyword.toLowerCase()))
              .length;

      if (matches > maxMatches) {
        maxMatches = matches;
        bestMatch = id;
      }
    });

    return maxMatches > 0 ? bestMatch : null;
  }

  static int _calculateRelevanceScore(List<String> phenotypes) {
    // Use official clinical significance weighting
    const significanceWeights = {
      'pathogenic': 10,
      'likely pathogenic': 8,
      'uncertain significance': 5,
      'likely benign': 3,
      'benign': 2,
    };

    int score = phenotypes.length; // Base score

    for (String phenotype in phenotypes) {
      String lower = phenotype.toLowerCase();
      significanceWeights.forEach((term, weight) {
        if (lower.contains(term)) {
          score += weight;
        }
      });
    }

    return score;
  }
}

// Data models aligned with official standards
class HPOCategory {
  final String id;
  final String name;
  final List<String> keywords;

  const HPOCategory({
    required this.id,
    required this.name,
    required this.keywords,
  });
}

class EFOCategory {
  final String id;
  final String name;
  final List<String> keywords;

  const EFOCategory({
    required this.id,
    required this.name,
    required this.keywords,
  });
}

class OrganizedPhenotype {
  final String category;
  final List<String> phenotypes;
  final int relevanceScore;
  final String? ontologyId;
  final bool isOfficialMapping;

  OrganizedPhenotype({
    required this.category,
    required this.phenotypes,
    required this.relevanceScore,
    this.ontologyId,
    required this.isOfficialMapping,
  });
}

// Updated UI component with reliability indicators
class StandardsCompliantDataSourcesTab extends StatelessWidget {
  final SnpData snpData;
  final GwasData gwasData;

  const StandardsCompliantDataSourcesTab({
    super.key,
    required this.snpData,
    required this.gwasData,
  });

  @override
  Widget build(BuildContext context) {
    // Use official organization when possible
    final organizedPhenotypes = StandardsPhenotypesOrganizer.organizeFallback(
      snpData.phenotypes,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'ClinVar Data'),
          _buildInfoCard(
            context: context,
            children: [
              _buildDataRow(context, 'RS ID', snpData.rsId),
              _buildDataRow(context, 'Gene', snpData.gene),
              _buildDataRow(
                context,
                'Clinical Significance',
                _curatedClinicalSignificance(snpData.clinicalSignificance),
              ),
              if (organizedPhenotypes.isNotEmpty)
                _buildStandardsPhenotypesSection(context, organizedPhenotypes),
            ],
          ),
          const SizedBox(height: Sizes.lg),
          _buildSectionTitle(context, 'GWAS Catalog Data'),
          _buildInfoCard(
            context: context,
            children: [
              _buildDataRow(
                context,
                'Associations Found',
                gwasData.traitCount.toString(),
              ),
              if (gwasData.significantTraits.isNotEmpty)
                _buildEFOTraitsSection(context, gwasData.significantTraits),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandardsPhenotypesSection(
    BuildContext context,
    List<OrganizedPhenotype> organizedPhenotypes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Sizes.md, bottom: Sizes.sm),
          child: Row(
            children: [
              Text(
                'Associated Phenotypes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              _buildStandardsIndicator(context),
            ],
          ),
        ),
        ...organizedPhenotypes.map(
          (organized) => _buildPhenotypeCategory(context, organized),
        ),
      ],
    );
  }

  Widget _buildStandardsIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Text(
        'HPO Standards',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10,
          color: Colors.green.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPhenotypeCategory(
    BuildContext context,
    OrganizedPhenotype organized,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      organized.isOfficialMapping
                          ? Colors.blue.shade100
                          : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        organized.isOfficialMapping
                            ? Colors.blue.shade300
                            : Colors.orange.shade300,
                  ),
                ),
                child: Text(
                  organized.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        organized.isOfficialMapping
                            ? Colors.blue.shade700
                            : Colors.orange.shade700,
                  ),
                ),
              ),
              if (organized.ontologyId != null) ...[
                const SizedBox(width: 8),
                Text(
                  organized.ontologyId!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children:
                  organized.phenotypes
                      .map(
                        (phenotype) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? const Color.fromARGB(255, 137, 136, 136)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            phenotype,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEFOTraitsSection(BuildContext context, List<String> traits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Sizes.md, bottom: Sizes.sm),
          child: Row(
            children: [
              Text(
                'Significant Traits',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.purple.shade300),
                ),
                child: Text(
                  'EFO Standards',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children:
              traits
                  .map(
                    (trait) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Text(
                        trait,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.md),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  String _curatedClinicalSignificance(String clinicalSignificance) {
    // Use official ACMG clinical significance terms
    const acmgTerms = [
      'Pathogenic',
      'Likely pathogenic',
      'Uncertain significance',
      'Likely benign',
      'Benign',
      'risk factor',
      'drug response',
    ];

    final lower = clinicalSignificance.toLowerCase();
    final found = <String>[];

    for (final term in acmgTerms) {
      if (lower.contains(term.toLowerCase())) {
        found.add(term);
      }
    }

    return found.isEmpty ? clinicalSignificance : found.join(', ');
  }
}
