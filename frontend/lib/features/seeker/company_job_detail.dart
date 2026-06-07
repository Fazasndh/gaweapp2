import 'package:flutter/material.dart';

class CompanyJobDetailScreen extends StatefulWidget {
  final String companyName;
  final String jobTitle;

  const CompanyJobDetailScreen({super.key, required this.companyName, required this.jobTitle});

  @override
  State<CompanyJobDetailScreen> createState() => _CompanyJobDetailScreenState();
}

class _CompanyJobDetailScreenState extends State<CompanyJobDetailScreen> {
  int _selectedTab = 0;

  void _showApplyBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 16),
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 30),
              _buildApplyTextField(hint: "User Name", theme: theme),
              const SizedBox(height: 20),
              _buildApplyTextField(hint: "Email Address", theme: theme),
              const SizedBox(height: 20),
              _buildApplyTextField(hint: "Phone number", theme: theme),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplyTextField({required String hint, required ThemeData theme}) {
    return TextField(
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade600)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.iconTheme.color), onPressed: () => Navigator.pop(context)),
        title: Text(widget.jobTitle, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(height: 180, width: double.infinity, color: theme.cardColor, child: Icon(Icons.location_city, size: 60, color: theme.textTheme.bodyMedium?.color)),
                Positioned(
                  bottom: -35,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: theme.scaffoldBackgroundColor, width: 3)),
                    child: const Icon(Icons.business, color: Colors.white, size: 35),
                  ),
                )
              ],
            ),
            const SizedBox(height: 45),
            Text(widget.jobTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            Text(widget.companyName, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 16)),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(color: theme.cardColor, border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2)))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildTab(0, "ABOUT US", theme), _buildTab(1, "RATINGS", theme), _buildTab(2, "REVIEW", theme)]),
            ),
            Padding(padding: const EdgeInsets.all(20), child: _buildTabContent(theme)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: theme.cardColor, border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2)))),
        child: ElevatedButton(
          onPressed: () => _showApplyBottomSheet(context),
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('APPLY NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title, ThemeData theme) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isActive ? theme.primaryColor : Colors.transparent, width: 3))),
        child: Text(title, style: TextStyle(color: isActive ? theme.primaryColor : theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    if (_selectedTab == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 10),
          Text("Kami mencari talenta terbaik untuk bergabung di ${widget.companyName}.", style: TextStyle(height: 1.5, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 20),
          Text("Requirements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 10),
          Text("• Pengalaman minimal 1 tahun\n• Menguasai Flutter & Dart", style: TextStyle(height: 1.8, color: theme.textTheme.bodyLarge?.color)),
        ],
      );
    } else if (_selectedTab == 1) {
      return Column(children: [Text("4.8", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)), Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.orange)))]);
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
          child: Text("Lingkungan kerja sangat suportif dan menantang.", style: TextStyle(fontSize: 13, height: 1.4, color: theme.textTheme.bodyLarge?.color)),
        ),
      );
    }
  }
}