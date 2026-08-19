import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'Hindi (हिन्दी)',
    'gu': 'Gujarati (ગુજરાતી)',
    'mr': 'Marathi (मराठी)',
    'bn': 'Bengali (বাংলা)',
    'ta': 'Tamil (தமிழ்)',
    'te': 'Telugu (తెలుగు)',
  };

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeLanguage(String langCode) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'language': langCode});
      setState(() => _userData?['language'] = langCode);
      if (mounted) Navigator.pop(context);
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (ctx, index) {
              String key = _languages.keys.elementAt(index);
              return ListTile(
                title: Text(_languages[key]!),
                onTap: () => _changeLanguage(key),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: const Color(0xFF1E3A8A)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          Center(child: Text(_userData?['fullName'] ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Change Language'),
            subtitle: Text(_languages[_userData?['language'] ?? 'en'] ?? 'English'),
            onTap: _showLanguageDialog,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _auth.signOut();
              // અહીંથી લૉગિન સ્ક્રીન પર રીડાયરેક્ટ કરી શકાય
            },
          ),
        ],
      ),
    );
  }
}
