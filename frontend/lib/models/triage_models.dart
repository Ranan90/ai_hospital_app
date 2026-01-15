enum TriageStatus { gatheringInfo, conclusion }

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {"role": role, "content": content};
}

class TriageResponse {
  final String status;
  final String message;
  final String? recommendedDepartment;
  final String? reasoning;
  final String urgency;

  TriageResponse({
    required this.status,
    required this.message,
    this.recommendedDepartment,
    this.reasoning,
    required this.urgency,
  });

  factory TriageResponse.fromJson(Map<String, dynamic> json) {
    return TriageResponse(
      status: json["status"],
      message: json["message"],
      recommendedDepartment: json["recommendedDepartment"],
      reasoning: json["reasoning"],
      urgency: json["urgency"],
    );
  }
}
