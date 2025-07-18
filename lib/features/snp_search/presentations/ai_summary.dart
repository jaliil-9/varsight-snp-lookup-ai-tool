import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';

class AiSummaryTab extends StatelessWidget {
  final String summary;

  const AiSummaryTab({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    List<Widget> buildSummaryWidgets() {
      final List<Widget> widgets = [];
      final lines = summary.split('\n');

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line == '---') {
          continue;
        }

        if (line.startsWith('###')) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: Sizes.md, bottom: Sizes.sm),
              child: Text(
                line.replaceAll('###', '').replaceAll('**', '').trim(),
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else if (line.startsWith('**') &&
            line.endsWith('**') &&
            line.contains('Database Annotations')) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: Sizes.md, bottom: Sizes.sm),
              child: Text(
                line.replaceAll('**', '').trim(),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else if (line.startsWith('*')) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: Sizes.md, bottom: Sizes.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      line.substring(1).trim(),
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: Sizes.sm),
              child: Text(
                line,
                style: textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          );
        }
      }
      return widgets;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sizes.md),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildSummaryWidgets(),
          ),
          SizedBox(height: Sizes.spaceBtwItems),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
              top: 8,
              right: MediaQuery.of(context).size.width * 0.3,
              bottom: 8,
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor:
                    isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: summary));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI Summary copied to clipboard'),
                    ),
                  );
                }
              },
              icon: const Icon(Iconsax.copy, size: 20),
              label: const Text('Copy to Clipboard'),
            ),
          ),
          SizedBox(height: Sizes.spaceBtwSections),
        ],
      ),
    );
  }
}
