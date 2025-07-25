import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/core/utils/error.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';

class PubmedTab extends StatelessWidget {
  final List<PubmedArticle> articles;

  const PubmedTab({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(child: Text('No PubMed articles found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(Sizes.md),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: Sizes.spaceBtwItems),
      itemBuilder: (context, index) {
        return PubmedArticleCard(article: articles[index]);
      },
    );
  }
}

class PubmedArticleCard extends StatelessWidget {
  final PubmedArticle article;

  const PubmedArticleCard({super.key, required this.article});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ErrorUtils.showErrorSnackBar(ErrorUtils.getErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusMd),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusMd),
        onTap: () => _launchURL(article.url),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Sizes.sm),
              Text(
                article.authors,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: Sizes.md),
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 16,
                    color:
                        isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: Sizes.sm),
                  Expanded(
                    child: Text(
                      '${article.journal} (${article.year})',
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Sizes.sm),
                  Icon(
                    Icons.launch,
                    size: 16,
                    color:
                        isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
