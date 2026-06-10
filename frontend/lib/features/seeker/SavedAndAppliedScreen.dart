import 'package:flutter/material.dart';
import '/services/api_service.dart';

class SavedAndAppliedScreen extends StatefulWidget {
  final int initialIndex;

  const SavedAndAppliedScreen({
    super.key,
    required this.initialIndex,
  });

  @override
  State<SavedAndAppliedScreen> createState() => _SavedAndAppliedScreenState();
}

class _SavedAndAppliedScreenState extends State<SavedAndAppliedScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0, // Disesuaikan karena ada leading icon
          // TOMBOL BACK DINAMIS (Hitam saat terang, putih saat gelap)
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "My Activity",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.work_outline),
                text: "Applied",
              ),
              Tab(
                icon: Icon(Icons.bookmark_border),
                text: "Saved",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildJobListView(isApplied: true),
            _buildJobListView(isApplied: false),
          ],
        ),
      ),
    );
  }

  Widget _buildJobListView({required bool isApplied}) {
    return FutureBuilder<List<dynamic>?>(
      future: isApplied ? _apiService.getAppliedJobs() : _apiService.getSavedJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Failed to load data",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isApplied ? Icons.work_outline : Icons.bookmark_border,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  isApplied ? "No applications yet" : "No saved jobs yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isApplied
                      ? "Jobs you apply for will appear here"
                      : "Jobs you save will appear here",
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final job = item['job']; // Bisa jadi null jika relasi di server rusak

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.work,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PENGAMANAN DATA: Gunakan job? untuk menghindari crash null-pointer
                        Text(
                          job?['title'] ?? 'Posisi Tidak Tersedia',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${job?['company_name'] ?? 'Perusahaan'} • ${job?['location'] ?? 'Lokasi'}",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isApplied
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['status'] ?? 'Pending',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.bookmark,
                          color: Theme.of(context).primaryColor,
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}