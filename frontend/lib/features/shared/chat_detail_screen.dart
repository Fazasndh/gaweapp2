import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatName;

  const ChatDetailScreen({super.key, required this.chatName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Bagian: State Data Obrolan
  final List<Map<String, dynamic>> _messages = [
    {"text": "Awesome!", "isMe": false, "time": "10:05 AM", "isImage": false},
    {"text": "Like it very much!", "isMe": false, "time": "10:04 AM", "isImage": false},
    {"text": "Nice!", "isMe": false, "time": "10:03 AM", "isImage": false},
    // Pakai placeholder URL untuk gambar kucing biar gak crash
    {"text": "https://cataas.com/cat", "isMe": true, "time": "10:02 AM", "isImage": true},
    {"text": "Hey, look, cutest kitten ever!", "isMe": true, "time": "10:01 AM", "isImage": false},
    {"text": "Hey, Blue Ninja! Glad to see you ;)", "isMe": true, "time": "10:00 AM", "isImage": false},
  ];

  // Bagian: Logika Kirim Pesan & Bot Reply
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, {
        "text": _messageController.text,
        "isMe": true,
        "time": "Now",
        "isImage": false
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulasi Bot ngebales setelah 1.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            "text": "Maaf, ini pesan otomatis. Saya sedang sibuk coding aplikasi Gawee. Nanti saya balas ya! 🚀",
            "isMe": false,
            "time": "Now",
            "isImage": false
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Bagian: AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.chatName, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      // Bagian: Body (Area Chat & Input)
      body: Column(
        children: [
          // Area Chat Bubbles
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Biar pesan terbaru ada di bawah
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg, theme);
              },
            ),
          ),
          // Area Input Bawah
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  // Bagian: Komponen Chat Bubble
  Widget _buildChatBubble(Map<String, dynamic> msg, ThemeData theme) {
    bool isMe = msg["isMe"];
    bool isImage = msg["isImage"];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: isImage ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: isImage ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(msg["text"], width: 200, height: 200, fit: BoxFit.cover),
              )
            : Text(
                msg["text"],
                style: TextStyle(
                  color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
      ),
    );
  }

  // Bagian: Komponen Kolom Input Teks
  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Icon(Icons.camera_alt, color: theme.textTheme.bodyMedium?.color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Message",
                  hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Icon(Icons.send, color: theme.primaryColor, size: 28),
          ),
        ],
      ),
    );
  }
}