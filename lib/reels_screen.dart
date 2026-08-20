import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_post_screen.dart';
import 'reel_player_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  String _userLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _fetchUserLanguage();
  }

  Future<void> _fetchUserLanguage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() => _userLanguage = doc.data()?['language'] ?? 'en');
        }
      } catch (_) {}
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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _t('Star Clips', 'સ્ટાર ક્લિપ્સ', 'स्टार क्लिप्स'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostScreen(
                  initialType: 'video',
                  userLanguage: _userLanguage,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('type', isEqualTo: 'video')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                _t('Error loading reels', 'રીલ્સ લોડ કરવામાં ભૂલ આવી', 'रील्स लोड करने में त्रुटि'),
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library_outlined, size: 64, color: Colors.white38),
                  const SizedBox(height: 12),
                  Text(
                    _t('No reels yet! Tap + to upload.', 'હજુ કોઈ રીલ નથી! અપલોડ કરવા + દબાવો.', 'अभी कोई रील नहीं है! अपलोड करने के लिए + दबाएं।'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final reels = snapshot.data!.docs;

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final doc = reels[index];
              final data = doc.data() as Map<String, dynamic>;
              return ReelVideoPlayerItem(
                postId: doc.id,
                reelData: data,
                userLanguage: _userLanguage,
              );
            },
          );
        },
      ),
    );
  }
}
