import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/triage_models.dart';
import 'ai_service.dart';
import 'ai_results_screen.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // UI State for messages (includes time for display)
  final List<Map<String, dynamic>> _messages = [];

  bool _isTyping = false;
  TriageResponse? _result;
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndStart();
  }

  Future<void> _fetchProfileAndStart() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (data != null && mounted) {
          setState(() {
            _userProfile = data;
          });
        }
      } catch (e) {
        // Continue even if profile load fails
        debugPrint("Failed to load profile for AI context: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
      _startChat();
    }
  }

  void _startChat() {
    // Initial AI Message
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        String greeting =
            "Hello! I can help determine which medical specialist you may need.";
        // if (_userProfile != null && _userProfile!['name'] != null) {
        //   greeting = "Hello ${_userProfile!['name']}! I can help determine which medical specialist you may need.";
        // }
        _addMessage(
          "$greeting What symptoms are you experiencing?",
          isUser: false,
        );
      }
    });
  }

  // Helper to convert UI messages to API model
  List<ChatMessage> get _apiMessages {
    return _messages.map((m) {
      return ChatMessage(
        role: m['isUser'] ? "user" : "model",
        content: m['text'],
      );
    }).toList();
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add({'text': text, 'isUser': isUser, 'time': DateTime.now()});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    _controller.clear();
    _addMessage(text, isUser: true);

    setState(() {
      _isTyping = true;
    });

    try {
      final res = await AIService.sendMessage(
        _apiMessages,
        userProfile: _userProfile, // Pass the context
      );

      if (mounted) {
        setState(() {
          _addMessage(res.message, isUser: false);

          if (res.status.toLowerCase() == "conclusion" &&
              (res.recommendedDepartment?.isNotEmpty ?? false)) {
            _result = res;
          }
        });
      }
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

      _addMessage(friendlyError, isUser: false);
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MediGuide AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Text(
                              "Typing...",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(
                        message['text'],
                        message['isUser'],
                        message['time'],
                      );
                    },
                  ),
                ),
                if (_result != null) _buildResultButton(),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildResultButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.medical_services_outlined),
        label: const Text("View Recommendation"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: () {
          if (_result != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIResultScreen(
                  result: TriageResponse(
                    status: _result!.status,
                    message: _result!.message,
                    recommendedDepartment:
                        _result!.recommendedDepartment ?? "General Medicine",
                    reasoning: _result!.reasoning,
                    urgency: _result!.urgency,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, DateTime time) {
    String formattedTime = DateFormat('h:mm a').format(time);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 16,
                  child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.teal : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                      bottomRight: isUser
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isUser
                        ? null
                        : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 16,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isUser ? 0 : 40,
              right: isUser ? 40 : 0,
            ),
            child: Text(
              formattedTime,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _handleSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => _handleSubmitted(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
