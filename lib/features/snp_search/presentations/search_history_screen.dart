import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/features/snp_search/notifiers/recent_searches_notifier.dart';
import 'package:varsight/features/snp_search/presentations/variant_full_report.dart';
import 'package:varsight/features/snp_search/providers/snp_provider.dart';

class SearchHistoryScreen extends ConsumerStatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  ConsumerState<SearchHistoryScreen> createState() =>
      _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends ConsumerState<SearchHistoryScreen> {
  final Set<String> _selected = {};

  Color _getSignificanceColor(String significance) {
    switch (significance.toLowerCase()) {
      case 'benign':
        return AppColors.success;
      case 'pathogenic':
        return AppColors.error;
      case 'risk factor':
        return AppColors.warning;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);
    final notifier = ref.read(recentSearchesProvider.notifier);
    final dossierNotifier = ref.read(snpDossierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Search History')),
        actions: [
          if (_selected.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected',
              onPressed: () {
                for (final rsId in _selected) {
                  notifier.removeSearch(rsId);
                }
                setState(() => _selected.clear());
              },
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: recentSearches.length,
        itemBuilder: (context, index) {
          final rsId = recentSearches[index];
          return FutureBuilder(
            future: dossierNotifier.loadDossierLocally(rsId),
            builder: (context, snapshot) {
              final dossier = snapshot.data;
              final gene = dossier?.snpData.gene ?? 'Unknown gene';
              final significance = dossier?.snpData.clinicalSignificance ?? '';
              final color = _getSignificanceColor(significance);
              final isSelected = _selected.contains(rsId);
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.primaryLight
                            : Theme.of(context).dividerColor.withAlpha(60),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                  onTap: () async {
                    final dossier = snapshot.data;
                    if (dossier != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => VariantFullReport(dossier: dossier),
                        ),
                      );
                    } else {
                      await dossierNotifier.fetchDossier(rsId);
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(rsId);
                      } else {
                        _selected.add(rsId);
                      }
                    });
                  },
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(rsId);
                          } else {
                            _selected.remove(rsId);
                          }
                        });
                      },
                    ),
                    title: Row(
                      children: [
                        Text(
                          rsId,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            gene,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                      tooltip: 'Delete',
                      onPressed: () {
                        notifier.removeSearch(rsId);
                        setState(() => _selected.remove(rsId));
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
