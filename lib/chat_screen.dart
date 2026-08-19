import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_screen.dart'; // આ ફાઈલ આપણે પછી બનાવીશું

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // માત્ર એ જ ચેટ્સ બતાવશે જેમાં કરંટ યુઝર પાર્ટિસિપન્ટ છે
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No active chats yet."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chat = snapshot.data!.docs[index];
              final participants = List<String>.from(chat['participants']);
              final peerId = participants.firstWhere((id) => id != currentUid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(peerId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const ListTile(title: Text("Loading..."));
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(child: Text(userData['fullName'][0])),
                    title: Text(userData['fullName']),
                    subtitle: Text(chat['lastMessage'] ?? 'Start chatting...'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(peerId: peerId, peerName: userData['fullName']),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
