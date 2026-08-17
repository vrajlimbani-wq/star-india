import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_post_screen.dart';
import 'chat_screen.dart';
import 'post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _userState = 'Gujarat';

  @override
  void initState() {
    super.initState();
    _fetchUserState();
  }

  Future<void> _fetchUserState() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['state'] != null && data['state'].toString().trim().isNotEmpty) {
          if (mounted) {
            setState(() {
              _userState = data['state'].toString().trim();
            });
          }
        }
      }
    }
  }

  void _openCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
  }

  void _showStoryDetails(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title વિભાગ શરૂ થઈ રહ્યો છે...'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stories = [
      {'title': 'Your Story', 'icon': Icons.person, 'isUser': true, 'color': Colors.grey},
      {'title': 'Star Live', 'icon': Icons.videocam, 'isUser': false, 'color': const Color(0xFFE11D48)},
      {'title': 'Star News', 'icon': Icons.campaign, 'isUser': false, 'color': const Color(0xFF0284C7)},
      {'title': 'Trending', 'icon': Icons.local_fire_department, 'isUser': false, 'color': const Color(0xFFEA580C)},
      {'title': _userState, 'icon': Icons.location_on, 'isUser': false, 'color': const Color(0xFF16A34A)},
      {'title': 'Tech', 'icon': Icons.laptop_mac, 'isUser': false, 'color': const Color(0xFF9333EA)},
    ];

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
            letterSpacing: 0.5,
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
          await _fetchUserState();
          setState(() {});
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 94,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    final isUser = story['isUser'] as bool;
                    final color = story['color'] as Color;

                    return GestureDetector(
                      onTap: () => _showStoryDetails(story['title'] as String),
                      child: Container(
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
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _openCreatePost,
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
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            onPressed: _openCreatePost,
                            icon: const Icon(Icons.photo_library, color: Colors.green, size: 18),
                            label: const Text('ફોટો', style: TextStyle(color: Colors.black87, fontSize: 12)),
                          ),
                          TextButton.icon(
                            onPressed: _openCreatePost,
                            icon: const Icon(Icons.videocam, color: Colors.red, size: 18),
                            label: const Text('વિડિયો', style: TextStyle(color: Colors.black87, fontSize: 12)),
                          ),
                          TextButton.icon(
                            onPressed: () => _showStoryDetails('Star Live'),
                            icon: const Icon(Icons.stream, color: Colors.orange, size: 18),
                            label: const Text('લાઈવ', style: TextStyle(color: Colors.black87, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'હજુ કોઈ નવી પોસ્ટ નથી. પ્રથમ પોસ્ટ તમે શેર કરો!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: posts[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
