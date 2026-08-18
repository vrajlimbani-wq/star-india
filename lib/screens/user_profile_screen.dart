import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'call_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String targetUid;

  const UserProfileScreen({super.key, required this.targetUid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _userLanguage = 'en'; // મૂળભૂત ભાષા English

  @override
  void initState() {
    super.initState();
    _loadUserLanguage();
  }

  Future<void> _loadUserLanguage() async {
    if (_currentUid.isEmpty) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(_currentUid).get();
    if (doc.exists && mounted) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _userLanguage = data['language'] ?? 'en'; // ભાષા લોડ થશે
      });
    }
  }

  void _startCall(String targetName, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          targetName: targetName,
          isVideoCall: isVideo,
          currentLanguage: _userLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        title: Text(
          _userLanguage == 'gu' ? 'પ્રોફાઇલ' : 'Profile',
          style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.targetUid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                _userLanguage == 'gu' ? 'યુઝર મળ્યા નથી.' : 'User not found.',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['fullName'] ?? data['name'] ?? 'Star User';
          final profession = data['designation'] ?? 'Star Member';
          final city = data['city'] ?? '';
          final bio = data['bio'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(profession, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                if (city.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(city, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bio, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                ],
                const SizedBox(height: 20),

                // ઓડિયો અને વિડિઓ કોલિંગ બટન્સ
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.call, color: Colors.white, size: 18),
                      label: Text(
                        _userLanguage == 'gu' ? 'ઓડિયો કૉલ' : 'Audio Call',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _startCall(name, false),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.videocam, color: Colors.white, size: 18),
                      label: Text(
                        _userLanguage == 'gu' ? 'વિડિઓ કૉલ' : 'Video Call',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _startCall(name, true),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
