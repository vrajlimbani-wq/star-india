import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String targetUid;

  const UserProfileScreen({super.key, required this.targetUid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _toggleFollow(bool isFollowing) async {
    if (_currentUid.isEmpty || widget.targetUid == _currentUid) return;

    final currentRef = FirebaseFirestore.instance.collection('users').doc(_currentUid);
    final targetRef = FirebaseFirestore.instance.collection('users').doc(widget.targetUid);

    if (isFollowing) {
      await currentRef.collection('following').doc(widget.targetUid).delete();
      await targetRef.collection('followers').doc(_currentUid).delete();
    } else {
      await currentRef.collection('following').doc(widget.targetUid).set({
        'followedAt': FieldValue.serverTimestamp(),
      });
      await targetRef.collection('followers').doc(_currentUid).set({
        'followerAt': FieldValue.serverTimestamp(),
      });
    }
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.targetUid)
                      .collection(collectionName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('કોઈ $title મળ્યા નથી.', style: const TextStyle(color: Colors.grey)));
                    }

                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final uId = docs[index].id;
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(uId).get(),
                          builder: (context, userSnap) {
                            String name = 'Star User';
                            String city = 'Star India';
                            if (userSnap.hasData && userSnap.data!.exists) {
                              final uData = userSnap.data!.data() as Map<String, dynamic>;
                              name = uData['fullName'] ?? uData['name'] ?? 'Star User';
                              city = uData['city'] ?? 'Star India';
                            }
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1E3A8A),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(city),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () {
                                Navigator.pop(ctx);
                                if (uId != widget.targetUid) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfileScreen(targetUid: uId),
                                    ),
                                  );
                                }
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

  Widget _buildStatCounter(String subCollection, String label) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.targetUid)
          .collection(subCollection)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        );
      },
    );
  }

  Widget _buildUserPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('authorUid', isEqualTo: widget.targetUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Text(
                'હજુ કોઈ પોસ્ટ મૂકી નથી.',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          );
        }

        final posts = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postData = posts[index].data() as Map<String, dynamic>;
            final content = postData['content'] ?? '';
            final likesCount = (postData['likes'] as List?)?.length ?? 0;

            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text('$likesCount likes', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = _currentUid == widget.targetUid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.targetUid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('યુઝર પ્રોફાઇલ મળી નથી.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = data['fullName'] ?? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          final profession = data['designation'] ?? data['professionType'] ?? 'Member';
          final city = data['city'] ?? '';
          final bio = data['bio'] ?? '';
          final education = data['education'] ?? '';
          final hobbies = data['hobbies'] ?? '';
          final isContactVisible = data['isContactVisible'] ?? false;
          final phone1 = data['phone1'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFF1E3A8A),
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName.isNotEmpty ? fullName : 'Star User',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profession,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                      if (city.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(city, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => _showUserList('followers', 'Followers'),
                            child: _buildStatCounter('followers', 'Followers'),
                          ),
                          Container(height: 25, width: 1, color: Colors.grey.shade300),
                          GestureDetector(
                            onTap: () => _showUserList('following', 'Following'),
                            child: _buildStatCounter('following', 'Following'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!isOwnProfile)
                        Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_currentUid)
                                    .collection('following')
                                    .doc(widget.targetUid)
                                    .snapshots(),
                                builder: (context, followSnap) {
                                  final isFollowing = followSnap.hasData && followSnap.data!.exists;

                                  return ElevatedButton(
                                    onPressed: () => _toggleFollow(isFollowing),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFollowing ? Colors.grey.shade200 : const Color(0xFF1E3A8A),
                                      foregroundColor: isFollowing ? Colors.black87 : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(
                                      isFollowing ? 'Following' : 'Follow',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        peerUid: widget.targetUid,
                                        peerName: fullName.isNotEmpty ? fullName : 'Star User',
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Message',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (education.isNotEmpty || hobbies.isNotEmpty || (isContactVisible && phone1.isNotEmpty))
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (education.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.school, size: 18, color: Color(0xFF1E3A8A)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('અભ્યાસ: $education', style: const TextStyle(fontSize: 13.5))),
                              ],
                            ),
                          ),
                        if (hobbies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.interests, size: 18, color: Color(0xFF1E3A8A)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('શોખ: $hobbies', style: const TextStyle(fontSize: 13.5))),
                              ],
                            ),
                          ),
                        if (isContactVisible && phone1.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 18, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text('સંપર્ક: $phone1', style: const TextStyle(fontSize: 13.5))),
                            ],
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.grid_on, size: 18, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Text(
                        'Posts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildUserPosts(),
              ],
            ),
          );
        },
      ),
    );
  }
}
