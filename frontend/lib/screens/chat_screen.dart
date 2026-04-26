import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int jobId;
  final int currentUserId;

  const ChatScreen({
    super.key,
    required this.jobId,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  final TextEditingController controller = TextEditingController();

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchMessages();

    // 🔁 Poll every 2 seconds
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchMessages();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchMessages() async {
    try {
      final res = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/chat/${widget.jobId}"),
      );

      if (res.statusCode == 200) {
        setState(() {
          messages = jsonDecode(res.body);
        });
      }
    } catch (_) {
      // Keep chat screen resilient during polling failures.
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.isEmpty) return;

    final content = controller.text.trim();
    if (content.isEmpty) return;

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/api/chat/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "jobId": widget.jobId,
        "senderId": widget.currentUserId,
        "content": content,
      }),
    );

    if (response.statusCode != 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't send message right now.")),
        );
      }
      return;
    }

    controller.clear();
    fetchMessages();
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeDate = DateTime(time.year, time.month, time.day);

    if (timeDate == today) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (timeDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender_id'] == widget.currentUserId;
                final timestamp = msg['created_at'] != null
                    ? DateTime.tryParse(msg['created_at'] as String)
                    : null;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          msg['content'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      if (timestamp != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Text(
                            _formatMessageTime(timestamp),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: "Type message"),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}
