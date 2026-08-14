import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // 🔑 Replace with your Gemini API Key
  static const String apiKey = "AQ.Ab8RN6LXx6vmJOj5Nm291_9i3do43gn9HeGoJSzkK999q1tNyw";

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: apiKey,
  );

  static Future<String> askAI(String question) async {
    try {
      final prompt = '''
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

      final response = await _model.generateContent(
        [Content.text(prompt)],
      );

      return response.text ??
          "Sorry, I couldn't generate a response.";
    } catch (e) {
      return "Error: $e";
    }
  }
}