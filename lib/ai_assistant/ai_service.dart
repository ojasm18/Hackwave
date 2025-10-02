import 'package:google_generative_ai/google_generative_ai.dart';
import '../common/env.dart';

class AIService {
  static Future<String> chat(String message, {String? systemPrompt, String? model}) async {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      return 'Gemini API key not set. Provide --dart-define=GEMINI_API_KEY=...';
    }
    final modelName = model ?? Env.geminiModel;
    final generativeModel = GenerativeModel(model: modelName, apiKey: apiKey);

    // Embed system instructions by prefixing the prompt
    final prompt = systemPrompt == null
        ? message
        : '$systemPrompt\n\nUser: $message';

    try {
      final response = await generativeModel.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return text.trim().isEmpty ? 'No response' : text.trim();
    } catch (e) {
      return 'Error: $e';
    }
  }
}
