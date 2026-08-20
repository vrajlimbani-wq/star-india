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
  String _selectedCategory = 'All';
  String _userState = 'Gujarat';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'Story', 'label_en': 'Story', 'label_gu': 'સ્ટોરી', 'label_hi': 'स्टोरी', 'icon': Icons.history_toggle_off},
    {'id': 'Star News', 'label_en': 'Star News', 'label_gu': 'સ્ટાર ન્યૂઝ', 'label_hi': 'स्टार न्यूज़', 'icon': Icons.newspaper},
    {'id': 'Trending', 'label_en': 'Trending', 'label_gu': 'ટ્રેન્ડિંગ', 'label_hi': 'ट्रेंडिंग', 'icon': Icons.local_fire_department},
    {'id': 'State', 'label_en': 'State', 'label_gu': 'રાજ્ય', 'label_hi': 'राज्य', 'icon': Icons.location_on},
    {'id': 'Tech', 'label_en': 'Tech', 'label_gu': 'ટેક', 'label_hi': 'टेक', 'icon': Icons.devices},
  ];

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
          final data = doc.data();
          setState(() {
            _userLanguage = data?['language'] ?? 'en';
            _userState = data?['state'] ?? 'Gujarat';
          });
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
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
          color: const Color(0xFF1E3A8A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Star India',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: [
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
                  IconButton(
                    icon: const Icon(Icons.send_outlined, color: Colors.white, size: 24),
                    onPressed: () {
                      _pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              String title = cat['id'] == 'State'
                  ? _userState
                  : _t(cat['label_en'], cat['label_gu'], cat['label_hi']);
              bool isSelected = _selectedCategory == cat['id'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: ChoiceChip(
                  avatar: Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : const Color(0xFF1E3A8A)),
                  label: Text(title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E3A8A),
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? cat['id'] : 'All';
                    });
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
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
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            _t('No posts yet! Tap + to create one.', 'હજી કોઈ પોસ્ટ નથી! નવી પોસ્ટ કરવા + દબાવો.', 'अभी कोई पोस्ट नहीं है! नई पोस्ट के लिए + दबाएं।'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
