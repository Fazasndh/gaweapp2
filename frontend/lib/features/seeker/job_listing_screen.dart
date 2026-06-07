import 'package:flutter/material.dart';
import 'company_job_detail.dart';

class JobListingScreen extends StatelessWidget {
  final String title;

  const JobListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Ambil tema saat ini
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> jobs = [
      {"company": "Cosax Studios", "title": "Junior Software Engineer", "color": const Color(0xFF9B51E0)},
      {"company": "GoTo Group", "title": "Software Engineer", "color": const Color(0xFF007BFF)},
      {"company": "Agate", "title": "Graphic Designer", "color": const Color(0xFF388E3C)},
      {"company": "Shopee", "title": "Data Scientist", "color": const Color(0xFF00838F)},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Dinamis
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color), // Dinamis
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [Icon(Icons.more_vert, color: theme.iconTheme.color), const SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)), // Dinamis
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Search job here...",
                  hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: theme.textTheme.bodyMedium?.color),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // List Pekerjaan
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Cek kalau ini halaman Recent/Search, lempar ke Company Detail
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyJobDetailScreen(
                      companyName: jobs[index]["company"], 
                      jobTitle: jobs[index]["title"]
                    )));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)), // Dinamis
                    child: Row(
                      children: [
                        Container(
                          width: 55, height: 55,
                          decoration: BoxDecoration(color: jobs[index]["color"] as Color, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.donut_large, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(jobs[index]["title"] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor)),
                              const SizedBox(height: 4),
                              Text("Medan, Indonesia", style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text("\$500 - \$1,000", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.bodyLarge?.color)),
                            ],
                          ),
                        ),
                        Icon(Icons.bookmark_border, color: theme.textTheme.bodyMedium?.color),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}