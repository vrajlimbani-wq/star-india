import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  final VoidCallback onAddPost;
  const FeedScreen({super.key, required this.onAddPost});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 105,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 12),
              _buildMyStory(),
              _buildStory('Star News', Icons.campaign, Colors.blue),
              _buildStory('Trending', Icons.local_fire_department, Colors.orange),
              _buildStory('Gujarat', Icons.location_city, Colors.green),
              _buildStory('Tech', Icons.computer, Colors.purple),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF1E3A8A),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onAddPost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "તમારા વિચારો પોસ્ટ કરો (Create Post)...",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: Colors.black, child: Icon(Icons.tag, size: 16, color: Colors.white)),
                    SizedBox(width: 8),
                    Text('Star India Official', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Text('@starindia', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('ઓલ-ઇન-વન સોશિયલ મીડિયા હબ હવે તૈયાર છે! 🚀 #StarIndia #NextGenApp'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAction(Icons.chat_bubble_outline, '240'),
                    _buildAction(Icons.repeat, 'Repost'),
                    _buildAction(Icons.favorite_border, '1.5K'),
                    _buildAction(Icons.share_outlined, ''),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.person, color: Colors.white)),
                title: Text('Vraj Limbani', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('અમદાવાદ, ગુજરાત', style: TextStyle(fontSize: 11)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('Star India પ્લેટફોર્મ પર આપનું સ્વાગત છે! કનેક્ટ થાઓ અને શેર કરો.'),
              ),
              Container(
                height: 160,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Icon(Icons.image, size: 60, color: Colors.white54)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyStory() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: const Column(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: 26, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 8, backgroundColor: Colors.blue, child: Icon(Icons.add, size: 12, color: Colors.white))),
            ],
          ),
          SizedBox(height: 4),
          Text('Your Story', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStory(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.pink, width: 2)),
            child: CircleAvatar(radius: 24, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 20)),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ],
    );
  }
}
