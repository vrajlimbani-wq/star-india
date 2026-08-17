import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSwitcherScreen extends StatelessWidget {
  final String? activeProfile;
  final Function(String)? onProfileChanged;

  const ProfileSwitcherScreen({
    super.key,
    this.activeProfile,
    this.onProfileChanged,
  });

  Future<void> _updateActiveProfile(String profileName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'activeProfile': profileName,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentActive = activeProfile ?? 'Personal Profile';

    final List<Map<String, dynamic>> profiles = [
      {
        'title': 'Personal Profile',
        'subtitle': 'મિત્રો અને પરિવાર સાથે અંગત વાતચીત અને પોસ્ટ',
        'icon': Icons.person,
        'color': const Color(0xFF1E3A8A),
      },
      {
        'title': 'Business Profile',
        'subtitle': 'વ્યાપારિક ગ્રાહકો, સેવાઓ અને ઓફર્સ માટે',
        'icon': Icons.business_center,
        'color': const Color(0xFF0284C7),
      },
      {
        'title': 'Creator Profile',
        'subtitle': 'રીલ્સ, વિડિયો કન્ટેન્ટ અને પબ્લિક ફેન ફોલોઇંગ',
        'icon': Icons.video_collection,
        'color': const Color(0xFFEA580C),
      },
      {
        'title': 'Private Profile',
        'subtitle': 'સંપૂર્ણ પ્રાઇવેટ અને સુરક્ષિત સ્પેસ',
        'icon': Icons.lock,
        'color': const Color(0xFF16A34A),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Switch Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1E3A8A), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'હાલની સક્રિય પ્રોફાઇલ: $currentActive',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...profiles.map((p) {
              final isSelected = p['title'] == currentActive;
              final Color pColor = p['color'] as Color;

              return Card(
                elevation: isSelected ? 2 : 0.5,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: pColor.withValues(alpha: 0.15),
                    child: Icon(p['icon'] as IconData, color: pColor, size: 24),
                  ),
                  title: Text(
                    p['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? const Color(0xFF1E3A8A) : Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      p['subtitle'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF1E3A8A), size: 24)
                      : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    final selectedTitle = p['title'] as String;
                    await _updateActiveProfile(selectedTitle);
                    if (onProfileChanged != null) {
                      onProfileChanged!(selectedTitle);
                    }
                    if (context.mounted) {
                      Navigator.pop(context, selectedTitle);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
