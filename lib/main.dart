import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'language_selection_screen.dart';
import 'profile_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase error: $e');
  }
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LanguageSelectionScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final String userName;
  final String profileType;

  const MainHomeScreen({
    super.key,
    required this.userName,
    required this.profileType,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  late String _activeProfile;

  @override
  void initState() {
    super.initState();
    _activeProfile = widget.profileType;
  }

  void _changeProfile(String newProfile) {
    setState(() {
      _activeProfile = newProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 2,
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Star India [$_activeProfile]',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${widget.userName}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Active Profile: $_activeProfile',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.indigo),
            label: 'Feed & Shorts',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Colors.indigo),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
