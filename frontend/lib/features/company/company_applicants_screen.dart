import 'package:flutter/material.dart';
import '/services/api_service.dart';
import 'applicant_detail.dart';

class CompanyApplicantsScreen extends StatefulWidget {
  const CompanyApplicantsScreen({super.key});

  @override
  State<CompanyApplicantsScreen> createState() =>
      _CompanyApplicantsScreenState();
}

class _CompanyApplicantsScreenState extends State<CompanyApplicantsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _applicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    try {
      final data = await _apiService.getCompanyApplicants();
      if (mounted) {
        setState(() {
          _applicants = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi dinamis untuk warna status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'reviewed':
        return Colors.blue;
      case 'interview':
        return Colors.orange;
      default:
        return Colors.grey.shade600; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Applicants",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applicants.isEmpty
          ? _buildEmptyState(theme)
          : _buildApplicantList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Belum Ada Pelamar",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Pelamar untuk lowongan Anda akan muncul di sini.",
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _fetchApplicants,
      color: theme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _applicants.length,
        itemBuilder: (context, index) {
          final application = _applicants[index];
          final seeker = application['user'];
          final job = application['job'];
          final status = application['status'] ?? 'pending';

          // Ambil inisial nama pelamar
          String initials = "U";
          if (seeker != null && seeker['name'] != null) {
            initials = seeker['name'].toString().substring(0, 1).toUpperCase();
          }

          return GestureDetector(
            onTap: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ApplicantDetailScreen(application: application),
                ),
              );
              if (refresh == true) {
                _fetchApplicants();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seeker != null ? seeker['name'] : 'Unknown Seeker',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Applied for: ${job != null ? job['title'] : 'Unknown Job'}",
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toString().toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
