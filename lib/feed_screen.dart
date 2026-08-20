import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reels_screen.dart';
import 'explore_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  String _userLanguage = 'en';

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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() => _userLanguage = doc.data()?['language'] ?? 'en');
        }
      }
    } catch (_) {}
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
          color: const Color(0xFF1E3A8A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Star India',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              IconButton(
                icon: const Icon(Icons.add_box_outlined, color: Colors.white, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatePostScreen(
                        initialType: 'photo',
                        userLanguage: _userLanguage,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _t('Error loading posts', 'પોસ્ટ લોડ કરવામાં ભૂલ આવી', 'पोस्ट लोड करने में त्रुटि'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        _t('No posts yet! Tap + to create one.', 'હજી કોઈ પોસ્ટ નથી! નવી પોસ્ટ કરવા + દબાવો.', 'अभी कोई पोस्ट नहीं है! नई पोस्ट के लिए + दबाएं।'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    return PostCard(
                      postId: doc.id,
                      post: data,
                      userLanguage: _userLanguage,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
