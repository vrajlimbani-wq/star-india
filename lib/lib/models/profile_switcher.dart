import 'package:flutter/material.dart';

class ProfileSwitcherScreen extends StatefulWidget {
  @override
  _ProfileSwitcherScreenState createState() => _ProfileSwitcherScreenState();
}

class _ProfileSwitcherScreenState extends State<ProfileSwitcherScreen> {
  String activeProfile = 'Personal';
  final List<String> profiles = ['Personal', 'Business', 'Creator', 'Private'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Star India - Active: $activeProfile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Profile: $activeProfile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: activeProfile,
              items: profiles.map((String profile) {
                return DropdownMenuItem<String>(
                  value: profile,
                  child: Text(profile),
                );
              }).toList(),
              onChanged: (String? newProfile) {
                if (newProfile != null) {
                  setState(() {
                    activeProfile = newProfile;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

