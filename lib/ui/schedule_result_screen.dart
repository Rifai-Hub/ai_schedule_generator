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
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pemberitahuan"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Hasil Jadwal Optimal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.scheduleResult));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Jadwal berhasil disalin!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.event_available),
            onPressed: _isLoading ? null : _exportToGoogleCalendar,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 15),
              Expanded(
                child: Container(
                  decoration: _boxDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Markdown(
                      data: widget.scheduleResult,
                      selectable: true,
                      padding: const EdgeInsets.all(15),
                      styleSheet: MarkdownStyleSheet(
                        tableCellsPadding: const EdgeInsets.all(8),
                        tableBorder: TableBorder.all(color: Colors.grey.shade200, width: 1),
                        tableBody: const TextStyle(fontSize: 12, height: 1.4),
                        tableHead: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        tableColumnWidth: const FlexColumnWidth(), 
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _isLoading ? null : _exportToGoogleCalendar,
                  icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.calendar_month),
                  label: Text(_isLoading ? "Memproses..." : "Ekspor ke Google Calendar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.indigo),
          SizedBox(width: 10),
          Expanded(child: Text("Jadwal ini disusun otomatis oleh AI.", style: TextStyle(color: Colors.indigo, fontSize: 13))),
        ],
      ),
    );
  }
}