import 'package:flutter/material.dart';
import '../../models/triage_models.dart';
import 'ai_service.dart';
import 'ai_results_screen.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [
    ChatMessage(
      role: "model",
      content:
          "Hello! I can help determine which medical specialist you may need. "
          "What symptoms are you experiencing?",
    ),
  ];

  bool loading = false;
  TriageResponse? result;

  Future<void> send() async {
    if (controller.text.isEmpty || loading) return;

    setState(() {
      messages.add(ChatMessage(role: "user", content: controller.text));
      controller.clear();
      loading = true;
    });

    try {
      final res = await AIService.sendMessage(messages);

      setState(() {
        messages.add(ChatMessage(role: "model", content: res.message));

        // Only show recommendation if truly a significant conclusion
        if (res.status.toLowerCase() == "conclusion" &&
            (res.recommendedDepartment?.isNotEmpty ?? false)) {
          result = res;
        }
      });
    } catch (e) {
      if (!mounted) return;

      String friendlyError =
          "The AI service is unavailable. Please try again later.";

      final msg = e.toString();
      if (msg.contains("503")) {
        friendlyError =
            "The AI model is currently overloaded. Please try again later.";
      } else if (msg.contains("429")) {
        friendlyError =
            "Daily usage limit reached. Please try again in a few hours.";
      } else if (msg.contains("Failed host lookup") ||
          msg.contains("SocketException")) {
        friendlyError = "No internet connection. Please check your network.";
      }

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Service Unavailable"),
          content: Text(friendlyError),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // go back home
              },
              child: const Text("Go Home"),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MediGuide AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m = messages[i];
                final isUser = m.role == "user";

                return ListTile(
                  title: Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          if (result != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                child: const Text("View Recommendation"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AIResultScreen(
                        result: TriageResponse(
                          status: result!.status,
                          message: result!.message,
                          recommendedDepartment:
                              result!.recommendedDepartment ??
                              "General Medicine",
                          reasoning: result!.reasoning,
                          urgency: result!.urgency,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Describe symptoms",
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
