import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _userLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _fetchLanguage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLanguage() async {
    if (_currentUid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(_currentUid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userLanguage = doc.data()?['language'] ?? 'en';
          });
        }
      } catch (_) {}
    }
  }

  String _t(String en, String gu, String hi) {
    if (_userLanguage == 'gu') return gu;
    if (_userLanguage == 'hi') return hi;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUid.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _t('Chats', 'ચેટ્સ', 'चैट्स'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
        body: Center(
          child: Text(
            _t('Please log in to view chats', 'ચેટ્સ જોવા માટે કૃપા કરીને લોગિન કરો', 'चैट्स देखने के लिए कृपया लॉगिन करें'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _t('Chats', 'ચેટ્સ', 'चैट्स'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: _t('Search user to chat...', 'ચેટ કરવા યુઝર શોધો...', 'चैट के लिए यूजर खोजें...'),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildUserSearchResults()
                : _buildRecentChatsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(_t('No users found', 'કોઈ યુઝર મળ્યા નથી', 'कोई यूजर नहीं मिला')));
        }

        final filteredUsers = snapshot.data!.docs.where((doc) {
          if (doc.id == _currentUid) return false;
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['fullName'] ?? data['name'] ?? '').toString().toLowerCase();
          final phone = (data['phone'] ?? '').toString();
          return name.contains(_searchQuery) || phone.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(child: Text(_t('No users found', 'કોઈ યુઝર મળ્યા નથી', 'कोई यूजर नहीं मिला')));
        }

        return ListView.separated(
          itemCount: filteredUsers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = filteredUsers[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = data['fullName'] ?? data['name'] ?? 'Star Member';
            final photo = data['photoUrl'] ?? '';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1E3A8A),
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1E3A8A)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      peerId: doc.id,
                      peerName: name,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentChatsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: _currentUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${_t("Error loading chats", "ચેટ લોડ કરવામાં ભૂલ", "चैट लोड करने में त्रुटि")}: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  _t('No chats yet', 'હજુ કોઈ ચેટ નથી', 'अभी कोई चैट नहीं है'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  _t('Search user above to start chatting.', 'ચેટ શરૂ કરવા ઉપર યુઝર સર્ચ કરો.', 'बातचीत शुरू करने के लिए ऊपर यूजर सर्च करें।'),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.separated(
          itemCount: chatDocs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chatData = chatDocs[index].data() as Map<String, dynamic>;
            final List<dynamic> participants = chatData['participants'] ?? [];
            
            final peerId = participants.firstWhere(
              (id) => id != _currentUid,
              orElse: () => '',
            );

            final lastMessage = chatData['lastMessage'] ?? _t('No messages yet', 'કોઈ મેસેજ નથી', 'कोई संदेश नहीं');

            if (peerId.isEmpty) return const SizedBox();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(peerId).get(),
              builder: (context, userSnapshot) {
                String peerName = 'Star Member';
                String peerPhoto = '';
                if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  peerName = userData?['fullName'] ?? userData?['name'] ?? 'Star Member';
                  peerPhoto = userData?['photoUrl'] ?? '';
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1E3A8A),
                    backgroundImage: peerPhoto.isNotEmpty ? NetworkImage(peerPhoto) : null,
                    child: peerPhoto.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  title: Text(peerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          peerId: peerId,
                          peerName: peerName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
