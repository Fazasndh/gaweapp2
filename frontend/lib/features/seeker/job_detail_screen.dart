import 'package:flutter/material.dart';

class JobDetailScreen extends StatefulWidget {
  // Menerima suplai data JSON dari layar sebelumnya
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isBookmarked = false;

  void _applyJob() {
    // TODO: Eksekusi tembak API ke tabel applications Laravel
    print("LOG: Mengeksekusi Apply untuk Job ID: ${widget.job['id']}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sistem melamar sedang dalam tahap pengembangan.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final job = widget.job;

    // Logika fallback nama perusahaan
    final companyName = job['user']?['name'] ?? job['company_name'] ?? 'Perusahaan Rahasia';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Lowongan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.iconTheme.color),
            onPressed: () {
              print("Bagikan lowongan");
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      
      // BOTTOM NAVIGATION: AREA AKSI MUTLAK PELAMAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: _isBookmarked ? primaryColor : Colors.grey.shade600,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() => _isBookmarked = !_isBookmarked);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
            // HEADER LOWONGAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: primaryColor.withOpacity(0.05),
              child: Column(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
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
                  Text(
                    companyName,
                    style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(job['location'] ?? 'Lokasi tidak diatur', style: TextStyle(color: Colors.grey.shade600)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("•", style: TextStyle(color: Colors.grey))),
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(job['job_type'] ?? 'Tipe', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),

            // KONTEN DESKRIPSI
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Salary Estimate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(job['salary_range'] ?? 'Gaji dirahasiakan', style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w600)),
                  
                  const SizedBox(height: 25),
                  
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
}