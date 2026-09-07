import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiApi {
  Future<String> sendRequest(String text) async {
    String link =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent";
    var uri = Uri.parse(link);

    Map<String, String> header = {
      "x-goog-api-key": dotenv.env['GEMINI_API_KEY']!,
      "Content-Type": "application/json",
    };

    Map<String, dynamic> body = {
      "contents": [
        {
          "parts": [
            {"text": text}
          ]
        }
      ]
    };

    // ↓↓↓ this whole block replaces your old "var request = ..." through the final return ↓↓↓
    const maxRetries = 2;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      var request = await http.post(uri, headers: header, body: jsonEncode(body));
      print(request.statusCode);
      print(request.body);

      if (request.statusCode == 200) {
        var jsonResponse = jsonDecode(request.body);
        return jsonResponse["candidates"][0]["content"]["parts"][0]["text"].toString();
      }

      // Retry only on 503 (overloaded), not other errors
      if (request.statusCode == 503 && attempt < maxRetries) {
        await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        continue;
      }

      throw Exception("Request failed (${request.statusCode}): ${request.body}");
    }

    throw Exception("Request failed after retries");
    // ↑↑↑ end of replaced block ↑↑↑
  }
}