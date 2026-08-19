import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> post;
  final String userLanguage;

  const PostCard({super.key, required this.postId, required this.post, required this.userLanguage});

  String _t(String en, String gu, String hi) {
    if (userLanguage == 'gu') return gu;
    if (userLanguage == 'hi') return hi;
    return en;
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(_t('Share to Star India', 'સ્ટાર ઈન્ડિયા પર શેર કરો', 'स्टार इंडिया पर साझा करें'))),
          ListTile(title: Text(_t('WhatsApp', 'વોટ્સએપ', 'WhatsApp'))),
          ListTile(title: Text(_t('Facebook', 'ફેસબુક', 'Facebook'))),
          ListTile(title: Text(_t('Instagram', 'ઈન્સ્ટાગ્રામ', 'Instagram'))),
          ListTile(title: Text('X (Twitter)')),
          ListTile(title: Text('Snapchat')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isOwner = post['authorId'] == currentUid;
    final List likes = post['likes'] ?? [];
    final bool isLiked = likes.contains(currentUid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(post['authorName'] ?? 'User'),
            trailing: isOwner
                ? PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(child: Text(_t('Edit', 'એડિટ', 'एडिट')), value: 'edit'),
                      PopupMenuItem(child: Text(_t('Delete', 'ડિલીટ', 'डिलीट')), value: 'delete'),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
                      }
                    },
                  )
                : null,
          ),
          if (post['mediaUrl'] != null)
            Image.network(post['mediaUrl'], fit: BoxFit.cover, width: double.infinity, height: 250),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(post['text'] ?? ''),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
                onPressed: () {
                  final db = FirebaseFirestore.instance.collection('posts').doc(postId);
                  if (isLiked) db.update({'likes': FieldValue.arrayRemove([currentUid])});
                  else db.update({'likes': FieldValue.arrayUnion([currentUid])});
                },
              ),
              Text('${likes.length}'),
              IconButton(icon: const Icon(Icons.comment_outlined), onPressed: () {}),
              Text('0'), // કમેન્ટ કાઉન્ટ
              const Spacer(),
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () => _showShareOptions(context)),
            ],
          ),
        ],
      ),
    );
  }
}
