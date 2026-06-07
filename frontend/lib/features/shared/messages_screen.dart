import 'package:flutter/material.dart';

// Bagian: Import Absolut ke halaman Chat Detail
import 'package:gawe_app/features/shared/chat_detail_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bagian: Data Dummy List Pesan
    final List<Map<String, dynamic>> messages = [
      {"name": "Sam Verdinand", "message": "OK. Lorem ipsum dolor sect...", "time": "2m ago", "status": "Read", "isRead": true},
      {"name": "Freddie Ronan", "message": "Roger that sir, thankyou", "time": "2m ago", "status": "Pending", "isRead": false},
      {"name": "Ethan Jacoby", "message": "Lorem ipsum dolor", "time": "2m ago", "status": "Read", "isRead": true},
      {"name": "Alfie Mason", "message": "Lorem ipsum dolor sect...", "time": "2m ago", "status": "Pending", "isRead": false},
      {"name": "Archie Parker", "message": "OK. Lorem ipsum dolor sect...", "time": "2m ago", "status": "Pending", "isRead": false},
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
            decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text("Messages", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.more_vert, color: theme.iconTheme.color), onPressed: () {}), const SizedBox(width: 10)],
      ),
      // Bagian: Body
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Bagian: Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Search message here...",
                  hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 15),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: theme.textTheme.bodyMedium?.color),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Bagian: List Pesan
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return GestureDetector(
                  onTap: () {
                    // Navigasi ke ruang obrolan saat di-klik
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(chatName: msg["name"])));
                  },
                  child: _buildMessageItem(
                    name: msg["name"],
                    message: msg["message"],
                    time: msg["time"],
                    status: msg["status"],
                    isRead: msg["isRead"],
                    theme: theme,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Bagian: Komponen Item List Pesan
  Widget _buildMessageItem({required String name, required String message, required String time, required String status, required bool isRead, required ThemeData theme}) {
    final statusColor = isRead ? const Color(0xFF007BFF) : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 28, backgroundColor: theme.cardColor, child: Icon(Icons.person, size: 35, color: theme.textTheme.bodyMedium?.color)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                    Row(
                      children: [
                        Text(status, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 4),
                        Icon(isRead ? Icons.done_all : Icons.check, color: statusColor, size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(message, style: TextStyle(fontSize: 15, color: theme.textTheme.bodyLarge?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(time, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}