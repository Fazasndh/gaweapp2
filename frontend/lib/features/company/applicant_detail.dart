import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '/services/api_service.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final dynamic application;
  const ApplicantDetailScreen({super.key, required this.application});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application['status'] ?? 'pending';
  }

  // Fungsi launcher aman (Langsung tembak eksekusi tanpa canLaunch jika channel bermasalah)
  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CV tidak tersedia dari database")),
      );
      return;
    }
    
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuka CV: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seeker = widget.application['user'] ?? {};
    final profile = seeker['seeker_profile'] ?? {}; 

    return Scaffold(
      backgroundColor: Colors.white, // Memaksa background putih agar konsisten
      
      // APPBAR DISESUAIKAN PERSIS SEPERTI GAMBAR 2 (Polos, Rata Kiri, Tanpa Bayangan)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Pelamar", 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
      ),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Profile Polos Rata Kiri
                _buildHeader(theme, seeker),
                
                // 2. Info Detail & Kontak
                const SizedBox(height: 30),
                _buildSectionTitle("Informasi Kontak"),
                _buildInfoTile(Icons.phone, profile['phone'] ?? 'Tidak ada nomor', theme),
                _buildInfoTile(Icons.email, seeker['email'] ?? '-', theme),

                // 3. Skills Paragraf Teks Full
                const SizedBox(height: 25),
                _buildSectionTitle("Keahlian"),
                const SizedBox(height: 10),
                _buildSkills(profile['skills'] ?? '', theme),

                // 4. CV/Resume Button
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchURL(widget.application['resume_url']),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text("Buka CV/Resume", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),

                // 5. Action Buttons (Update Status)
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 10),
                _buildSectionTitle("Aksi Keputusan HRD"),
                const SizedBox(height: 20),
                _buildActionButtons(theme),
              ],
            ),
          ),
    );
  }

  // HEADER POLOS TANPA BACKGROUND WARNA/KOTAK
  Widget _buildHeader(ThemeData theme, dynamic seeker) {
    return Center( // <--- MEMBUAT SEMUA ELEMEN RATA TENGAH
      child: Column(
        children: [
          CircleAvatar(
            radius: 45, // Diperbesar sedikit agar lebih menonjol
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Text(
              seeker['name'] != null ? seeker['name'][0].toUpperCase() : 'U', 
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: theme.primaryColor)
            )
          ),
          const SizedBox(height: 16),
          Text(
            seeker['name'] ?? 'Unknown User', 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(20) // Dibuat lebih membulat
            ),
            child: Text(
              "Status: ${_currentStatus.toUpperCase()}", 
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.primaryColor)
            ),
          ),
        ],
      ),
    );
  }

  // SKILL BERBENTUK PARAGRAF TEKS FULL
  Widget _buildSkills(String skills, ThemeData theme) {
    if (skills.trim().isEmpty) {
      return const Text(
        "Belum ada data keahlian", 
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
      );
    }

    return Text(
      skills.trim(),
      style: const TextStyle(
        fontSize: 14, 
        height: 1.6, 
        color: Colors.black87,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title, 
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
  );

  Widget _buildInfoTile(IconData icon, String text, ThemeData theme) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: theme.primaryColor, size: 20)
    ),
    title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
    dense: true,
  );

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _btn("Reviewed", Colors.blue, 'reviewed')),
          const SizedBox(width: 10),
          Expanded(child: _btn("Interview", Colors.orange, 'interview')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _btn("Terima Kerja", Colors.green, 'accepted')),
          const SizedBox(width: 10),
          Expanded(child: _btn("Tolak", Colors.red, 'rejected')),
        ]),
      ],
    );
  }

  Widget _btn(String label, Color color, String status) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
    ),
    onPressed: () async {
      setState(() => _isProcessing = true);
      final success = await _apiService.updateApplicantStatus(widget.application['id'], status);
      if (mounted) {
        setState(() { if(success) _currentStatus = status; _isProcessing = false; });
      }
    },
    child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );
}