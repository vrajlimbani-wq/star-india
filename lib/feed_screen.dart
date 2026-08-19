import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reels_screen.dart';
import 'explore_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'story_view_screen.dart';
import 'post_card.dart'; // આ લાઈનથી આપણે નવું PostCard વાપરી શકીશું

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() => _userLanguage = doc.data()?['language'] ?? 'en');
      }
    }
  }

  String _t(String en, String gu, String hi) {
    if (_userLanguage == 'gu') return gu;
    if (_userLanguage == 'hi') return hi;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
          color: const Color(0xFF1E3A8A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Star India', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePostScreen(initialType: 'photo', userLanguage: _userLanguage))),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  return PostCard(
                    postId: doc.id,
                    post: doc.data() as Map<String, dynamic>,
                    userLanguage: _userLanguage,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
