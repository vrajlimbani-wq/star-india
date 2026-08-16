import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _toggleLike(String postId, List<dynamic> likes) async {
    if (_currentUid.isEmpty) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (likes.contains(_currentUid)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([_currentUid]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([_currentUid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Star India Feed',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'હજુ કોઈ પોસ્ટ નથી.\nનવી પોસ્ટ ઉમેરવા માટે + બટન દબાવો.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            );
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final postId = post.id;
              final authorUid = data['authorUid'] ?? '';
              final authorName = data['authorName'] ?? 'Star User';
              final authorProfession = data['authorProfession'] ?? '';
              final content = data['content'] ?? '';
              final likes = List<dynamic>.from(data['likes'] ?? []);
              final isLiked = likes.contains(_currentUid);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Profile Header
                      InkWell(
                        onTap: () {
                          if (authorUid.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(targetUid: authorUid),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF1E3A8A),
                              child: Text(
                                authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  if (authorProfession.isNotEmpty)
                                    Text(
                                      authorProfession,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Post Content Text
                      Text(
                        content,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 12),

                      // Action Bar (Like Counter & Button)
                      Divider(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey.shade600,
                              size: 22,
                            ),
                            onPressed: () => _toggleLike(postId, likes),
                          ),
                          Text(
                            '${likes.length} Likes',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
