import 'package:flutter/material.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
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
              // Central Video Placeholder
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline, size: 80, color: Colors.white70),
                    const SizedBox(height: 12),
                    Text(
                      'Star Reel #${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text('સ્વાઇપ કરીને આગળ જુઓ', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              
              // Bottom Details (User profile, caption, music)
              Positioned(
                bottom: 25,
                left: 16,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF1E3A8A),
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '@star_creator_${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Follow',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Star India Reels ✨ #Viral #Trending #StarIndia',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.music_note, size: 16, color: Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          'Original Audio - Star India Music',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right Action Buttons (Like, Comment, Share, More)
              Positioned(
                bottom: 30,
                right: 12,
                child: Column(
                  children: [
                    _buildAction(Icons.favorite, '12.4K', Colors.red),
                    const SizedBox(height: 18),
                    _buildAction(Icons.comment, '450', Colors.white),
                    const SizedBox(height: 18),
                    _buildAction(Icons.share, 'Share', Colors.white),
                    const SizedBox(height: 18),
                    _buildAction(Icons.more_vert, '', Colors.white),
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
        Icon(icon, color: color, size: 30),
        if (count.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}
