import 'dart:convert'; 
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyDoeaBkOPyf7fu1t8cnpWkZ1hiza_mgtEQ";

  static const String model = "gemini-flash-latest";

  static const String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

  static Future<String> generateSchedule(
    List<Map<String, dynamic>> tasks,
  ) async {
    try {
      final prompt = _buildPrompt(tasks);
      final url = Uri.parse('$baseUrl?key=$apiKey');

      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],

        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        },
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": apiKey, 
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["candidates"] != null &&
            data["candidates"].isNotEmpty &&
            data["candidates"][0]["content"] != null &&
            data["candidates"][0]["content"]["parts"] != null &&
            data["candidates"][0]["content"]["parts"].isNotEmpty) {
          return data["candidates"][0]["content"]["parts"][0]["text"] as String;
        }
        return "Tidak ada jadwal yang dihasilkan dari AI.";
      } else {
        print("API Error - Status: ${response.statusCode}, Body: ${response.body}");
        if (response.statusCode == 429) {
          throw Exception("Rate limit tercapai (429). Tunggu beberapa menit atau upgrade quota.");
        }
        if (response.statusCode == 401) {
          throw Exception("API key tidak valid (401). Periksa key Anda.");
        }
        if (response.statusCode == 400) {
          throw Exception("Request salah format (400). Periksa struktur data tugas.");
        }
        throw Exception("Gagal memanggil Gemini API (Code: ${response.statusCode})");
      }
    } catch (e) {
      print("Exception saat generate schedule: $e");
      throw Exception("Error saat generate jadwal: $e");
    }
  }

  static String _buildPrompt(List<Map<String, dynamic>> tasks) {
    String taskDescription = tasks.map((task) => 
      "- ${task['name']} (${task['duration']} menit, Prioritas: ${task['priority']})"
    ).join('\n');

    return """
Buatkan jadwal harian yang efisien berdasarkan daftar tugas berikut:
$taskDescription

Berikan jadwal dalam format Markdown yang rapi, mulai dari jam 08:00 pagi.
Gunakan tabel jika memungkinkan untuk jadwalnya.
Tambahkan tips produktivitas di bagian akhir.
""";
  }
}