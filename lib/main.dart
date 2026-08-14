import 'package:flutter/material.dart';
import 'profile_switcher.dart';

void main() {
  runApp(StarIndiaApp());
}

class StarIndiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star India',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: ProfileSwitcherScreen(),
    );
  }
}
