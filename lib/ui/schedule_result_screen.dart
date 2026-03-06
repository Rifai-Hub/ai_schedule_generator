import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:intl/intl.dart'; 

class ScheduleResultScreen extends StatefulWidget {
  final String scheduleResult;
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  @override
  State<ScheduleResultScreen> createState() => _ScheduleResultScreenState();
}

class _ScheduleResultScreenState extends State<ScheduleResultScreen> {
  // --- LOGIKA ASLI TETAP DIPERTAHANKAN ---
  bool _isLoading = false;

  List<Map<String, String>> _parseSchedule(String markdown) {
    final regExp = RegExp(r"(\d{2}:\d{2})");
    final matches = regExp.allMatches(markdown);
    
    if (matches.isEmpty) return [];
    
    return matches.map((m) => {
      "time": m.group(1) ?? "",
      "activity": "Kegiatan Terjadwal"
    }).toList();
  }

  Future<void> _exportToGoogleCalendar() async {
    setState(() => _isLoading = true);

    try {
      final String title = Uri.encodeComponent("Jadwal Optimal AI");
      final String cleanDetails = widget.scheduleResult.replaceAll('#', '').replaceAll('*', '');
      final String details = Uri.encodeComponent(cleanDetails);
      
      final scheduledDate = DateTime.now().add(const Duration(days: 1));
      final String startTime = DateFormat("yyyyMMdd'T'080000").format(scheduledDate);
      final String endTime = DateFormat("yyyyMMdd'T'170000").format(scheduledDate);

      final String url = "https://calendar.google.com/calendar/render?action=TEMPLATE"
          "&text=$title"
          "&details=$details"
          "&dates=$startTime/$endTime";

      final Uri calendarUri = Uri.parse(url);

      if (await canLaunchUrl(calendarUri)) {
        await launchUrl(
          calendarUri, 
          mode: LaunchMode.externalApplication, 
        );
      } else {
        await launchUrl(calendarUri); 
      }
    } catch (e) {
      _showErrorDialog("Gagal mengekspor: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Pemberitahuan", style: TextStyle(fontFamily: 'SF Pro', fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontFamily: 'SF Pro')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("OK", style: TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }
  // --- END OF LOGIKA ASLI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // background-light
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text(
          "Hasil Jadwal",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 22,
            fontFamily: 'SF Pro',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy_rounded, color: Color(0xFFA855F7), size: 22),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.scheduleResult));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Jadwal berhasil disalin!", style: TextStyle(fontFamily: 'SF Pro')),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF0F172A),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildInfoBanner(),
              const SizedBox(height: 20),
              
              // Kartu Markdown (Glass Style)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Markdown(
                      data: widget.scheduleResult,
                      selectable: true,
                      padding: const EdgeInsets.all(24),
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontFamily: 'SF Pro', fontSize: 15, color: Color(0xFF334155), height: 1.5),
                        h1: const TextStyle(fontFamily: 'SF Pro', fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        h2: const TextStyle(fontFamily: 'SF Pro', fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        listBullet: const TextStyle(color: Color(0xFFA855F7)),
                        tableCellsPadding: const EdgeInsets.all(12),
                        tableBorder: TableBorder.all(color: const Color(0xFFF1F5F9), width: 1),
                        tableBody: const TextStyle(fontFamily: 'SF Pro', fontSize: 13, height: 1.4, color: Color(0xFF475569)),
                        tableHead: const TextStyle(fontFamily: 'SF Pro', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                        tableColumnWidth: const FlexColumnWidth(), 
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tombol Ekspor (Gradient Style)
              _buildGradientButton(
                onTap: _isLoading ? null : _exportToGoogleCalendar,
                text: "Ekspor ke Google Calendar",
                icon: Icons.calendar_today_rounded,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFA855F7).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFFA855F7), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Jadwal ini disusun otomatis oleh AI untuk produktivitas maksimal kamu.",
              style: TextStyle(
                color: Color(0xFF7E22CE), 
                fontSize: 13, 
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onTap,
    required String text,
    required IconData icon,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA259FF), Color(0xFFFF61D2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA259FF).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}