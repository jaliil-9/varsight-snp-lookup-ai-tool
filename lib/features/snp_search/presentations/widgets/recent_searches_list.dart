import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/features/snp_search/notifiers/recent_searches_notifier.dart';
import 'package:varsight/features/snp_search/presentations/search_history_screen.dart';
import 'package:varsight/features/snp_search/presentations/variant_full_report.dart';
import 'package:varsight/features/snp_search/providers/snp_provider.dart';

class RecentSearchesList extends ConsumerWidget {
  const RecentSearchesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final recentSearches = ref.watch(recentSearchesProvider);
    return recentSearches.when(
      data: (recentSearchesList) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.spaceBtwSections),
            if (recentSearchesList.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Recently searched',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchHistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            if (recentSearchesList.isNotEmpty)
              ListView.builder(
                itemCount: recentSearchesList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final rsId = recentSearchesList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Sizes.sm),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Sizes.borderRadiusLg,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: Sizes.sm,
                          horizontal: Sizes.md,
                        ),
                        title: Row(
                          children: [
                            Text(
                              rsId,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color:
                              isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                        ),
                        onTap: () async {
                          final notifier = ref.read(
                            snpDossierProvider.notifier,
                          );
                          final dossier = await notifier.loadDossierLocally(
                            rsId,
                          );
                          if (dossier != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        VariantFullReport(dossier: dossier),
                              ),
                            );
                          } else {
                            await notifier.fetchDossier(rsId);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
    );
  }
}
