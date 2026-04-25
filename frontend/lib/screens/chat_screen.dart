import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final res = await http.get(
      Uri.parse("http://10.0.2.2:3000/api/chat/${widget.jobId}"),
    );

    if (res.statusCode == 200) {
      setState(() {
        messages = jsonDecode(res.body);
      });
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.isEmpty) return;

    await http.post(
      Uri.parse("http://10.0.2.2:3000/api/chat/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "jobId": widget.jobId,
        "senderId": widget.currentUserId,
        "content": controller.text,
      }),
    );

    controller.clear();
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe =
                    msg['sender_id'] == widget.currentUserId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
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
