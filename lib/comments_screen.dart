import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String userLanguage;

  const CommentsScreen({
    super.key,
    required this.postId,
    this.userLanguage = 'en',
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _t(String en, String gu, String hi) {
    if (widget.userLanguage == 'gu') return gu;
    if (widget.userLanguage == 'hi') return hi;
    return en;
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final currentUid = user?.uid ?? 'guest_user';

    String authorName = user?.displayName ?? 'Star User';
    String authorPhoto = '';

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          authorName = data['fullName'] ?? data['name'] ?? authorName;
          authorPhoto = data['photoUrl'] ?? '';
        }
      } catch (_) {}
    }

    setState(() => _isPosting = true);

    try {
      final commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments');

      await commentRef.add({
        'authorId': currentUid,
        'authorName': authorName,
        'authorPhoto': authorPhoto,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update total comments counter on post doc
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _reportComment(String commentId, String commentText) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('Report Comment', 'કમેન્ટ રિપોર્ટ કરો', 'कमेंट रिपोर्ट करें')),
        content: Text(
          _t(
            'Are you sure you want to report this comment for inappropriate content?',
            'શું તમે ખરેખર આ ગેરવ્યાજબી કમેન્ટ સામે રિપોર્ટ કરવા માંગો છો?',
            'क्या आप वास्तव में इस अनुचित टिप्पणी की रिपोर्ट करना चाहते हैं?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('Cancel', 'રદ કરો', 'रद्द करें')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('reports').add({
                'type': 'comment',
                'postId': widget.postId,
                'commentId': commentId,
                'commentText': commentText,
                'reportedBy': FirebaseAuth.instance.currentUser?.uid ?? '',
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _t(
                        'Report submitted. Our team will review it.',
                        'રિપોર્ટ સબમિટ થયો છે. ટીમ તેની તપાસ કરશે.',
                        'रिपोर्ट सबमिट हो गई है। टीम इसकी समीक्षा करेगी।',
                      ),
                    ),
                  ),
                );
              }
            },
            child: Text(_t('Report', 'રિપોર્ટ', 'रिपोर्ट'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t('Comments', 'કમેન્ટ્સ', 'कमेंट्स'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      _t('No comments yet. Be the first to comment!', 'હજુ કોઈ કમેન્ટ નથી. પહેલી કમેન્ટ તમે કરો!', 'अभी कोई टिप्पणी नहीं है। पहली टिप्पणी आप करें!'),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isMe = data['authorId'] == currentUid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF1E3A8A),
                            backgroundImage: (data['authorPhoto'] != null && data['authorPhoto'].toString().isNotEmpty)
                                ? NetworkImage(data['authorPhoto'])
                                : null,
                            child: (data['authorPhoto'] == null || data['authorPhoto'].toString().isEmpty)
                                ? const Icon(Icons.person, size: 20, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
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
                                  Text(
                                    data['authorName'] ?? 'User',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['text'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                            itemBuilder: (ctx) => [
                              if (isMe)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(_t('Delete', 'ડિલીટ', 'डिलीट'), style: const TextStyle(color: Colors.red)),
                                )
                              else
                                PopupMenuItem(
                                  value: 'report',
                                  child: Text(_t('Report', 'રિપોર્ટ', 'रिपोर्ट'), style: const TextStyle(color: Colors.red)),
                                ),
                            ],
                            onSelected: (value) async {
                              if (value == 'delete') {
                                await doc.reference.delete();
                                await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
                                  'commentsCount': FieldValue.increment(-1),
                                });
                              } else if (value == 'report') {
                                _reportComment(doc.id, data['text'] ?? '');
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _t('Write a comment...', 'કમેન્ટ લખો...', 'कमेंट लिखें...'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isPosting
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF1E3A8A)),
                          onPressed: _postComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
