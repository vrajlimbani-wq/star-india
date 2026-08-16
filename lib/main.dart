import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_screen.dart';
import 'reels_screen.dart';
import 'explore_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAFWVCmLEW-3vmjQys5p4yj3JkjJJho2Cc",
      appId: "1:219020282945:android:82be9457eb99719125cac0",
      messagingSenderId: "219020282945",
      projectId: "star-india-a377f",
      storageBucket: "star-india-a377f.firebasestorage.app",
    ),
  );
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// ૧. ઓટો-લોગિન ચેક વિજેટ
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
                );
              }
              String name = "Star User";
              String profileType = "Personal";
              if (userSnap.hasData && userSnap.data!.exists) {
                final data = userSnap.data!.data() as Map<String, dynamic>?;
                name = data?['fullName'] ?? data?['name'] ?? snapshot.data!.displayName ?? "Star User";
                profileType = data?['profileType'] ?? "Personal";
              }
              return MainHomeScreen(userName: name, profileType: profileType);
            },
          );
        }
        return const LanguageSelectionScreen();
      },
    );
  }
  }

class MainHomeScreen extends StatefulWidget {
  final String userName;
  final String profileType;

  const MainHomeScreen({
    super.key,
    this.userName = "Star User",
    this.profileType = "Personal",
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  int _backPressCount = 0;
  DateTime? _lastBackPressTime;

  void _navigateToCreateScreen(String postType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(initialType: postType),
      ),
    );
  }

  void _openCreatePostModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'નવી પોસ્ટ / કન્ટેન્ટ ઉમેરો',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Icon(Icons.post_add, color: Colors.white),
                  ),
                  title: const Text('સોશિયલ પોસ્ટ બનાવો'),
                  subtitle: const Text('તમારા વિચારો, ફોટો અથવા કેપ્શન લખીને પોસ્ટ કરો'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreateScreen('post');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.video_call, color: Colors.white),
                  ),
                  title: const Text('રીલ્સ અને શોર્ટ વિડિયો બનાવો'),
                  subtitle: const Text('માત્ર ટૂંકા વિડિયો / રીલ્સ અપલોડ કરો'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreateScreen('reel');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.history_toggle_off, color: Colors.white),
                  ),
                  title: const Text('સ્ટેટસ અને સ્ટોરી વિડિયો બનાવો'),
                  subtitle: const Text('24 કલાક માટે વિડિયો સ્ટેટસ અને સ્ટોરી ઉમેરો'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreateScreen('story');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

    @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FeedScreen(onAddPost: _openCreatePostModal),
      const ReelsScreen(),
      const ExploreScreen(),
      const ChatsScreen(),
      ProfileScreen(userName: widget.userName),
    ];

    // ૨. ૩ વાર બેક દબાવવા પર જ એપ બંધ થવાનું લોજિક
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _backPressCount = 1;
        } else {
          _backPressCount++;
        }
        _lastBackPressTime = now;

        if (_backPressCount == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('એપ બંધ કરવા માટે હજુ ૨ વાર બેક દબાવો'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (_backPressCount == 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('એપ બંધ કરવા માટે હજુ ૧ વાર બેક દબાવો'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (_backPressCount >= 3) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 1,
          title: const Text(
            'Star India',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined, color: Colors.white),
              onPressed: _openCreatePostModal,
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
        body: screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Color(0xFF1E3A8A)),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle_fill, color: Colors.red),
              label: 'Reels',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up),
              selectedIcon: Icon(Icons.trending_up, color: Color(0xFF1E3A8A)),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat, color: Colors.green),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Color(0xFF1E3A8A)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
