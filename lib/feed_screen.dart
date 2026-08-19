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
        setState(() {
          _userLanguage = data['language'] ?? 'en';
        });
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('Switch Profile', 'પ્રોફાઇલ બદલો', 'प्रोफाइल बदलें'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
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
                    children: [
                      const Text(
                        'Star India',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _activeProfileType,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined, color: Colors.white, size: 22),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'photo', userLanguage: _userLanguage)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      onPressed: () {
                        _pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                  height: 95,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildStoryItem(Icons.person_add, _t('Your Story', 'તમારી સ્ટોરી', 'आपकी स्टोरी')),
                      _buildStoryItem(Icons.videocam, _t('Star Live', 'સ્ટાર લાઈવ', 'स्टार लाइव'), onTap: _openLiveDialog),
                      _buildStoryItem(Icons.campaign, _t('Star News', 'સ્ટાર ન્યૂઝ', 'स्टार न्यूज़')),
                      _buildStoryItem(Icons.local_fire_department, _t('Trending', 'ટ્રેન્ડિંગ', 'ट्रेंडिंग')),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'photo', userLanguage: _userLanguage)),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFF1E3A8A),
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _t('Share your thoughts...', 'તમારા વિચારો પોસ્ટ કરો...', 'अपने विचार साझा करें...'),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.image, color: Colors.green, size: 18),
                              label: Text(_t('Photo', 'ફોટો', 'फ़ोटो'), style: const TextStyle(color: Colors.black87, fontSize: 12)),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'photo', userLanguage: _userLanguage)),
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.videocam, color: Colors.red, size: 18),
                              label: Text(_t('Video', 'વિડિઓ', 'वीडियो'), style: const TextStyle(color: Colors.black87, fontSize: 12)),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreatePostScreen(initialType: 'video', userLanguage: _userLanguage)),
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.stream, color: Colors.orange, size: 18),
                              label: Text(_t('Live', 'લાઈવ', 'लाइव'), style: const TextStyle(color: Colors.black87, fontSize: 12)),
                              onPressed: _openLiveDialog,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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
                        child: Center(child: Text(_t('No posts available yet.', 'કોઈ પોસ્ટ્સ ઉપલબ્ધ નથી.', 'कोई पोस्ट उपलब्ध नहीं है.'))),
                      );
                    }

                    final posts = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final data = posts[index].data() as Map<String, dynamic>;
                        final docId = posts[index].id;
                        final name = data['authorName'] ?? 'Star User';
                        final text = data['text'] ?? '';
                        final mediaUrl = data['mediaUrl'] ?? '';
                        final likes = List<dynamic>.from(data['likes'] ?? []);
                        final isLiked = likes.contains(_currentUid);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF1E3A8A),
                                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                                if (text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(text, style: const TextStyle(fontSize: 13)),
                                ],
                                if (mediaUrl.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(mediaUrl, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => const SizedBox()),
                                  ),
                                ],
                                const Divider(height: 18),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (_currentUid.isEmpty) return;
                                        if (isLiked) {
                                          await FirebaseFirestore.instance.collection('posts').doc(docId).update({
                                            'likes': FieldValue.arrayRemove([_currentUid])
                                          });
                                        } else {
                                          await FirebaseFirestore.instance.collection('posts').doc(docId).update({
                                            'likes': FieldValue.arrayUnion([_currentUid])
                                          });
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey, size: 20),
                                          const SizedBox(width: 4),
                                          Text('${likes.length}', style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                                    const SizedBox(width: 4),
                                    Text(_t('Comment', 'કમેન્ટ', 'टिप्पणी'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
      ),
    );
  }

  Widget _buildStoryItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
              child: Icon(icon, color: const Color(0xFF1E3A8A), size: 22),
            ),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
