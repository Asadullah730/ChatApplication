import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  final String myId;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.myId,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel channel;
  final TextEditingController messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

  channel = WebSocketChannel.connect(
  Uri.parse("ws://localhost:8080"),
);

    // Register user
    channel.sink.add(jsonEncode({
      "type": "register",
      "userId": widget.myId,
    }));

    // Listen incoming messages
    channel.stream.listen((data) {
      final decoded = jsonDecode(data);

      if (decoded["type"] == "message") {
        setState(() {
          messages.add(decoded);
        });
      }
    });
  }

  void sendMessage() {
    if (messageController.text.isEmpty) return;

    final msgText = messageController.text;

    // Send to server
    channel.sink.add(jsonEncode({
      "type": "message",
      "from": widget.myId,
      "to": widget.receiverId,
      "text": msgText,
    }));

    // Show instantly on sender UI
    setState(() {
      messages.add({
        "type": "message",
        "from": widget.myId,
        "text": msgText,
        "time": DateTime.now().toIso8601String(),
      });
    });

    messageController.clear();
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat (${widget.myId} → ${widget.receiverId})"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg["from"] == widget.myId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send, color: Colors.blue),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
} 