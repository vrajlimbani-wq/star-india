import 'package:flutter/material.dart';

class ProfileSwitcherScreen extends StatelessWidget {
  final String activeProfile;
  final Function(String) onProfileChanged;

  const ProfileSwitcherScreen({super.key, required this.activeProfile, required this.onProfileChanged});

  final List<Map<String, dynamic>> profileTypes = const [
    {'name': 'Personal', 'icon': Icons.person, 'desc': 'મિત્રો અને પરિવાર માટે'},
    {'name': 'Business', 'icon': Icons.business_center, 'desc': 'ગ્રાહકો અને વેપાર માટે'},
    {'name': 'Creator', 'icon': Icons.video_collection, 'desc': 'શોર્ટ્સ અને રીલ્સ માટે'},
    {'name': 'Private', 'icon': Icons.lock, 'desc': 'ખાનગી ઉપયોગ માટે'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('પ્રોફાઇલ પસંદ કરો'), backgroundColor: Colors.indigo),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: profileTypes.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = profileTypes[index];
          final isSelected = activeProfile == item['name'];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.indigo : Colors.grey[300],
              child: Icon(item['icon'], color: Colors.white),
            ),
            title: Text('${item['name']} Profile', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['desc']),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.indigo) : null,
            onTap: () {
              onProfileChanged(item['name']);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
