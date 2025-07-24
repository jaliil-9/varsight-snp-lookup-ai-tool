import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:varsight/features/snp_search/models/variant_model.dart';

class SnpRepository {
  final String baseUrl;
  SnpRepository({required this.baseUrl});

  Future<VariantModel> fetchSnpDossier(String rsId) async {
    final url = Uri.parse('$baseUrl/snp/$rsId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true && data['dossier'] != null) {
        // The backend returns ai_summary at the top level, but our model expects it inside dossier
        final dossierJson = data['dossier'];
        dossierJson['ai_summary'] = data['ai_summary'] ?? '';
        return VariantModel.fromJson(dossierJson);
      } else {
        throw Exception(data['detail'] ?? 'No dossier found');
      }
    } else {
      throw Exception(
        'Failed to fetch SNP dossier [$url]: ${response.statusCode} – ${response.body}',
      );
    }
  }
}
