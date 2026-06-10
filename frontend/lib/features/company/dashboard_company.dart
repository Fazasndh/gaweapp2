import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gawe_app/services/api_service.dart';
import 'package:gawe_app/features/auth/screens/login.dart';
import 'package:gawe_app/features/company/add_job_screen.dart';
import 'package:gawe_app/features/company/detail_job_screen.dart';
import 'package:gawe_app/features/company/company_applicants_screen.dart';
import 'package:gawe_app/features/company/company_profile_screen.dart'; 
import 'package:gawe_app/features/shared/settings_screen.dart'; 

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});
  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  String _companyName = 'Loading...';
  int _totalApplicantsCount = 0; 

  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _myJobsFuture;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
    _loadApplicantCount(); // Panggil fungsi hitung pelamar
    _myJobsFuture = _apiService.getMyJobs();
  }

  Future<void> _loadCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    String rawName = prefs.getString('user_name') ?? 'Perusahaan';
    if (mounted) {
      setState(() {
        _companyName = rawName;
      });
    }
  }

  // Fungsi untuk menarik data dari API dan menghitung jumlahnya
  Future<void> _loadApplicantCount() async {
    try {
      final applicants = await _apiService.getCompanyApplicants();
      if (mounted) {
        setState(() {
          _totalApplicantsCount = applicants.length;
        });
      }
    } catch (e) {
      print("Error loading applicant count: $e");
    }
  }

  void _refreshJobs() {
    _loadApplicantCount(); // Refresh juga jumlah pelamar saat job diperbarui
    setState(() {
      _myJobsFuture = _apiService.getMyJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
        title: Text(
          'Company Dashboard',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              final success = await _apiService.logout();
              if (!mounted) return;
              
              Navigator.pop(context);

              if (success) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: Icon(Icons.logout, color: theme.iconTheme.color),
          ),
          const SizedBox(width: 10),
        ],
      ),
      // Bungkus dengan RefreshIndicator untuk fitur pull-to-refresh
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshJobs();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),

              Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 15),

              // Kartu Statistik
              Row(
                children: [
                  FutureBuilder<List<dynamic>>(
                    future: _myJobsFuture,
                    builder: (context, snapshot) {
                      int count = snapshot.hasData ? snapshot.data!.length : 0;
                      return _buildStatCard(count.toString(), "Active Jobs", Icons.work_outline, primaryColor, context);
                    },
                  ),
                  const SizedBox(width: 15),
                  _buildStatCard(_totalApplicantsCount.toString(), "Applicants", Icons.people_outline, const Color(0xFFFF9800), context),
                ],
              ),

              const SizedBox(height: 30),
              Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 15),
              _buildQuickActions(context, primaryColor),
              
              const SizedBox(height: 30),
              Text("Your Active Jobs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 15),

              FutureBuilder<List<dynamic>>(
                future: _myJobsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()));
                  } 
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(context, primaryColor);
                  }

                  final jobs = snapshot.data!;
                  return Column(
                    children: jobs.map((job) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.work, color: primaryColor),
                          ),
                          title: Text(job['title'] ?? 'Posisi', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(job['location'] ?? '-'),
                          onTap: () async {
                            final shouldRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CompanyJobDetailScreen(job: job)),
                            );
                            if (shouldRefresh == true) _refreshJobs();
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Widget _buildHeader, _buildStatCard, _buildQuickActions, _buildEmptyState tetap sama)
  
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 4),
            Text(_companyName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: const Icon(Icons.business_center, color: Colors.blueGrey, size: 28),
        ),
      ],
    );
  }

  Widget _buildStatCard(String count, String label, IconData icon, Color iconColor, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 24)),
              ],
            ),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        Row(
          children: [
            _buildActionItem("Add Job", Icons.post_add, primaryColor, context, () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddJobScreen())); _refreshJobs(); }),
            const SizedBox(width: 15),
            _buildActionItem("Applicants", Icons.recent_actors, const Color(0xFF00A884), context, () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CompanyApplicantsScreen())); }),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildActionItem("Company Profile", Icons.domain, const Color(0xFF9B51E0), context, () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CompanyProfileScreen())); }),
            const SizedBox(width: 15),
            _buildActionItem("Settings", Icons.settings, Colors.blueGrey, context, () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color color, BuildContext context, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]),
          child: Column(children: [Icon(icon, color: color, size: 32), const SizedBox(height: 12), Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14))]),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color primaryColor) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1)), child: Column(children: [Icon(Icons.work_off_outlined, size: 60, color: Colors.grey.shade400), const SizedBox(height: 15), Text("No active jobs yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)), const SizedBox(height: 8), Text("Post a new job to start receiving applications from great candidates.", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)), const SizedBox(height: 20), ElevatedButton.icon(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddJobScreen())); _refreshJobs(); }, icon: const Icon(Icons.add, color: Colors.white), label: const Text("Post a Job", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))]));
  }
}