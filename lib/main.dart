import 'package:flutter/material.dart';

void main() {
  runApp(const StarIndiaApp());
}

class StarIndiaApp extends StatelessWidget {
  const StarIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  String _activeProfile = "Personal";

  final List<String> _profiles = ["Personal", "Business", "Creator", "Private"];

  void _switchProfile(String newProfile) {
    setState(() {
      _activeProfile = newProfile;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $_activeProfile Profile'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProfileSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Switch Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Divider(color: Colors.white24),
              ..._profiles.map(
                (p) => ListTile(
                  leading: Icon(
                    p == "Personal"
                        ? Icons.person
                        : p == "Business"
                            ? Icons.business
                            : p == "Creator"
                                ? Icons.video_collection
                                : Icons.lock,
                    color: _activeProfile == p ? Colors.orangeAccent : Colors.white70,
                  ),
                  title: Text(
                    p,
                    style: TextStyle(
                      fontWeight: _activeProfile == p ? FontWeight.bold : FontWeight.normal,
                      color: _activeProfile == p ? Colors.orangeAccent : Colors.white,
                    ),
                  ),
                  trailing: _activeProfile == p
                      ? const Icon(Icons.check_circle, color: Colors.orangeAccent)
                      : null,
                  onTap: () => _switchProfile(p),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 10),
            Text(
              'Star India Feed ($_activeProfile)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('Smart Feed & Shorts coming soon...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.greenAccent),
            const SizedBox(height: 10),
            Text(
              'Instant Chat ($_activeProfile)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('Partitioned chats ready.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 15),
            Text(
              '$_activeProfile Profile',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _showProfileSwitcher,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Switch Account'),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('STAR INDIA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          ActionChip(
            avatar: const Icon(Icons.account_circle, size: 18),
            label: Text(_activeProfile),
            onPressed: _showProfileSwitcher,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
