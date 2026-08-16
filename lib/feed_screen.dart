import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';
import 'create_post_screen.dart';
import 'chat_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<Map<String, dynamic>> _stories = [
    {'title': 'Your Story', 'icon': Icons.person, 'isUser': true, 'color': Colors.grey},
    {'title': 'Star News', 'icon': Icons.campaign, 'isUser': false, 'color': const Color(0xFF0284C7)},
    {'title': 'Trending', 'icon': Icons.local_fire_department, 'isUser': false, 'color': const Color(0xFFEA580C)},
    {'title': 'Gujarat', 'icon': Icons.location_city, 'isUser': false, 'color': const Color(0xFF16A34A)},
    {'title': 'Tech', 'icon': Icons.laptop_mac, 'isUser': false, 'color': const Color(0xFF9333EA)},
  ];

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

  void _openCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: const Text(
          'Star India',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white, size: 26),
            onPressed: _openCreatePost,
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(peerUid: '', peerName: 'Star Messages'),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 1. Stories Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                height: 94,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    final isUser = story['isUser'] as bool;
                    final color = story['color'] as Color;

                    return Container(
                      width: 72,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isUser ? Colors.grey.shade300 : color,
                                    width: 2.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.5),
                                  child: CircleAvatar(
                                    backgroundColor: color.withOpacity(0.15),
                                    child: Icon(story['icon'] as IconData, color: color, size: 26),
                                  ),
                                ),
                              ),
                              if (isUser)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0284C7),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            story['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 2. Post Creation Input Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: InkWell(
                  onTap: _openCreatePost,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF1E3A8A),
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'તમારા વિચારો પોસ્ટ કરો (Post / Share)...',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3. Official Welcome Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Text('#', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Star India Official', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('@starindia', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ઓલ-ઇન-વન સોશિયલ મીડિયા હબ હવે તૈયાર છે! 🚀\n#StarIndia #NextGenApp',
                        style: TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPostAction(Icons.chat_bubble_outline, '240'),
                          _buildPostAction(Icons.repeat, 'Repost'),
                          _buildPostAction(Icons.favorite_border, '1.5K'),
                          _buildPostAction(Icons.share_outlined, ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 4. Live Firestore Posts Feed
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final data = post.data() as Map<String, dynamic>;
                    final postId = post.id;
                    final authorUid = data['authorUid'] ?? '';
                    final authorName = data['authorName'] ?? 'Star User';
                    final authorProfession = data['authorProfession'] ?? 'અમદાવાદ, ગુજરાત';
                    final content = data['content'] ?? '';
                    final likes = List<dynamic>.from(data['likes'] ?? []);
                    final isLiked = likes.contains(_currentUid);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                        Text(
                                          authorProfession.isNotEmpty ? authorProfession : 'અમદાવાદ, ગુજરાત',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              content,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            Divider(height: 1, color: Colors.grey.shade100),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildPostAction(Icons.chat_bubble_outline, '0'),
                                _buildPostAction(Icons.repeat, 'Repost'),
                                InkWell(
                                  onTap: () => _toggleLike(postId, likes),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${likes.length}',
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildPostAction(Icons.share_outlined, ''),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5)),
        ],
      ],
    );
  }
}
