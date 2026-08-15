import 'package:flutter/material.dart';

class ProfileSwitcherScreen extends StatelessWidget {
  final String activeProfile;
  final Function(String) onProfileChanged;

  ProfileSwitcherScreen({
    required this.activeProfile,
    required this.onProfileChanged,
  });

  final List<Map<String, dynamic>> profileTypes = [
    {'name': 'Personal', 'icon': Icons.person, 'desc': 'મિત્રો અને પરિવાર માટે'},
    {'name': 'Business', 'icon': Icons.business_center, 'desc': 'ગ્રાહકો અને વેપાર માટે'},
    {'name': 'Creator', 'icon': Icons.video_collection, 'desc': 'શોર્ટ્સ અને રીલ્સ માટે'},
    {'name': 'Private', 'icon': Icons.lock, 'desc': 'ખાનગી ઉપયોગ માટે'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('પ્રોફાઇલ પસંદ કરો'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(12),
        itemCount: profileTypes.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final item = profileTypes[index];
          final isSelected = activeProfile == item['name'];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.indigo : Colors.grey[300],
              foregroundColor: isSelected ? Colors.white : Colors.black87,
              child: Icon(item['icon']),
            ),
            title: Text(
              '${item['name']} Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item['desc']),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Colors.indigo)
                : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tileColor: isSelected ? Colors.indigo.withOpacity(0.08) : null,
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
