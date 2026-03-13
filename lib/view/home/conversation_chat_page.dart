import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/home_controller.dart';
import '../../color.dart';

class ConversationChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const ConversationChatPage({Key? key, required this.conversationId, required this.otherUserId, required this.otherUserName}) : super(key: key);

  @override
  _ConversationChatPageState createState() => _ConversationChatPageState();
}

class _ConversationChatPageState extends State<ConversationChatPage> {
  final HomeController _controller = Get.find<HomeController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName), backgroundColor: primaryblue),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _controller.streamConversationMessages(widget.conversationId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryblue));
                }
                final messages = snap.data ?? [];
                if (messages.isEmpty) {
                  return Center(child: Text('لا توجد رسائل بعد', style: TextStyle(color: Colors.grey)));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(w * 0.04),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = (m['senderId'] ?? '') == _controller.userId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: h * 0.02),
                        constraints: BoxConstraints(maxWidth: w * 0.8),
                        padding: EdgeInsets.all(w * 0.04),
                        decoration: BoxDecoration(
                          color: isMe ? primaryblue : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isMe ? 'أنت' : widget.otherUserName, style: TextStyle(color: isMe ? Colors.white : primaryblue, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(m['content'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                            SizedBox(height: 6),
                            Align(alignment: Alignment.bottomRight, child: Text(_formatTime(m['timestamp']), style: TextStyle(color: isMe ? Colors.white70 : Colors.black45, fontSize: 11)))
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -3))]),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                    decoration: BoxDecoration(color: Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(25)),
                    child: TextField(controller: _messageController, decoration: InputDecoration(hintText: 'اكتب رسالتك هنا...', border: InputBorder.none)),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Container(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.circular(20)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final text = _messageController.text.trim();
                        if (text.isEmpty) return;
                        await _controller.sendConversationMessage(widget.conversationId, text);
                        _messageController.clear();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(padding: EdgeInsets.all(w * 0.035), child: Icon(Icons.send, color: Colors.white, size: w * 0.055)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatTime(dynamic ts) {
    try {
      if (ts == null) return '';
      DateTime t;
      if (ts is Timestamp) {
        t = ts.toDate();
      } else if (ts is int) {
        t = DateTime.fromMillisecondsSinceEpoch(ts);
      } else if (ts is String) {
        t = DateTime.tryParse(ts) ?? DateTime.now();
      } else {
        return '';
      }
      return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }
}
