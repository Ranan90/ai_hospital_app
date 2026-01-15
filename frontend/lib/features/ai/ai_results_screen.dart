import 'package:flutter/material.dart';
import '../../models/triage_models.dart';

class AIResultScreen extends StatelessWidget {
  final TriageResponse result;

  const AIResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommendation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Urgency: ${result.urgency.toUpperCase()}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Department:", style: Theme.of(context).textTheme.titleMedium),
            Text(result.recommendedDepartment ?? "General Medicine"),
            const SizedBox(height: 16),
            Text("Reasoning:", style: Theme.of(context).textTheme.titleMedium),
            Text(result.reasoning ?? ""),
          ],
        ),
      ),
    );
  }
}
