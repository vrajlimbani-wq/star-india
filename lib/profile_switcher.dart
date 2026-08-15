import 'package:flutter/material.dart';

class ProfileSwitcherScreen extends StatelessWidget {
  const ProfileSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileTile(context, 'Personal Profile', Icons.person),
          _buildProfileTile(context, 'Business Profile', Icons.business),
          _buildProfileTile(context, 'Creator Profile', Icons.video_collection),
          _buildProfileTile(context, 'Private Profile', Icons.lock),
        ],
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

