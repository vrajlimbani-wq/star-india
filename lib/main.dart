import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed_screen.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      ),
    );
  };

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAFWVCmLEW-3vmjQys5p4yj3JkjJJho2Cc',
        appId: '1:219020282945:android:82be9457eb99719125cac0',
        messagingSenderId: '219020282945',
        projectId: 'star-india-a377f',
        storageBucket: 'star-india-a377f.firebasestorage.app',
      ),
    );
  } catch (e) {
    debugPrint("Firebase Startup: $e");
  }

  runApp(const StarIndiaApp());
}

class StarIndiaApp extends StatefulWidget {
  const StarIndiaApp({super.key});

  @override
  State<StarIndiaApp> createState() => _StarIndiaAppState();
}

class _StarIndiaAppState extends State<StarIndiaApp> {
  DateTime? _lastBackPressTime;
  int _backPressCount = 0;

  Future<bool> _handleWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _backPressCount = 1;
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back 2 more times to exit Star India'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    _backPressCount++;
    if (_backPressCount < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back ${3 - _backPressCount} more time to exit'),
          duration: const Duration(seconds: 1),
        ),
      );
      return false;
    }

    await SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: WillPopScope(
        onWillPop: _handleWillPop,
        child: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const FeedScreen();
        }
        return const AuthScreen();
      },
    );
  }
}
