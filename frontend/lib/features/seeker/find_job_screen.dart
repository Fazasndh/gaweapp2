import 'package:flutter/material.dart';
import 'package:gawe_app/features/company/add_job_screen.dart';

class FindJobScreen extends StatelessWidget {
  const FindJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bagian: Data Popular Searches
    final List<String> popularSearches = [
      "Software developer fresher",
      "Worker From Home",
      "Driver",
      "hr frsher",
      "softwere testing",
      "seles executive",
      "business analyst",
      "receptionist",
      "data analyst",
      "seo executive"
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Find Job", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [Icon(Icons.more_vert, color: theme.iconTheme.color), const SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian: Kartu Search Utama
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]
              ),
              child: Column(
                children: [
                  _buildSearchInput(hint: "job title, keywords, or company", icon: Icons.search, theme: theme),
                  const SizedBox(height: 16),
                  _buildSearchInput(hint: "Enter city or locality", icon: Icons.location_on, theme: theme),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddJobScreen ()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B51E0), // Ungu sesuai gambar
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('SEARCH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Bagian: Section Popular Searches
            Text("Popular Searches", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: popularSearches.map((search) {
                return _buildSearchChip(text: search, theme: theme, context: context);
              }).toList(),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput({required String hint, required IconData icon, required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8)
      ),
      child: TextField(
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 16),
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.grey.shade400, size: 24),
        ),
      ),
    );
  }

  Widget _buildSearchChip({required String text, required ThemeData theme, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddJobScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.08), // Transparan sesuai palet
          borderRadius: BorderRadius.circular(30)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: theme.primaryColor, size: 18),
            const SizedBox(width: 10),
            Text(
              text, 
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }
}