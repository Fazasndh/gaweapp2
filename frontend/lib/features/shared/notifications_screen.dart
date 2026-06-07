import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bagian: Data Notifikasi 
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Apply Success",
        "description": "You has apply an job in Queenify Group as UI Designer",
        "time": "10h ago",
        "dotColor": const Color(0xFF26A69A), // Cyan/Teal
      },
      {
        "title": "Interview Calls",
        "description": "Congratulations! You have interview calls",
        "time": "9h ago",
        "dotColor": null, // Tidak ada titik di mockup
      },
      {
        "title": "Apply Success",
        "description": "You has apply an job in Queenify Group as UI Designer",
        "time": "8h ago",
        "dotColor": const Color(0xFF9B51E0), // Purple
      },
      {
        "title": "Complete your profile",
        "description": "Please verify your profile information to continue using this app",
        "time": "4h ago",
        "dotColor": const Color(0xFF26A69A), // Cyan/Teal
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Bagian: AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text("Notifications", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      // Bagian: Body menggunakan ListView agar bisa di-scroll tanpa Overflow
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotificationCard(
            title: notif["title"],
            description: notif["description"],
            time: notif["time"],
            dotColor: notif["dotColor"],
            theme: theme,
          );
        },
      ),
    );
  }

  // Bagian: Komponen Card UI Notifikasi
  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    required Color? dotColor,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Judul & Indikator Titik
          Row(
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 12, 
                  height: 12,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                title, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Deskripsi
          Text(
            description, 
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, height: 1.5, fontSize: 15)
          ),
          const SizedBox(height: 16),
          
          // Baris Waktu & Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time, 
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14)
              ),
              GestureDetector(
                onTap: () {
                  // Aksi ketika di-klik "Mark as read"
                },
                child: const Text(
                  "Mark as read", 
                  style: TextStyle(color: Color(0xFF9B51E0), fontWeight: FontWeight.w600, fontSize: 14)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}