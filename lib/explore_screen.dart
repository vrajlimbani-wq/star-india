import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> trends = [
      {'tag': '#StarIndiaApp', 'posts': '52.4K Posts', 'category': 'Trending in Gujarat'},
      {'tag': '#AllInOnePlatform', 'posts': '31.2K Posts', 'category': 'Technology'},
      {'tag': '#DigitalIndia', 'posts': '140K Posts', 'category': 'India Trends'},
      {'tag': '#AhmedabadHub', 'posts': '18.5K Posts', 'category': 'Local'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search hashtags, trends...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Trends for you (X / Twitter)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...trends.map((t) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t['tag']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          subtitle: Text('${t['category']} • ${t['posts']}'),
          trailing: const Icon(Icons.more_vert),
        )),
      ],
    );
  }
}

