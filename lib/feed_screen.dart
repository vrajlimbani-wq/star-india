import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reels_screen.dart';
import 'explore_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _currentIndex = 0;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _userLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _fetchLanguage();
  }

  Future<void> _fetchLanguage() async {
    if (_currentUid.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_currentUid).get();
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _userLanguage = data['language'] ?? 'en';
        });
      }
    } catch (_) {}
  }

  String _t(String en, String gu) => _userLanguage == 'gu' ? gu : en;

  void _openLiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('Star Live', 'સ્ટાર લાઈવ')),
        content: Text(_t('Live streaming feature is launching soon!', 'લાઈવ સ્ટ્રીમિંગ સુવિધા ટૂંક સમયમાં શરૂ થઈ રહી છે!')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('OK', 'ઠીક છે')),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeFeed(),
      const ReelsScreen(),
      const ExploreScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: _t('Feed', 'ફીડ')),
          BottomNavigationBarItem(icon: const Icon(Icons.play_arrow), label: _t('Reels', 'રીલ્સ')),
          BottomNavigationBarItem(icon: const Icon(Icons.explore), label: _t('Explore', 'એક્સપ્લોર')),
          BottomNavigationBarItem(icon: const Icon(Icons.chat), label: _t('Chats', 'ચેટ્સ')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: _t('Profile', 'પ્રોફાઇલ')),
        ],
      ),
    );
  }

  Widget _buildHomeFeed() {
    return Column(
      children: [
        // ટોપ હેડર
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF1E3A8A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Star India', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'photo', userLanguage: _userLanguage)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),

        // મુખ્ય સ્ક્રોલ ફીડ
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // સ્ટોરીઝ લિસ્ટ
              Container(
                height: 100,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStoryItem(Icons.person_add, _t('Your Story', 'તમારી સ્ટોરી'), true),
                    _buildStoryItem(Icons.videocam, _t('Star Live', 'સ્ટાર લાઈવ'), false, onTap: _openLiveDialog),
                    _buildStoryItem(Icons.campaign, _t('Star News', 'સ્ટાર ન્યૂઝ'), false),
                    _buildStoryItem(Icons.local_fire_department, _t('Trending', 'ટ્રેન્ડિંગ'), false),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // પોસ્ટ ક્રિએટ કાર્ડ
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'photo', userLanguage: _userLanguage)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.person, color: Colors.white)),
                            const SizedBox(width: 12),
                            Text(_t('Share your thoughts or update...', 'તમારા વિચારો પોસ્ટ કરો...'), style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.image, color: Colors.green),
                            label: Text(_t('Photo', 'ફોટો'), style: const TextStyle(color: Colors.black87)),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'photo', userLanguage: _userLanguage)),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.videocam, color: Colors.red),
                            label: Text(_t('Video', 'વિડિઓ'), style: const TextStyle(color: Colors.black87)),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'video', userLanguage: _userLanguage)),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.stream, color: Colors.orange),
                            label: Text(_t('Live', 'લાઈવ'), style: const TextStyle(color: Colors.black87)),
                            onPressed: _openLiveDialog,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // પોસ્ટ લિસ્ટ Stream
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: Text(_t('No posts available yet.', 'કોઈ પોસ્ટ્સ ઉપલબ્ધ નથી.'))),
                    );
                  }

                  final posts = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final data = posts[index].data() as Map<String, dynamic>;
                      final name = data['authorName'] ?? 'Star User';
                      final text = data['text'] ?? '';
                      final mediaUrl = data['mediaUrl'] ?? '';
                      final likes = List<dynamic>.from(data['likes'] ?? []);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              if (text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(text, style: const TextStyle(fontSize: 14)),
                              ],
                              if (mediaUrl.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(mediaUrl, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => const SizedBox()),
                                ),
                              ],
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Icon(Icons.favorite, color: likes.contains(_currentUid) ? Colors.red : Colors.grey, size: 20),
                                  const SizedBox(width: 4),
                                  Text('${likes.length}'),
                                  const SizedBox(width: 20),
                                  const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                                  const SizedBox(width: 4),
                                  Text(_t('0 Comments', '0 કમેન્ટ')),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(IconData icon, String label, bool isAdd, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
              child: Icon(icon, color: const Color(0xFF1E3A8A), size: 26),
            ),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
