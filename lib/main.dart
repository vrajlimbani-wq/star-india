import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'chat_screen.dart';
import 'profile_switcher.dart';

void main() {
  runApp(const StarIndiaApp());
}

class StarIndiaApp extends StatelessWidget {
  const StarIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star India',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
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

  void _changeProfile(String newProfile) {
    setState(() {
      _activeProfile = newProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FeedScreen(activeProfile: _activeProfile),
      ChatScreen(activeProfile: _activeProfile),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSwitcherScreen(
                  activeProfile: _activeProfile,
                  onProfileChanged: _changeProfile,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Star India [$_activeProfile]', style: TextStyle(color: Colors.white, fontSize: 18)),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}
