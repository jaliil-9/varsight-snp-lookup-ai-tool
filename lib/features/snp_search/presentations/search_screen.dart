import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/features/snp_search/models/search_state.dart';
import 'package:varsight/features/snp_search/presentations/widgets/recent_searches_list.dart';
import 'package:varsight/features/snp_search/presentations/widgets/variant_summary_card.dart';
import 'package:varsight/features/snp_search/presentations/widgets/search_loading_stepper.dart';
import 'package:varsight/features/snp_search/providers/snp_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    final searchNotifier = ref.read(searchProvider.notifier);
    await searchNotifier.search(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SearchState>>(searchProvider, (previous, next) {
      next.when(
        data: (searchState) async {
          if (searchState.dossier != null) {
            final snpNotifier = ref.read(snpDossierProvider.notifier);
            await snpNotifier.saveDossierLocally(searchState.dossier!);
          }
        },
        error: (err, stack) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(err.toString())));
          }
        },
        loading: () {},
      );
    });

    final searchAsync = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: 56,
          child: Image.asset('assets/logo/varsight.png', fit: BoxFit.contain),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.user),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.spaceBtwSections * 2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  "Howdy, Explorer!\nLet's see what the data holds.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            Form(
              key: _formKey,
              child: SearchInputField(
                controller: _searchController,
                onSubmitted: (value) {
                  if (_formKey.currentState!.validate()) {
                    _performSearch(value);
                  }
                },
                isLoading: searchAsync.isLoading,
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            searchAsync.when(
              data: (searchState) {
                if (searchState.isLoading && searchState.currentStep != null) {
                  return SearchLoadingStepper(
                    currentStep: searchState.currentStep!,
                    stepStartTime: searchState.stepStartTime!,
                  );
                } else if (searchState.dossier != null) {
                  return VariantSummaryCard(
                    snpData: searchState.dossier!.snpData,
                    showViewFullResultButton: true,
                  );
                } else {
                  return const RecentSearchesList();
                }
              },
              loading: () => const SizedBox.shrink(), // The stepper handles the visual loading state
              error: (err, stack) => const RecentSearchesList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final bool isLoading;

  const SearchInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusMd),
      ),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a valid SNP rsID';
          } else if (!RegExp(
            r'^rs\d+$',
            caseSensitive: false,
          ).hasMatch(value.trim())) {
            return 'Invalid rsID format (e.g., rs1805008)';
          }
          return null;
        },
        onFieldSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Enter SNP rsID (e.g., rs1805008)',
          prefixIcon: Icon(
            Icons.search,
            color:
                isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
          ),
          suffixIcon:
              isLoading
                  ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.arrow_circle_right_rounded),
                    color: AppColors.primaryLight,
                    iconSize: 28,
                    onPressed: () => onSubmitted(controller.text),
                  ),
        ),
      ),
    );
  }
}
