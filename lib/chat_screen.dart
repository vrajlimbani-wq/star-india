import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'Star India Support',
        'msg': 'નમસ્તે, આપનું સ્વાગત છે.',
        'time': '10:45 AM',
        'unread': '1',
        'isOnline': true,
      },
      {
        'name': 'ગુજરાત ક્રિએટર્સ ગ્રૂપ',
        'msg': 'નવી પોસ્ટ શેર કરવામાં આવી છે.',
        'time': '09:12 AM',
        'unread': '3',
        'isOnline': false,
      },
      {
        'name': 'Social Updates',
        'msg': 'તમારી Reel ટ્રેન્ડિંગમાં છે.',
        'time': 'Yesterday',
        'unread': '0',
        'isOnline': false,
      },
    ];

    return Scaffold(
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final c = chats[index];
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: Text(
                    c['name'][0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (c['isOnline'] == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              c['msg'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c['unread'] != '0' ? Colors.black87 : Colors.grey.shade600,
                fontWeight: c['unread'] != '0' ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  c['time'],
                  style: TextStyle(
                    fontSize: 11,
                    color: c['unread'] != '0' ? Colors.green : Colors.grey,
                    fontWeight: c['unread'] != '0' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (c['unread'] != '0')
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      c['unread'],
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
