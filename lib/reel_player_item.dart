import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const ReelVideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<ReelVideoPlayerItem> createState() => _ReelVideoPlayerItemState();
}

class _ReelVideoPlayerItemState extends State<ReelVideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }
}

