import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {'name': 'Star India Support', 'msg': 'નમસ્તે, આપનું સ્વાગત છે.', 'time': '10:45 AM', 'unread': '1'},
      {'name': 'ગુજરાત ક્રિએટર્સ ગ્રૂપ', 'msg': 'નવી પોસ્ટ શેર કરવામાં આવી છે.', 'time': '09:12 AM', 'unread': '3'},
      {'name': 'Social Updates', 'msg': 'તમારી Reel ટ્રેન્ડિંગમાં છે.', 'time': 'Yesterday', 'unread': '0'},
    ];

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1E3A8A),
            child: Text(c['name']![0], style: const TextStyle(color: Colors.white)),
          ),
          title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(c['msg']!, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(c['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              if (c['unread'] != '0')
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: Text(c['unread']!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${c['name']} સાથે ચેટ શરૂ કરો')),
            );
          },
        );
      },
    );
  }
}
