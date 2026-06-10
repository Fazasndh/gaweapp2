import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isBookmarked = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.job['is_saved'] == true || widget.job['is_saved'] == 1;
  }

  // --- LOGIKA SAVE/BOOKMARK PEKERJAAN ---
  Future<void> _toggleBookmark() async {
    setState(() => _isBookmarked = !_isBookmarked);

    final int jobId = widget.job['id'];

    try {
      final result = await ApiService().toggleSaveJob(jobId);
      if (result['statusCode'] != 200 && result['statusCode'] != 201) {
        // Jika server menolak, kembalikan UI ke semula (Revert)
        setState(() => _isBookmarked = !_isBookmarked);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isBookmarked = !_isBookmarked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan jaringan.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- LOGIKA APPLY PEKERJAAN ---
  Future<void> _applyJob() async {
    final int jobId = widget.job['id']; 
    setState(() => _isApplying = true);

    try {
      final result = await ApiService().applyJob(jobId);

      if (result['statusCode'] == 201) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Berhasil melamar!'), backgroundColor: Colors.green));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Gagal mengirim lamaran.'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan jaringan atau server.'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _showApplyConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Konfirmasi Lamaran", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "Apakah Anda yakin ingin mengirim profil dan resume Anda untuk posisi ini?",
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.pop(context); 
                _applyJob();            
              },
              child: const Text("Ya, Kirim", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final job = widget.job;

    final companyName = job['user']?['name'] ?? job['company_name'] ?? 'Perusahaan Rahasia';
    final salary = job['salary_range'] ?? 'Gaji Rahasia';
    final location = job['location'] ?? job['address'] ?? 'Remote';
    final jobType = job['job_type'] ?? 'Contract';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Lowongan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      
      // BOTTOM NAVIGATION (TOMBOL APPLY & SAVE)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(14)),
                child: IconButton(
                  icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_outline, color: _isBookmarked ? primaryColor : Colors.grey.shade600, size: 28),
                  onPressed: _toggleBookmark, // Menggunakan logika optimistik baru
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isApplying ? null : _showApplyConfirmationDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _isApplying
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Apply Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER LOWONGAN (DENGAN CHIPS INFORMASI)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 30),
              color: primaryColor.withOpacity(0.05),
              child: Column(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: primaryColor, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.work, color: Colors.white, size: 35),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    job['title'] ?? 'Posisi Tidak Diketahui',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(companyName, style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  
                  // INFORMASI RAPI DALAM BENTUK KOTAK (CHIPS)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildInfoChip(Icons.location_on, location, theme),
                      _buildInfoChip(Icons.access_time, jobType, theme),
                      _buildInfoChip(Icons.monetization_on, salary, theme),
                    ],
                  ),
                ],
              ),
            ),

            // KONTEN DESKRIPSI SAJA
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Job Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    job['description'] ?? 'Tidak ada deskripsi rinci untuk pekerjaan ini.',
                    style: TextStyle(fontSize: 15, height: 1.6, color: theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN UNTUK MEMBUAT KOTAK INFORMASI (CHIP)
  Widget _buildInfoChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}