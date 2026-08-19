import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // તમારા Firebase પ્રોજેક્ટની ડાયરેક્ટ વિગતો (ક્યારેય ક્રેશ નહીં થાય)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAFWVCmLEW-3vmjQys5p4yj3JkjJJho2Cc',
      appId: '1:219020282945:android:82be9457eb99719125cac0',
      messagingSenderId: '219020282945',
      projectId: 'star-india-a377f',
      storageBucket: 'star-india-a377f.firebasestorage.app',
    ),
  );

  runApp(const StarIndiaApp());
}

class StarIndiaApp extends StatelessWidget {
  const StarIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Star India',
      debugShowCheckedModeBanner: false,
      home: FeedScreen(),
    );
  }
}
