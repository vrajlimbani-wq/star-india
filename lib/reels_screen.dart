import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfileScreen(targetUid: uid),
                                    ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SizedBox(
            height: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'રીલ કમેન્ટ્સ (Reels Comments)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reels')
                        .doc(reelId)
                        .collection('comments')
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('પ્રથમ કમેન્ટ તમે કરો!', style: TextStyle(color: Colors.grey)),
                        );
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final cData = comments[index].data() as Map<String, dynamic>;
                          final uName = cData['userName'] ?? 'User';
                          final text = cData['comment'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  child: Text(
                                    uName.isNotEmpty ? uName[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(uName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        const SizedBox(height: 2),
                                        Text(text, style: const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                          decoration: InputDecoration(
                            hintText: 'કમેન્ટ લખો...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Color(0xFF1E3A8A)),
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty && _currentUid.isNotEmpty) {
                            commentController.clear();
                            await FirebaseFirestore.instance
                                .collection('reels')
                                .doc(reelId)
                                .collection('comments')
                                .add({
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
          title: const Text('નવી રીલ અપલોડ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'વીડિયો URL (MP4 / Direct Link)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  labelText: 'કૅપ્શન લખો...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('રદ કરો'),
            ),
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
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('રીલ સફળતાપૂર્વક અપલોડ થઈ ગઈ છે!'),
                        backgroundColor: Color(0xFF1E3A8A),
                      ),
                    );
                  }
                }
              },
              child: const Text('અપલોડ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _shareReel(String caption) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Star India રીલ લિંક કોપી થઈ ગઈ છે!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF1E3A8A),
      ),
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
        title: const Text(
          'Reels',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_outlined, color: Colors.white, size: 28),
            onPressed: _openCreateReelDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library_outlined, color: Colors.white54, size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    'હજુ કોઈ રીલ્સ ઉપલબ્ધ નથી.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                    onPressed: _openCreateReelDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('પ્રથમ રીલ અપલોડ કરો', style: TextStyle(color: Colors.white)),
                  ),
                ],
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
              final videoUrl = data['videoUrl'] ?? '';
              final authorUid = data['authorUid'] ?? '';
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
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 220,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
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
           
