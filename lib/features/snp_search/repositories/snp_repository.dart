import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:varsight/features/snp_search/models/variant_model.dart';

class SnpRepository {
  final String baseUrl;
  SnpRepository({required this.baseUrl});

  Future<VariantModel> fetchSnpDossier(String rsId) async {
    final url = Uri.parse('$baseUrl/snp/$rsId');
    print('[SnpRepository] Fetching SNP dossier for: $rsId at $url');
    final response = await http.get(url);
    print('[SnpRepository] Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('[SnpRepository] Response data: ${data.toString()}');
      if (data['success'] == true && data['dossier'] != null) {
        // The backend returns ai_summary at the top level, but our model expects it inside dossier
        final dossierJson = data['dossier'];
        dossierJson['ai_summary'] = data['ai_summary'] ?? '';
        return VariantModel.fromJson(dossierJson);
      } else {
        print(
          '[SnpRepository] Error: No dossier found or backend error: ${data['detail']}',
        );
        throw Exception(data['detail'] ?? 'No dossier found');
      }
    } else {
      print(
        '[SnpRepository] Error: Failed to fetch SNP dossier: ${response.statusCode}',
      );
      throw Exception('Failed to fetch SNP dossier: ${response.statusCode}');
    }
  }
}
