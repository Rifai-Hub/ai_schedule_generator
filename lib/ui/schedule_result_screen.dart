import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_markdown/flutter_markdown.dart'; 
import 'package:markdown/markdown.dart' as md;

class ScheduleResultScreen extends StatelessWidget {
  final String scheduleResult; 
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Hasil Jadwal Optimal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: "Salin Jadwal",
            onPressed: () {
              Clipboard.setData(ClipboardData(text: scheduleResult));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Jadwal berhasil disalin!")),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.indigo),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Jadwal ini disusun otomatis oleh AI berdasarkan prioritas Anda.",
                        style: TextStyle(color: Colors.indigo, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Markdown(
                      data: scheduleResult, 
                      selectable: true, 
                      padding: const EdgeInsets.all(20),
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.black87),
                        h1: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                        h2: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        h3: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigoAccent),
                        tableBorder:
                            TableBorder.all(color: Colors.grey, width: 1),
                        tableHeadAlign: TextAlign.center,
                        tablePadding: const EdgeInsets.all(8),
                      ),
                      builders: {"table": TableBuilder()},
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Buat Jadwal Baru"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return null;
  }
}