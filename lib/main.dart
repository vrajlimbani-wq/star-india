import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // જો કોઈ એરર આવે તો તેની ચોક્કસ વિગત સ્ક્રીન પર દેખાશે
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              'Error: ${details.exceptionAsString()}',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  };

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

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
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const FeedScreen(),
    );
  }
}
