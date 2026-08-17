import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';

class PostCard extends StatelessWidget {
  final DocumentSnapshot post;

  const PostCard({super.key, required this.post});

  Future<void> _toggleLike(BuildContext context, String postId, List<dynamic> likes, String currentUid) async {
    if (currentUid.isEmpty) return;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (likes.contains(currentUid)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUid]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUid]),
      });
    }
  }

  void _showLikesBottomSheet(BuildContext context, List<dynamic> likes) {
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
                'લાઈક કરનાર યૂઝર્સ',
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
                              String city = 'Star India';
                              if (userSnap.hasData && userSnap.data!.exists) {
                                final uData = userSnap.data!.data() as Map<String, dynamic>;
                                name = uData['fullName'] ?? uData['name'] ?? 'Star User';
                                city = uData['city'] ?? 'Star India';
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
                                subtitle: Text(city),
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

  void _showShareDialog(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              const Center(
                child: Text(
                  'પોસ્ટ શેર કરો',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.copy, color: Color(0xFF1E3A8A)),
                title: const Text('લિંક કોપી કરો'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'https://starindia.app/post/$postId'));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Star India પોસ્ટ લિંક કોપી થઈ ગઈ છે!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF1E3A8A),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('અન્ય એપ્લિકેશન્સમાં શેર કરો (WhatsApp/Social)'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('શેરિંગ શરૂ થઈ રહ્યું છે...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCommentBottomSheet(BuildContext context, String postId, String currentUid, String currentUserName) {
    final TextEditingController commentController = TextEditingController();

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
                  'કમેન્ટ્સ (Comments)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .collection('comments')
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('હજુ સુધી કોઈ કમેન્ટ નથી. પ્રથમ કમેન્ટ કરો!', style: TextStyle(color: Colors.grey)),
                        );
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final cData = comments[index].data() as Map<String, dynamic>;
                          final uUid = cData['userId'] ?? '';
                          final uName = cData['userName'] ?? 'User';
                          final text = cData['comment'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (uUid.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfileScreen(targetUid: uUid),
                                        ),
                                      );
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    child: Text(
                                      uName.isNotEmpty ? uName[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      if (uUid.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserProfileScreen(targetUid: uUid),
                                          ),
                                        );
                                      }
                                    },
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
                          if (text.isNotEmpty && currentUid.isNotEmpty) {
                            commentController.clear();
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(postId)
                                .collection('comments')
                                .add({
                              'userId': currentUid,
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

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? 'Star User';

    final data = post.data() as Map<String, dynamic>;
    final postId = post.id;
    final authorUid = data['authorUid'] ?? '';
    final authorName = data['authorName'] ?? 'Star User';
    final authorProfession = data['authorProfession'] ?? 'અમદાવાદ, ગુજરાત';
    final content = data['content'] ?? '';
    final likes = List<dynamic>.from(data['likes'] ?? []);
    final isLiked = likes.contains(currentUid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
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
                    radius: 20,
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: Text(
                      authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          authorProfession.isNotEmpty ? authorProfession : 'અમદાવાદ, ગુજરાત',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey.shade600,
                        size: 22,
                      ),
                      onPressed: () => _toggleLike(context, postId, likes, currentUid),
                    ),
                    GestureDetector(
                      onTap: () => _showLikesBottomSheet(context, likes),
                      child: Text(
                        '${likes.length}',
                        style: TextStyle(
                          color: isLiked ? Colors.red : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, cSnap) {
                    final commentCount = cSnap.hasData ? cSnap.data!.docs.length : 0;
                    return TextButton.icon(
                      onPressed: () => _openCommentBottomSheet(context, postId, currentUid, currentUserName),
                      icon: Icon(Icons.mode_comment_outlined, color: Colors.grey.shade600, size: 20),
                      label: Text(
                        '$commentCount કમેન્ટ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey.shade600, size: 20),
                  onPressed: () => _showShareDialog(context, postId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
