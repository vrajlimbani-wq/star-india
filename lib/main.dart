import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'language_selection_screen.dart';
import 'profile_switcher.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ફાઈલ પાથ પર આધાર રાખ્યા વગર સીધું ડાયરેક્ટ કનેક્શન
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
      ),
      body: Center(
        child: Text(
          'વેલકમ, ${widget.userName}!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
