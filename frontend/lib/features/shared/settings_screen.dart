import 'package:flutter/material.dart';

import 'package:gawe_app/main.dart'; 

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Map<String, dynamic>> colors = [
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Pink', 'color': Colors.pink},
      {'name': 'Yellow', 'color': Colors.yellow.shade700},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Deep Purple', 'color': Colors.deepPurple},
      {'name': 'Light Blue', 'color': Colors.lightBlue},
      {'name': 'Teal', 'color': Colors.teal},
      {'name': 'Lime', 'color': Colors.lime.shade700},
      {'name': 'Deep Orange', 'color': Colors.deepOrange},
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Settings", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 30),

            // ==========================================
            // BAGIAN 1: LAYOUT THEMES (LIGHT / DARK)
            // ==========================================
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentThemeMode, _) {
                final isDark = currentThemeMode == ThemeMode.dark;
                // Ambil primary color aktif untuk warna judul dan checkbox
                return ValueListenableBuilder<Color>(
                  valueListenable: primaryColorNotifier,
                  builder: (context, primaryColor, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Layout Themes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Gawee comes with 2 main layout themes: Light (default) and Dark:",
                                style: TextStyle(fontSize: 16, height: 1.5, color: theme.textTheme.bodyLarge?.color),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => themeNotifier.value = ThemeMode.light,
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300, width: 2),
                                        ),
                                        alignment: Alignment.bottomLeft,
                                        padding: const EdgeInsets.all(10),
                                        child: !isDark 
                                            ? Icon(Icons.check_box, color: primaryColor) 
                                            : const Icon(Icons.check_box_outline_blank, color: Colors.transparent),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  // KOTAK DARK MODE
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => themeNotifier.value = ThemeMode.dark,
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                        alignment: Alignment.bottomLeft,
                                        padding: const EdgeInsets.all(10),
                                        child: isDark 
                                            ? Icon(Icons.check_box, color: primaryColor) 
                                            : const Icon(Icons.check_box_outline_blank, color: Colors.transparent),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                );
              }
            ),

            const SizedBox(height: 40),

            // ==========================================
            // BAGIAN 2: DEFAULT COLOR THEMES
            // ==========================================
            ValueListenableBuilder<Color>(
              valueListenable: primaryColorNotifier,
              builder: (context, currentColor, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Default Color Themes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: currentColor)),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gawee comes with 12 color themes set.",
                            style: TextStyle(fontSize: 16, height: 1.5, color: theme.textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: colors.map((colorData) {
                              final Color btnColor = colorData['color'];
                              final bool isSelected = currentColor.value == btnColor.value;
                              
                              return GestureDetector(
                                onTap: () => primaryColorNotifier.value = btnColor,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: btnColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected ? Border.all(color: theme.textTheme.bodyLarge!.color!, width: 2) : null,
                                  ),
                                  child: Text(
                                    colorData['name'],
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}