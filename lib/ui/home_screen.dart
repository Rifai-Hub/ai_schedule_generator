import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import 'schedule_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Tetap mempertahankan logika asli kamu ---
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String? priority;
  bool isLoading = false;

  @override
  void dispose() {
    taskController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (taskController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        priority != null) {
      setState(() {
        tasks.add({
          "name": taskController.text,
          "priority": priority!,
          "duration": int.tryParse(durationController.text) ?? 30,
        });
      });
      taskController.clear();
      durationController.clear();
      setState(() => priority = null);
    }
  }

  Future<void> _generateSchedule() async {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Harap tambahkan tugas dulu!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final schedule = await GeminiService.generateSchedule(tasks);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ScheduleResultScreen(scheduleResult: schedule),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color _getColor(String value) {
    switch (value) {
      case "Tinggi": return const Color(0xFFA855F7);
      case "Sedang": return const Color(0xFFF472B6);
      case "Rendah": return const Color(0xFF94A3B8);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Header diatur ke kiri (centerTitle: false)
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "AI Schedule",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 24,
              fontFamily: 'SF Pro', // Menggunakan font dari yaml kamu
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined, color: Color(0xFFA855F7)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Section (Card Putih)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: taskController,
                        hint: "Nama Tugas",
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: durationController,
                              hint: "Durasi (Min)",
                              icon: Icons.schedule_rounded,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGradientButton(
                        onTap: _addTask,
                        text: "Tambah Tugas",
                        icon: Icons.add_rounded,
                      ),
                    ],
                  ),
                ),

                // Daftar Tugas Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daftar Tugas",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SF Pro',
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        "${tasks.length} Tugas",
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ),
                ),

                // List Tugas
                if (tasks.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildTaskItem(task, index);
                    },
                  ),
                const SizedBox(height: 120), // Memberi ruang untuk floating button
              ],
            ),
          ),

          // Tombol Utama di Bawah
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildGradientButton(
              onTap: isLoading ? null : _generateSchedule,
              text: "Buat Jadwal AI",
              icon: Icons.auto_awesome_rounded,
              isLarge: true,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontFamily: 'SF Pro'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'SF Pro'),
        prefixIcon: Icon(icon, color: const Color(0xFFA855F7), size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: priority,
      hint: const Text("Prioritas", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'SF Pro')),
      style: const TextStyle(fontFamily: 'SF Pro', color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        prefixIcon: const Icon(Icons.flag_outlined, color: Color(0xFFA855F7), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: ["Tinggi", "Sedang", "Rendah"]
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'SF Pro'))))
          .toList(),
      onChanged: (val) => setState(() => priority = val),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onTap,
    required String text,
    required IconData icon,
    bool isLarge = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 64 : 54,
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
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 10),
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

  Widget _buildTaskItem(Map<String, dynamic> task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              task['name'][0].toUpperCase(),
              style: TextStyle(
                color: _getColor(task['priority']),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'SF Pro',
              ),
            ),
          ),
        ),
        title: Text(
          task['name'],
          style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'SF Pro', fontSize: 16),
        ),
        subtitle: Text(
          "${task['duration']} Menit • ${task['priority']}",
          style: const TextStyle(fontFamily: 'SF Pro', color: Color(0xFF64748B)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFFDA4AF)),
          onPressed: () => setState(() => tasks.removeAt(index)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Belum ada tugas.\nMari mulai hari produktifmu!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'SF Pro', height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}