import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/api_config.dart';

class AIService {
  static Future<void> initUser(Map<String, dynamic> userData) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        ...userData,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<String?> symptomCheck(int userId, List<String> answers) async {
    try {
      // 1. Call AI API for inference
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/symptom/check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'answers': answers}),
      );

      if (response.statusCode != 200) {
        return null; // Or handle error appropriately
      }

      final data = jsonDecode(response.body);
      final department = data['department'];

      // 2. Save result to Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('symptom_checks').insert({
          'user_id': user.id,
          'symptoms': answers,
          'result_department': department,
          'metadata': data, // Store full response if needed
        });
      }

      return department;
    } catch (e) {
      // Log error or handle it
      print('Error in symptomCheck: $e');
      return null;
    }
  }
}
