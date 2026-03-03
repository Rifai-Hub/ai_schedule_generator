import 'dart:convert'; 
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyBSJ4EZTRBgQqAfM4SYSuqz4E44oo4Fyog";

  static const String model = "gemini-1.5-flash";

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
          throw Exception("Rate limit tercapai (429). Tunggu beberapa menit.");
        }
        if (response.statusCode == 401) {
          throw Exception("API key tidak valid (401). Periksa kembali key Anda.");
        }
        if (response.statusCode == 403) {
          throw Exception("Akses ditolak (403). Pastikan API Gemini sudah aktif di Google Cloud.");
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

INSTRUKSI FORMAT KHUSUS:
1. Berikan jadwal dalam format Markdown, mulai dari jam 08:00 pagi.
2. Gunakan tabel dengan 3 KOLOM UTAMA agar tetap rapi: | Waktu | Kegiatan & Prioritas | Keterangan |.
3. Di kolom 'Kegiatan & Prioritas', gabungkan nama tugas dan level prioritasnya (contoh: "Makan (Tinggi)").
4. Kolom 'Keterangan' harus berisi penjelasan singkat atau tips pelaksanaan tugas tersebut.
5. Gunakan bahasa Indonesia yang santai.
6. Tambahkan tips produktivitas tambahan di bagian paling bawah setelah tabel.
""";
  }
}