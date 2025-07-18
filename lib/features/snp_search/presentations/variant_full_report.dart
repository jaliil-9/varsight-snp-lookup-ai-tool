import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';
import 'package:varsight/features/snp_search/presentations/ai_summary.dart';
import 'package:varsight/features/snp_search/presentations/data_source.dart';
import 'package:varsight/features/snp_search/presentations/pubmed_screen.dart';
import 'package:varsight/features/snp_search/presentations/widgets/variant_summary_card.dart';

class VariantFullReport extends ConsumerStatefulWidget {
  final VariantModel dossier;

  const VariantFullReport({super.key, required this.dossier});

  @override
  ConsumerState<VariantFullReport> createState() => _VariantFullReportState();
}

class _VariantFullReportState extends ConsumerState<VariantFullReport>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showCopyButton = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        showCopyButton = _tabController.index == 0;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dossier.snpData.rsId),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Sizes.md),
            child: VariantSummaryCard(
              snpData: widget.dossier.snpData,
              showViewFullResultButton: false,
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor:
                isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            unselectedLabelColor:
                isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
            indicatorColor:
                isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            indicatorWeight: 3.0,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(icon: Icon(Iconsax.magicpen), text: 'AI Summary'),
              Tab(icon: Icon(Iconsax.book), text: 'Literature'),
              Tab(icon: Icon(Iconsax.data), text: 'Data Sources'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AiSummaryTab(summary: widget.dossier.aiSummary),
                PubmedTab(articles: widget.dossier.pubmedData),
                StandardsCompliantDataSourcesTab(
                  snpData: widget.dossier.snpData,
                  gwasData: widget.dossier.gwasData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
