import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/api_config.dart';
import '../../models/triage_models.dart';

class AIService {
  /* =====================
     INIT / UPDATE USER
  ===================== */

  static Future<void> initUser({
    required int heightCm,
    required int weightKg,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': user.id,
        'email': user.email,
        'height': heightCm,
        'weight': weightKg,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update user profile");
    }
  }

  /* =====================
     AI CHAT
  ===================== */

  static Future<TriageResponse> sendMessage(List<ChatMessage> history) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/ai/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"history": history.map((e) => e.toJson()).toList()}),
    );

    if (res.statusCode != 200) {
      throw Exception("AI request failed");
    }

    return TriageResponse.fromJson(jsonDecode(res.body));
  }
}
