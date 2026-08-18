import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';
import 'reel_player_item.dart';

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
      await reelRef.update({'likes': FieldValue.arrayRemove([_currentUid])});
    } else {
      await reelRef.update({'likes': FieldValue.arrayUnion([_currentUid])});
    }
  }

  void _showLikesBottomSheet(List<dynamic> likes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'રીલ લાઈક કરનાર યૂઝર્સ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: likes.isEmpty
                    ? const Center(child: Text('કોઈએ લાઈક કર્યું નથી.'))
                    : ListView.builder(
                        itemCount: likes.length,
                        itemBuilder: (context, index) {
                          final uid = likes[index].toString();
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                            builder: (context, userSnap) {
                              String name = 'Star User';
                              if (userSnap.hasData && userSnap.data!.exists) {
                                final uData = userSnap.data!.data() as Map<String, dynamic>;
                                name = uData['fullName'] ?? uData['name'] ?? 'Star User';
                              }
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UserProfileScreen(targetUid: uid)),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReelComments(String reelId) {
    final TextEditingController commentController = TextEditingController();
    final currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? 'Star Creator';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SizedBox(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('રીલ કમેન્ટ્સ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('reels').doc(reelId).collection('comments').orderBy('createdAt', descending: false).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('પ્રથમ કમેન્ટ તમે કરો!'));
                      }
                      final comments = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final cData = comments[index].data() as Map<String, dynamic>;
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF1E3A8A),
                              child: Text((cData['userName'] ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                            title: Text(cData['userName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            subtitle: Text(cData['comment'] ?? '', style: const TextStyle(fontSize: 13)),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'કમેન્ટ લખો...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF1E3A8A)),
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty && _currentUid.isNotEmpty) {
                            commentController.clear();
                            await FirebaseFirestore.instance.collection('reels').doc(reelId).collection('comments').add({
                              'userId': _currentUid,
                              'userName': currentUserName,
                              'comment': text,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCreateReelDialog() {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('નવી રીલ અપલોડ કરો'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'વીડિયો URL (MP4)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(labelText: 'કૅપ્શન', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('રદ કરો')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
              onPressed: () async {
                final videoUrl = urlController.text.trim();
                final caption = captionController.text.trim();
                if (videoUrl.isNotEmpty && _currentUid.isNotEmpty) {
                  final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Star Creator';
                  await FirebaseFirestore.instance.collection('reels').add({
                    'authorUid': _currentUid,
                    'authorName': userName,
                    'videoUrl': videoUrl,
                    'caption': caption,
                    'likes': [],
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('અપલોડ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.video_call, color: Colors.white), onPressed: _openCreateReelDialog),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reels').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('કોઈ રીલ્સ ઉપલબ્ધ નથી.', style: TextStyle(color: Colors.white)));
          }

          final reels = snapshot.data!.docs;

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final data = reels[index].data() as Map<String, dynamic>;
              final reelId = reels[index].id;
              final videoUrl = data['videoUrl'] ?? '';
              final authorName = data['authorName'] ?? 'Star Creator';
              final caption = data['caption'] ?? '';
              final likes = List<dynamic>.from(data['likes'] ?? []);
              final isLiked = likes.contains(_currentUid);

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (videoUrl.isNotEmpty)
                    ReelVideoPlayerItem(videoUrl: videoUrl)
                  else
                    const Center(child: Icon(Icons.play_circle_outline, size: 80, color: Colors.white30)),
                  Positioned(
                    left: 16,
                    bottom: 30,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        if (caption.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(caption, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 30),
                          onPressed: () => _toggleLike(reelId, likes),
                        ),
                        GestureDetector(
                          onTap: () => _showLikesBottomSheet(likes),
                          child: Text('${likes.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(height: 12),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.white, size: 28),
                          onPressed: () => _openReelComments(reelId),
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
