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
  final ScrollController _scrollController = ScrollController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchMessages();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

Future<void> fetchMessages() async {
  try {
    final res = await http.get(
      Uri.parse("${ApiService.apiBase}/chat/${widget.jobId}"),
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      setState(() {
        messages = decoded;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  } catch (_) {}
}

  Future<void> sendMessage() async {
    final content = controller.text.trim();
    if (content.isEmpty) return;

    controller.clear();

    final response = await http.post(
      Uri.parse("${ApiService.apiBase}/chat/send"),
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

    fetchMessages();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender_id'] == widget.currentUserId;

                // ✅ Safe toString() instead of "as String"
                final rawTime = msg['sent_at'] ?? msg['created_at'];
                final timestamp = rawTime != null
                    ? DateTime.tryParse(rawTime.toString())
                    : null;

                final timeStr = timestamp != null
                    ? "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}"
                    : '';

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            msg['content'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (timeStr.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? Colors.white70
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -1),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white, size: 18),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}