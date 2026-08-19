import 'package:flutter/material.dart';

class StoryViewScreen extends StatelessWidget {
  final String imageUrl;
  final String userName;

  const StoryViewScreen({super.key, required this.imageUrl, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // સ્ટોરીનો ફોટો
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
            ),
          ),
          // ટોપ બાર (યુઝર નામ અને ક્લોઝ બટન)
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
