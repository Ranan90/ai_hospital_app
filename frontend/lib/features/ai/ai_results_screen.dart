import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/triage_models.dart';
import 'package:intl/intl.dart';

class AIResultScreen extends StatefulWidget {
  final TriageResponse result;

  const AIResultScreen({super.key, required this.result});

  @override
  State<AIResultScreen> createState() => _AIResultScreenState();
}

class _AIResultScreenState extends State<AIResultScreen> {
  bool _isLoading = true;
  String? _departmentAbout;
  List<Map<String, dynamic>> _availableDoctors = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final deptName = widget.result.recommendedDepartment;

      if (deptName == null) {
        if (mounted) {
          setState(() {
            _errorMessage = "No specific department recommended.";
            _isLoading = false;
          });
        }
        return;
      }
      
      // Use HTTP call to backend instead of direct Supabase
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/department-details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'departmentName': deptName,
          'clientHour': DateTime.now().hour,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] ?? "Unknown error";
        throw Exception("Backend error: $error");
      }

      final data = jsonDecode(response.body);
      final about = data['about'] as String?;
      final doctorsList = (data['doctors'] as List).cast<Map<String, dynamic>>();

      if (mounted) {
        setState(() {
          _departmentAbout = about;
          _availableDoctors = doctorsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error loading data: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analysis Result",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.result.status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(widget.result.status),
                  size: 48,
                  color: _getStatusColor(widget.result.status),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Text
            // Summary Text
            Text(
              "Recommendation: ${widget.result.recommendedDepartment ?? 'General Consultation'}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Reasoning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                widget.result.reasoning ?? "No reasoning provided.",
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Department Info Section
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                "About ${widget.result.recommendedDepartment}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _departmentAbout ?? "No description available.",
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Available Doctors
              Text(
                "Available Doctors for Today",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              if (_availableDoctors.isEmpty)
                const Text(
                  "No doctors available at this time.",
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _availableDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _availableDoctors[index];
                    return _buildDoctorCard(doctor);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.shade100,
              child: Text(
                (doctor['name'] as String)[0],
                style:
                    TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${doctor['experience']} years experience",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (doctor['morning'])
                        _buildSlotBadge("Morning", Colors.orange),
                      if (doctor['morning'] && doctor['evening'])
                        const SizedBox(width: 8),
                      if (doctor['evening'])
                        _buildSlotBadge("Evening", Colors.indigo),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Consultation logic placeholder
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Consult"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'emergency':
        return Colors.red;
      case 'urgent':
        return Colors.orange;
      case 'routine':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'emergency':
        return Icons.warning_rounded;
      case 'urgent':
        return Icons.priority_high_rounded;
      case 'routine':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline;
    }
  }
}
