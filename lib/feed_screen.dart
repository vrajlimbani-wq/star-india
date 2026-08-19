import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reels_screen.dart';
import 'explore_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'story_view_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _userLanguage = 'en';
  String _activeProfileType = 'Personal';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fetchUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (_currentUid.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_currentUid).get();
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() => _userLanguage = data['language'] ?? 'en');
      }
    } catch (_) {}
  }

  String _t(String en, String gu, String hi) {
    if (_userLanguage == 'gu') return gu;
    if (_userLanguage == 'hi') return hi;
    return en;
  }

  void _openLiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('Star Live', 'સ્ટાર લાઈવ', 'स्टार लाइव')),
        content: Text(_t(
          'Live streaming feature is launching soon!',
          'લાઈવ સ્ટ્રીમિંગ સુવિધા ટૂંક સમયમાં શરૂ થઈ રહી છે!',
          'लाइव स्ट्रीमिंग सुविधा जल्द ही शुरू हो रही है!',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('OK', 'ઠીક છે', 'ठीक है')),
          )
        ],
      ),
    );
  }

  void _showProfileSwitcher() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('Switch Profile', 'પ્રોફાઇલ બદલો', 'प्रोफाइल बदलें'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildProfileTile('Personal', Icons.person, Colors.blue),
            _buildProfileTile('Business', Icons.business, Colors.green),
            _buildProfileTile('Creator', Icons.video_collection, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(String title, IconData icon, Color color) {
    final isSelected = _activeProfileType == title;
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF1E3A8A)) : null,
      onTap: () {
        setState(() => _activeProfileType = title);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _refreshFeed() async {
    await _fetchUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
            _buildHomeFeed(),
            const ReelsScreen(),
            const ExploreScreen(),
            const ChatScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: _t('Feed', 'ફીડ', 'फ़ीड')),
          BottomNavigationBarItem(icon: const Icon(Icons.play_arrow), label: _t('Reels', 'રીલ્સ', 'रील्स')),
          BottomNavigationBarItem(icon: const Icon(Icons.explore), label: _t('Explore', 'એક્સપ્લોર', 'एक्सप्लोर')),
          BottomNavigationBarItem(icon: const Icon(Icons.chat), label: _t('Chats', 'ચેટ્સ', 'चैट्स')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: _t('Profile', 'પ્રોફાઇલ', 'प्रोफ़ाइल')),
        ],
      ),
    );
  }

  Widget _buildHomeFeed() {
    return RefreshIndicator(
      color: const Color(0xFF1E3A8A),
      onRefresh: _refreshFeed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF1E3A8A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _showProfileSwitcher,
                  child: Row(
                    children: const [
                      Text('Star India', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
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
                      onPressed: () => _pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 95,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStoryItem(Icons.person_add, _t('Your Story', 'તમારી સ્ટોરી', 'आपकी स्टोरी'), isStory: true),
                _buildStoryItem(Icons.videocam, _t('Star Live', 'સ્ટાર લાઈવ', 'स्टार लाइव'), onTap: _openLiveDialog),
                _buildStoryItem(Icons.campaign, _t('Star News', 'સ્ટાર ન્યૂઝ', 'स्टार न्यूज़'), isStory: true),
                _buildStoryItem(Icons.local_fire_department, _t('Trending', 'ટ્રેન્ડિંગ', 'ट्रेंडिंग'), isStory: true),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(_t('No posts yet', 'હજુ સુધી કોઈ પોસ્ટ નથી', 'अभी कोई पोस्ट नहीं है')));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.person, color: Colors.white)),
                            title: Text(post['authorName'] ?? 'User'),
                          ),
                          if (post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty)
                            Image.network(post['mediaUrl'], fit: BoxFit.cover, width: double.infinity, height: 250, errorBuilder: (c, e, s) => const SizedBox()),
                          if (post['text'] != null && post['text'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(post['text']),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(IconData icon, String label, {VoidCallback? onTap, bool isStory = false}) {
    return GestureDetector(
      onTap: onTap ?? (isStory ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => StoryViewScreen(imageUrl: 'https://via.placeholder.com/150', userName: label))) : null),
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1), child: Icon(icon, color: const Color(0xFF1E3A8A), size: 22)),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
