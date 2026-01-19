
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/doctor_models.dart';

class ApiService {
  /* =====================
     DOCTOR AUTH
  ===================== */
  static Future<Doctor?> doctorLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/doctor/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Doctor.fromJson(data['doctor']);
        }
      }
      return null;
    } catch (e) {
      print("Doctor Login Error: $e");
      return null;
    }
  }

  /* =====================
     DOCTOR DASHBOARD
  ===================== */
  static Future<DashboardData> getDoctorDashboard(String doctorId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/doctor/dashboard'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'doctorId': doctorId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load dashboard: ${response.body}');
    }

    return DashboardData.fromJson(jsonDecode(response.body));
  }

  static Future<void> updateAvailability({
    required String doctorId,
    required String date,
    required bool morning,
    required bool evening,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/doctor/availability'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'doctorId': doctorId,
        'date': date,
        'morning': morning,
        'evening': evening,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update availability');
    }
  }
}
