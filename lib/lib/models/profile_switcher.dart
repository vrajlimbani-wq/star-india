import 'package:flutter/material.dart';

class ProfileSwitcherScreen extends StatefulWidget {
  @override
  _ProfileSwitcherScreenState createState() => _ProfileSwitcherScreenState();
}

class _ProfileSwitcherScreenState extends State<ProfileSwitcherScreen> {
  String activeProfile = 'Personal';
  final List<String> profiles = ['Personal', 'Business', 'Creator', 'Private'];

  void _switchProfile(String newProfile) {
    setState(() {
      activeProfile = newProfile;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to $newProfile Profile')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Profile')),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(profiles[index]),
            trailing: activeProfile == profiles[index] ? Icon(Icons.check, color: Colors.indigo) : null,
            onTap: () => _switchProfile(profiles[index]),
          );
        },
      ),
    );
  }
}
