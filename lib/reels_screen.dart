import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final PageController _pageController = PageController();

  Future<void> _toggleLike(String reelId, List<dynamic> likes) async {
    if (_currentUid.isEmpty) return;

    final reelRef = FirebaseFirestore.instance.collection('reels').doc(reelId);

    if (likes.contains(_currentUid)) {
      await reelRef.update({
        'likes': FieldValue.arrayRemove([_currentUid]),
      });
    } else {
      await reelRef.update({
        'likes': FieldValue.arrayUnion([_currentUid]),
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reels')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'હજુ કોઈ રીલ્સ ઉપલબ્ધ નથી.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final reels = snapshot.data!.docs;

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];
              final data = reel.data() as Map<String, dynamic>;
              final reelId = reel.id;
              final authorUid = data['authorUid'] ?? '';
              final authorName = data['authorName'] ?? 'Star Creator';
              final caption = data['caption'] ?? '';
              final likes = List<dynamic>.from(data['likes'] ?? []);
              final isLiked = likes.contains(_currentUid);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for Video Background
                  Container(
                    color: Colors.black,
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),

                  // Bottom Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // User Info & Caption
                  Positioned(
                    left: 16,
                    bottom: 30,
                    right: 80,
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
                                radius: 18,
                                backgroundColor: const Color(0xFF1E3A8A),
                                child: Text(
                                  authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                authorName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (caption.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            caption,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Right Side Action Buttons
                  Positioned(
                    right: 16,
                    bottom: 40,
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.redAccent : Colors.white,
                            size: 32,
                          ),
                          onPressed: () => _toggleLike(reelId, likes),
                        ),
                        Text(
                          '${likes.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                        const Text(
                          'Share',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
