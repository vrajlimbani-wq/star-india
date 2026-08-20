import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comments_screen.dart';

class ReelVideoPlayerItem extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> reelData;
  final String userLanguage;

  const ReelVideoPlayerItem({
    super.key,
    required this.postId,
    required this.reelData,
    this.userLanguage = 'en',
  });

  @override
  State<ReelVideoPlayerItem> createState() => _ReelVideoPlayerItemState();
}

class _ReelVideoPlayerItemState extends State<ReelVideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final String videoUrl = widget.reelData['mediaUrl'] ?? '';
    if (videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _isInitialized = true);
            _controller.setLooping(true);
            _controller.play();
          }
        });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _t(String en, String gu, String hi) {
    if (widget.userLanguage == 'gu') return gu;
    if (widget.userLanguage == 'hi') return hi;
    return en;
  }

  void _toggleLike(String currentUid, List likes) {
    if (currentUid.isEmpty) return;
    final ref = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    if (likes.contains(currentUid)) {
      ref.update({'likes': FieldValue.arrayRemove([currentUid])});
    } else {
      ref.update({'likes': FieldValue.arrayUnion([currentUid])});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final List likes = widget.reelData['likes'] is List ? widget.reelData['likes'] : [];
    final bool isLiked = likes.contains(currentUid);
    final String authorName = widget.reelData['authorName'] ?? 'Star User';
    final String caption = widget.reelData['text'] ?? '';

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isInitialized)
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        Positioned(
          left: 16,
          bottom: 24,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
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
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: () => _toggleLike(currentUid, likes),
              ),
              Text(
                '${likes.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.comment_outlined, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(
                        postId: widget.postId,
                        userLanguage: widget.userLanguage,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white, size: 30),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: 'https://starindia.app/reel/${widget.postId}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_t('Link copied!', 'લિંક કોપી થઈ ગઈ!', 'लिंक कॉपी हो गई!'))),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
