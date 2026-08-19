import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feed_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const FirebaseInitGate(),
    );
  }
}

class FirebaseInitGate extends StatelessWidget {
  const FirebaseInitGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Initialization Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          );
        }

        // Firebase સંપૂર્ણ લોડ થઈ જાય પછી જ FeedScreen ખુલશે
        if (snapshot.connectionState == ConnectionState.done) {
          return const FeedScreen();
        }

        // લોડિંગ દરમિયાન વાદળી ઇન્ડિકેટર દેખાશે
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
          ),
        );
      },
    );
  }
}
