import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/api_config.dart';

class AIService {
  static Future<void> initUser(Map<String, dynamic> userData) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Call backend to update profile
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': user.id, ...userData}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update user profile: ${response.statusCode}',
        );
      }
    }
  }

  static Future<String?> symptomCheck(int userId, List<String> answers) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final actualUserId = user?.id;

      // 1. Call AI API for inference (Backend now handles Supabase insert)
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/symptom-check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': actualUserId, 'answers': answers}),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      final department = data['department'];

      return department;
    } catch (e) {
      print('Error in symptomCheck: $e');
      return null;
    }
  }
}
