import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String activeProfile;

  ChatScreen({required this.activeProfile});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Map<String, List<String>> _profileMessages = {
    'Personal': ['કેમ છો બધા?'],
    'Business': ['નવા ઓર્ડરની વિગતો મોકલો.'],
    'Creator': ['કોલાબોરેશન માટે મેસેજ કરો.'],
    'Private': ['ખાનગી ચેટ રૂમ.'],
  };

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _profileMessages[widget.activeProfile]?.add(_controller.text.trim());
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentMessages = _profileMessages[widget.activeProfile] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('ચેટ (${widget.activeProfile})'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: currentMessages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Text(
                      currentMessages[index],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '${widget.activeProfile} માંથી મેસેજ લખો...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
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
