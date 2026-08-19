import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'create_post_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Star Clips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen(initialType: 'video')),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').where('type', isEqualTo: 'video').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final reels = snapshot.data!.docs;

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final data = reels[index].data() as Map<String, dynamic>;
              return ReelPlayer(videoUrl: data['mediaUrl'] ?? '');
            },
          );
        },
      ),
    );
  }
}

class ReelPlayer extends StatefulWidget {
  final String videoUrl;
  const ReelPlayer({super.key, required this.videoUrl});

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)..initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            children: [
              VideoPlayer(_controller),
              Positioned(
                bottom: 20,
                right: 10,
                child: Column(
                  children: [
                    IconButton(icon: const Icon(Icons.favorite, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.comment, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
                  ],
                ),
              )
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}
