import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChatRoom(String targetUid, String targetName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualChatScreen(
          targetUid: targetUid,
          targetName: targetName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('યુઝર લૉગિન નથી.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Chats',
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // સર્ચ બાર
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'યૂઝરનું નામ સર્ચ કરો...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // ચેટ અથવા સર્ચ પરિણામ લિસ્ટ
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildRecentChats(),
          ),
        ],
      ),
    );
  }

  // ૧. સર્ચ કરેલા યૂઝર્સ બતાવવા માટે
  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('કોઈ યૂઝર મળ્યા નથી.'));
        }

        final filteredUsers = snapshot.data!.docs.where((doc) {
          if (doc.id == _currentUid) return false; // પોતાનું નામ ન દેખાય
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['fullName'] ?? data['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(
            child: Text('આ નામથી કોઈ યૂઝર મળ્યા નથી.', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final uData = filteredUsers[index].data() as Map<String, dynamic>;
            final uid = filteredUsers[index].id;
            final name = uData['fullName'] ?? uData['name'] ?? 'Star User';
            final city = uData['city'] ?? 'Star India';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1E3A8A),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(city),
              trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1E3A8A)),
              onTap: () => _openChatRoom(uid, name),
            );
          },
        );
      },
    );
  }

  // ૨. માત્ર જેની સાથે ચેટ થઈ હોય તેવા રિસન્ટ ચેટ્સ બતાવવા માટે
  Widget _buildRecentChats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: _currentUid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_outlined, size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  'હજુ કોઈ સાથે વાતચીત થઈ નથી.',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ઉપર સર્ચ કરીને નવા મિત્રો સાથે ચેટ શરૂ કરો.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatData = chatDocs[index].data() as Map<String, dynamic>;
            final users = List<dynamic>.from(chatData['users'] ?? []);
            final otherUid = users.firstWhere((u) => u != _currentUid, orElse: () => '');
            final lastMessage = chatData['lastMessage'] ?? '';

            if (otherUid.isEmpty) return const SizedBox.shrink();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
              builder: (context, userSnap) {
                String otherName = 'Star User';
                if (userSnap.hasData && userSnap.data!.exists) {
                  final uData = userSnap.data!.data() as Map<String, dynamic>;
                  otherName = uData['fullName'] ?? uData['name'] ?? 'Star User';
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: Text(
                      otherName.isNotEmpty ? otherName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () => _openChatRoom(otherUid, otherName),
                );
              },
            );
          },
        );
      },
    );
  }
}

// વ્યક્તિગત ચેટ સ્ક્રીન
class IndividualChatScreen extends StatefulWidget {
  final String targetUid;
  final String targetName;

  const IndividualChatScreen({
    super.key,
    required this.targetUid,
    required this.targetName,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController _msgController = TextEditingController();

  String get _chatRoomId {
    List<String> ids = [_currentUid, widget.targetUid];
    ids.sort();
    return ids.join('_');
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _currentUid.isEmpty) return;

    _msgController.clear();
    final now = FieldValue.serverTimestamp();

    // ૧. ચેટ રૂમમાં મેસેજ ઉમેરો
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatRoomId)
        .collection('messages')
        .add({
      'senderId': _currentUid,
      'text': text,
      'timestamp': now,
    });

    // ૨. રિસન્ટ ચેટ લિસ્ટ માટે રૂમ અપડેટ કરો
    await FirebaseFirestore.instance.collection('chats').doc(_chatRoomId).set({
      'users': [_currentUid, widget.targetUid],
      'lastMessage': text,
      'lastMessageTime': now,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(targetUid: widget.targetUid),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF1E3A8A),
                child: Text(
                  widget.targetName.isNotEmpty ? widget.targetName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.targetName,
                style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('વાતચીત શરૂ કરવા મેસેજ મોકલો!', style: TextStyle(color: Colors.grey)),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final mData = messages[index].data() as Map<String, dynamic>;
                    final isMe = mData['senderId'] == _currentUid;
                    final text = mData['text'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF1E3A8A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'મેસેજ લખો...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF1E3A8A)),
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
