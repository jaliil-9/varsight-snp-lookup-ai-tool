import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/features/snp_search/notifiers/favourites_notifier.dart';
import 'package:varsight/features/snp_search/presentations/variant_full_report.dart';
import 'package:varsight/features/snp_search/providers/snp_provider.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(favouritesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favourites',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: favouritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data:
            (favourites) =>
                favourites.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.heart,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Favourites',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your saved search result will appear here.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: favourites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final dossier = favourites[index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.borderRadiusMd,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(Sizes.md),
                            leading: const Icon(Iconsax.document, size: 28),
                            title: Text(
                              dossier.snpData.rsId,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            subtitle: Text(dossier.snpData.gene),
                            trailing: IconButton(
                              icon: const Icon(Iconsax.heart_slash),
                              onPressed:
                                  () => ref
                                      .read(favouritesProvider.notifier)
                                      .removeFavourite(dossier.snpData.rsId),
                              tooltip: 'Remove from favourites',
                            ),
                            onTap: () async {
                              final notifier = ref.read(
                                snpDossierProvider.notifier,
                              );
                              final localDossier = await notifier
                                  .loadDossierLocally(dossier.snpData.rsId);
                              if (localDossier != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => VariantFullReport(
                                          dossier: localDossier,
                                        ),
                                  ),
                                );
                              } else {
                                await notifier.fetchDossier(
                                  dossier.snpData.rsId,
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
      ),
    );
  }
}
