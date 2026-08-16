import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, String>> _trends = [
    {'tag': '#StarIndiaApp', 'posts': '52.4K Posts', 'category': 'Trending in Gujarat'},
    {'tag': '#AllInOnePlatform', 'posts': '31.2K Posts', 'category': 'Technology'},
    {'tag': '#DigitalIndia', 'posts': '140K Posts', 'category': 'India Trends'},
    {'tag': '#AhmedabadHub', 'posts': '18.5K Posts', 'category': 'Local'},
  ];

  // Pull to refresh ફંક્શન
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // અહીં ટ્રેન્ડિંગ ડેટા રીફ્રેશ થશે
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1E3A8A),
      backgroundColor: Colors.white,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search hashtags, trends...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Trends for you',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._trends.map((t) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  t['tag']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                subtitle: Text('${t['category']} • ${t['posts']}'),
                trailing: const Icon(Icons.more_vert),
              )),
        ],
      ),
    );
  }
}
