import 'package:flutter/material.dart';

class ProfileSwitcherScreen extends StatelessWidget {
  final String activeProfile;
  final Function(String) onProfileChanged;

  const ProfileSwitcherScreen({
    super.key,
    required this.activeProfile,
    required this.onProfileChanged,
  });

  final List<Map<String, dynamic>> profileTypes = const [
    {'name': 'Personal', 'icon': Icons.person, 'desc': 'મિત્રો અને પરિવાર માટે'},
    {'name': 'Business', 'icon': Icons.business_center, 'desc': 'ગ્રાહકો અને વેપાર માટે'},
    {'name': 'Creator', 'icon': Icons.video_collection, 'desc': 'શોર્ટ્સ અને રીલ્સ માટે'},
    {'name': 'Private', 'icon': Icons.lock, 'desc': 'ખાનગી ઉપયોગ માટે'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'પ્રોફાઇલ પસંદ કરો',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: profileTypes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = profileTypes[index];
          final isSelected = activeProfile == item['name'];

          return Card(
            elevation: isSelected ? 2 : 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
                child: Icon(
                  item['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
              title: Text(
                '${item['name']} Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.black87,
                ),
              ),
              subtitle: Text(item['desc'] as String),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF1E3A8A), size: 22)
                  : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                onProfileChanged(item['name'] as String);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
