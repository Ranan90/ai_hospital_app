import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'ai_results_screen.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController inputController = TextEditingController();

  Map<String, dynamic> user = {
    "name": "John",
    "email": "john@gmail.com",
    "phone": "9999999999",
    "height_cm": 0,
    "weight_kg": 0,
    "dob": "1990-01-01",
  };

  bool collectingHeightWeight = true;
  String currentQuestion =
      "Enter height (cm) and weight (kg) separated by comma (eg: 175,70)";
  bool isLoading = false;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  /* ---------------- HEIGHT & WEIGHT ---------------- */

  Future<void> submitHeightWeight() async {
    final parts = inputController.text.split(',');

    if (parts.length != 2) {
      _showError('Please enter height and weight correctly.');
      return;
    }

    final height = int.tryParse(parts[0].trim());
    final weight = int.tryParse(parts[1].trim());

    if (height == null || weight == null) {
      _showError('Invalid height or weight.');
      return;
    }

    user['height_cm'] = height;
    user['weight_kg'] = weight;

    setState(() => isLoading = true);

    try {
      final data = await AIService.initUser(user);

      setState(() {
        user = data;
        collectingHeightWeight = false;
        currentQuestion = "What symptoms are you experiencing?";
      });
    } catch (_) {
      _showAiFailure();
    } finally {
      setState(() => isLoading = false);
      inputController.clear();
    }
  }

  /* ---------------- SYMPTOM SUBMIT ---------------- */

  Future<void> submitSymptom() async {
    final symptom = inputController.text.trim();

    if (symptom.isEmpty) {
      _showError('Please describe your symptoms.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final department = await AIService.symptomCheck(user['id'], [symptom]);

      if (department == null) {
        _showAiFailure();
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(department: department)),
      );
    } catch (_) {
      _showAiFailure();
    } finally {
      setState(() => isLoading = false);
      inputController.clear();
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Symptom Checker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: inputController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type here...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: collectingHeightWeight
                          ? submitHeightWeight
                          : submitSymptom,
                      child: Text(collectingHeightWeight ? 'Continue' : 'Next'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /* ---------------- DIALOGS ---------------- */

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAiFailure() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('AI Service Unavailable'),
        content: const Text(
          'Our AI service is currently not working.\n\n'
          'Please try again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
