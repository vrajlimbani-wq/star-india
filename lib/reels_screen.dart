import 'package:flutter/material.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline, size: 80, color: Colors.white70),
                    const SizedBox(height: 12),
                    Text('Star Reel #${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('સ્વાઇપ કરીને આગળ જુઓ', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              Positioned(
                bottom: 30,
                left: 16,
                right: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@star_creator_${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Star India Reels #Viral #Trending', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                right: 16,
                child: Column(
                  children: [
                    _buildAction(Icons.favorite, '12.4K', Colors.red),
                    const SizedBox(height: 16),
                    _buildAction(Icons.comment, '450', Colors.white),
                    const SizedBox(height: 16),
                    _buildAction(Icons.share, 'Share', Colors.white),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAction(IconData icon, String count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

