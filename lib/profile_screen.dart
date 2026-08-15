import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  const ProfileScreen({super.key, this.userName = "Vraj Limbani"});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1E3A8A),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('12', 'Posts'),
                  _buildStat('1.5K', 'Followers'),
                  _buildStat('320', 'Following'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text('Official Star India Profile', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Edit Profile'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Share Profile'))),
          ],
        ),
        const Divider(height: 30),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('લોગઆઉટ કરો', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

