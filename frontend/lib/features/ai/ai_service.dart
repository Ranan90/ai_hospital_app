import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class AIService {
  static Future<Map<String, dynamic>> initUser(
    Map<String, dynamic> userData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    return jsonDecode(response.body);
  }

  static Future<String?> symptomCheck(int userId, List<String> answers) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/symptom/check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'answers': answers}),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      return data['department'];
    } catch (e) {
      return null;
    }
  }
}
