import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/utils/error.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/core/utils/clinical_significance_utils.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';
import 'package:varsight/features/snp_search/notifiers/favourites_notifier.dart';
import 'package:varsight/features/snp_search/notifiers/recent_searches_notifier.dart';
import 'package:varsight/features/snp_search/presentations/variant_full_report.dart';
import 'package:varsight/features/snp_search/presentations/widgets/info_chip.dart';
import 'package:varsight/features/snp_search/providers/snp_provider.dart';

class VariantSummaryCard extends ConsumerWidget {
  final SnpData snpData;
  final bool showViewFullResultButton;

  const VariantSummaryCard({
    super.key,
    required this.snpData,
    this.showViewFullResultButton = false,
  });

  Color _getSignificanceColor(String significance) {
    switch (significance.toLowerCase()) {
      case 'benign':
        return AppColors.success;
      case 'pathogenic':
        return Colors.redAccent;
      case 'risk factor':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getSignificanceIcon(String significance) {
    switch (significance.toLowerCase()) {
      case 'benign':
        return Icons.check_circle_outline;
      case 'pathogenic':
        return Icons.warning_amber_rounded;
      case 'risk factor':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final favouritesAsync = ref.watch(favouritesProvider);
    final isFavourite = favouritesAsync.maybeWhen(
      data:
          (favourites) => favourites.any(
            (d) =>
                d.snpData.rsId.trim().toLowerCase() ==
                snpData.rsId.trim().toLowerCase(),
          ),
      orElse: () => false,
    );
    return Container(
      padding: const EdgeInsets.all(Sizes.md),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? AppColors.backgroundDark.withValues(alpha: 0.1)
                    : AppColors.backgroundLight.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snpData.rsId,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color:
                      isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                ),
              ),
              TweenAnimationBuilder(
                tween: Tween<double>(
                  begin: isFavourite ? 1.2 : 1.0,
                  end: isFavourite ? 1.0 : 1.2,
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: IconButton(
                  icon: Icon(
                    isFavourite ? Iconsax.heart5 : Iconsax.heart,
                    color:
                        isFavourite
                            ? Colors.red
                            : isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                    size: isFavourite ? 32 : 24,
                  ),
                  onPressed: () {
                    final notifier = ref.read(favouritesProvider.notifier);
                    if (isFavourite) {
                      notifier.removeFavourite(snpData.rsId);
                      ErrorUtils.showInfoSnackBar('Removed from favourites');
                    } else {
                      // Try to get the full dossier from snpDossierProvider, fallback to minimal
                      final dossier = ref.read(snpDossierProvider).value;
                      if (dossier != null &&
                          dossier.snpData.rsId.trim().toLowerCase() ==
                              snpData.rsId.trim().toLowerCase()) {
                        notifier.addFavourite(dossier);
                      } else {
                        // Fallback: create a minimal VariantModel with only snpData
                        notifier.addFavourite(
                          VariantModel(
                            snpData: snpData,
                            pubmedData: [],
                            gwasData: GwasData(
                              rsId: snpData.rsId,
                              significantTraits: [],
                              traitCount: 0,
                            ),
                            aiSummary: '',
                          ),
                        );
                      }
                      ErrorUtils.showSuccessSnackBar('Added to favourites');
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: Sizes.sm),
          const Divider(),
          const SizedBox(height: Sizes.sm),
          Wrap(
            spacing: Sizes.sm,
            runSpacing: Sizes.sm,
            children: [
              InfoChip(
                label: "${snpData.gene} gene",
                icon: Icons.biotech_outlined,
                color:
                    isDarkMode ? AppColors.accentDark : AppColors.accentLight,
              ),
              if (showViewFullResultButton)
                InfoChip(
                  label: _curatedClinicalSignificance(
                    snpData.clinicalSignificance,
                  ),
                  icon: _getSignificanceIcon(snpData.clinicalSignificance),
                  color: _getSignificanceColor(snpData.clinicalSignificance),
                ),
              // Show a chip for total results (pubmed articles + 3 sources)
              if (showViewFullResultButton)
                Builder(
                  builder: (context) {
                    final searchStateAsync = ref.watch(searchProvider);
                    return searchStateAsync.when(
                      data: (searchState) {
                        final pubmedCount =
                            searchState.dossier?.pubmedData.length ?? 0;
                        final total =
                            pubmedCount + 3; // ClinVar, dbSNP, GWAS Catalog
                        return InfoChip(
                          label: "$total results found for this SNP",
                          icon: Icons.analytics_outlined,
                          color:
                              isDarkMode
                                  ? AppColors.secondaryDark
                                  : AppColors.secondaryLight,
                        );
                      },
                      loading:
                          () => InfoChip(
                            label: "Loading...",
                            icon: Icons.hourglass_empty,
                            color:
                                isDarkMode
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight,
                          ),
                      error:
                          (error, stack) => const InfoChip(
                            label: "Error",
                            icon: Icons.error_outline,
                            color: AppColors.error,
                          ),
                    );
                  },
                ),
            ],
          ),
          if (showViewFullResultButton)
            Column(
              children: [
                const SizedBox(height: Sizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    ElevatedButton(
                      onPressed: () {
                        // Use the new search state provider for the dossier
                        final searchState = ref.read(searchProvider).value;
                        if (searchState != null) {
                          final dossier = searchState.dossier;
                          if (dossier != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        VariantFullReport(dossier: dossier),
                              ),
                            );
                            // Optionally clear the search state or keep as needed
                            // Add to recent searches immediately
                            ref
                                .read(recentSearchesProvider.notifier)
                                .addSearch(dossier.snpData.rsId);
                          }
                        }
                      },
                      child: const Text('View full result'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _curatedClinicalSignificance(String clinicalSignificance) {
    return ClinicalSignificanceUtils.curateClinicalSignificance(
      clinicalSignificance,
    );
  }
}
