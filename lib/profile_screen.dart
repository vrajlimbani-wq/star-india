import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';
import 'profile_edit_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showUserList(String collectionName, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUid)
                      .collection(collectionName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('કોઈ $title મળ્યા નથી.'));
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final targetUid = docs[index].id;
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(targetUid).get(),
                          builder: (context, userSnap) {
                            String name = 'Star User';
                            if (userSnap.hasData && userSnap.data!.exists) {
                              final uData = userSnap.data!.data() as Map<String, dynamic>;
                              name = uData['fullName'] ?? uData['name'] ?? 'Star User';
                            }
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1E3A8A),
                                child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserProfileScreen(targetUid: targetUid)),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String subCollection, String label) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_currentUid).collection(subCollection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Column(
          children: [
            Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        );
      },
    );
  }

  Widget _buildPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').where('authorUid', isEqualTo: _currentUid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('તમે હજુ કોઈ પોસ્ટ મૂકી નથી.', style: TextStyle(color: Colors.grey))),
          );
        }
        final posts = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final p = posts[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(p['content'] ?? '', style: const TextStyle(fontSize: 14)),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUid.isEmpty) {
      return const Scaffold(body: Center(child: Text('યુઝર લૉગિન નથી.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Profile', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _signOut(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_currentUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['fullName'] ?? 'Star Account';
          final profession = data['designation'] ?? 'Star Member';
          final bio = data['bio'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 32, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(profession, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(bio, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(onTap: () => _showUserList('followers', 'Followers'), child: _buildStat('followers', 'Followers')),
                    GestureDetector(onTap: () => _showUserList('following', 'Following'), child: _buildStat('following', 'Following')),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    child: const Text('પ્રોફાઇલ એડિટ કરો'),
                    onPressed: () => ProfileEditSheet.open(context, _currentUid, data),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('મારી પોસ્ટ્સ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const Divider(),
                _buildPosts(),
              ],
            ),
          );
        },
      ),
    );
  }
}
