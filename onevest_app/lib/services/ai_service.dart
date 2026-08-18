import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIService {
  // ============================================================
  // BACKEND URL
  // ============================================================

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:4021";
    }

    // Android Emulator -> host machine
    return "http://10.0.2.2:4021";
  }

  // ============================================================
  // AI ASSISTANT
  // ============================================================

  static Future<String> askAI(String question) async {
    try {
      final prompt =
          '''
You are OneVest AI, an intelligent investment assistant.

Rules:
- Answer only finance and investment related questions.
- Keep answers short (3-6 lines).
- Be beginner friendly.
- If asked something unrelated, politely say you only answer investment questions.
- Give practical suggestions wherever possible.

User Question:
$question
''';

      debugPrint("AIService: sending request to backend");

      final response = await http
          .post(
            Uri.parse("$baseUrl/api/ai"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"question": question, "prompt": prompt}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint("AIService: backend status ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("AIService: backend error ${response.body}");

        return "Sorry, the AI service is currently unavailable.";
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data["success"] != true) {
        return data["message"]?.toString() ??
            "Sorry, I couldn't generate a response.";
      }

      final answer = data["answer"]?.toString();

      if (answer == null || answer.trim().isEmpty) {
        return "Sorry, I couldn't generate a response.";
      }

      return answer;
    } catch (e) {
      debugPrint("AIService error: $e");

      return "Sorry, the AI service is currently unavailable.";
    }
  }
}
