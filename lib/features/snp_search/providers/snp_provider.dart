import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/snp_search/models/search_state.dart';
import 'package:varsight/features/snp_search/models/variant_model.dart';
import 'package:varsight/features/snp_search/notifiers/search_notifier.dart';
import 'package:varsight/features/snp_search/notifiers/snp_dossier_notifier.dart';
import 'package:varsight/features/snp_search/repositories/snp_repository.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

// Updated backend URL for local development
String _backendBaseUrl = dotenv.env['BACKEND_URL']!;

final snpRepositoryProvider = Provider<SnpRepository>((ref) {
  return SnpRepository(baseUrl: _backendBaseUrl);
});

final snpDossierProvider =
    AsyncNotifierProvider<SnpDossierNotifier, VariantModel?>(
      SnpDossierNotifier.new,
    );

final searchProvider = AsyncNotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
