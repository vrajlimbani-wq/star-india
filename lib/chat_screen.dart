import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Star India Support',
      'msg': 'નમસ્તે, આપનું સ્વાગત છે.',
      'time': '10:45 AM',
      'unread': '1',
      'isOnline': true,
    },
    {
      'name': 'ગુજરાત ક્રિએટર્સ ગ્રૂપ',
      'msg': 'નવી પોસ્ટ શેર કરવામાં આવી છે.',
      'time': '09:12 AM',
      'unread': '3',
      'isOnline': false,
    },
    {
      'name': 'Social Updates',
      'msg': 'તમારી Reel ટ્રેન્ડિંગમાં છે.',
      'time': 'Yesterday',
      'unread': '0',
      'isOnline': false,
    },
  ];

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  // Active Chat Screen ખોલવા માટે
  void _openChatRoom(String chatName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(title: chatName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: const Color(0xFF1E3A8A),
        backgroundColor: Colors.white,
        onRefresh: _handleRefresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _chats.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final c = _chats[index];
            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: Text(
                      c['name'][0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (c['isOnline'] == true)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                c['msg'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c['unread'] != '0' ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: c['unread'] != '0' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    c['time'],
                    style: TextStyle(
                      fontSize: 11,
                      color: c['unread'] != '0' ? Colors.green : Colors.grey,
                      fontWeight: c['unread'] != '0' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (c['unread'] != '0')
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(
                        c['unread'],
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              onTap: () => _openChatRoom(c['name']),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openChatRoom("New Chat"),
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}

// ચેટિંગ રૂમ વ્યુ
class ChatRoomScreen extends StatefulWidget {
  final String title;
  const ChatRoomScreen({super.key, required this.title});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<String> _messages = ["નમસ્તે, Star India માં આપનું સ્વાગત છે!"];

  void _sendMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(_msgController.text.trim());
        _msgController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(_messages[index], style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'મેસેજ લખો...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1E3A8A)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
