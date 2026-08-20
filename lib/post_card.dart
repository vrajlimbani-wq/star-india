import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comments_screen.dart';

class PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> post;
  final String userLanguage;

  const PostCard({
    super.key,
    required this.postId,
    required this.post,
    required this.userLanguage,
  });

  String _t(String en, String gu, String hi) {
    if (userLanguage == 'gu') return gu;
    if (userLanguage == 'hi') return hi;
    return en;
  }

  void _showLikesDialog(BuildContext context, List likes) {
    if (likes.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _t('Liked by', 'લાઈક કરનાર યુઝર્સ', 'लाइक करने वाले'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: likes.length,
            itemBuilder: (context, index) {
              final uid = likes[index].toString();
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                builder: (context, snapshot) {
                  String name = uid;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    name = data?['fullName'] ?? data?['name'] ?? uid;
                  }
                  return ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF1E3A8A),
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    title: Text(name, style: const TextStyle(fontSize: 14)),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('Close', 'બંધ કરો', 'बंद करें')),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFF1E3A8A)),
              title: Text(_t('Copy Link', 'લિંક કોપી કરો', 'लिंक कॉपी करें')),
              onTap: () {
                Clipboard.setData(ClipboardData(text: 'https://starindia.app/post/$postId'));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _t('Link copied to clipboard!', 'લિંક કોપી થઈ ગઈ!', 'लिंक कॉपी हो गई!'),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: Text(_t('Share to WhatsApp', 'WhatsApp પર શેર કરો', 'WhatsApp पर साझा करें')),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: Text(_t('Share to Instagram', 'Instagram પર શેર કરો', 'Instagram पर साझा करें')),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.blue),
              title: Text(_t('Share to Facebook', 'Facebook પર શેર કરો', 'Facebook पर साझा करें')),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isOwner = post['authorId'] == currentUid;
    final List likes = post['likes'] is List ? post['likes'] : [];
    final bool isLiked = likes.contains(currentUid);
    final String text = post['text'] ?? '';
    final String mediaUrl = post['mediaUrl'] ?? '';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E3A8A),
              backgroundImage: (post['authorPhoto'] != null && post['authorPhoto'].toString().isNotEmpty)
                  ? NetworkImage(post['authorPhoto'])
                  : null,
              child: (post['authorPhoto'] == null || post['authorPhoto'].toString().isEmpty)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              post['authorName'] ?? _t('Star User', 'સ્ટાર યુઝર', 'स्टार यूजर'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            trailing: isOwner
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Text(_t('Delete', 'ડિલીટ', 'डिलीट'), style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
                      }
                    },
                  )
                : null,
          ),
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(text, style: const TextStyle(fontSize: 14, height: 1.3)),
            ),
          if (mediaUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              constraints: const BoxConstraints(maxHeight: 350),
              width: double.infinity,
              child: Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey.shade700,
                  ),
                  onPressed: () {
                    if (currentUid.isEmpty) return;
                    final db = FirebaseFirestore.instance.collection('posts').doc(postId);
                    if (isLiked) {
                      db.update({'likes': FieldValue.arrayRemove([currentUid])});
                    } else {
                      db.update({'likes': FieldValue.arrayUnion([currentUid])});
                    }
                  },
                ),
                GestureDetector(
                  onTap: () => _showLikesDialog(context, likes),
                  child: Text(
                    '${likes.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade700),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(
                          postId: postId,
                          userLanguage: userLanguage,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey.shade700),
                  onPressed: () => _showShareOptions(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
