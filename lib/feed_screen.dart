import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  final String activeProfile;

  FeedScreen({required this.activeProfile});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // દરેક પ્રોફાઇલ માટે અલગ ડેટા
  final Map<String, List<String>> _profilePosts = {
    'Personal': ['પરિવાર સાથેનો સુંદર દિવસ!', 'અમદાવાદમાં નવો અનુભવ.'],
    'Business': ['નવા કન્સ્ટ્રક્શન પ્રોજેક્ટ્સની માહિતી.', 'વ્યાપાર સંબંધિત અપડેટ્સ.'],
    'Creator': ['મારો નવો શોર્ટ વિડીયો જુઓ 🎥', 'New trending reel content!'],
    'Private': ['ખાનગી નોંધો અને અંગત યાદો.'],
  };

  final TextEditingController _postController = TextEditingController();

  void _addNewPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.activeProfile} માં નવી પોસ્ટ ઉમેરો'),
        content: TextField(
          controller: _postController,
          decoration: InputDecoration(hintText: 'અહીં લખો...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('રદ કરો'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_postController.text.trim().isNotEmpty) {
                setState(() {
                  _profilePosts[widget.activeProfile]?.insert(0, _postController.text.trim());
                });
                _postController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('પોસ્ટ કરો'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentPosts = _profilePosts[widget.activeProfile] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Star India (${widget.activeProfile})'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: _addNewPost,
          ),
        ],
      ),
      body: currentPosts.isEmpty
          ? Center(child: Text('કોઈ પોસ્ટ નથી. નવી પોસ્ટ કરો!'))
          : ListView.builder(
              itemCount: currentPosts.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo,
                          child: Text(widget.activeProfile[0]),
                        ),
                        title: Text('${widget.activeProfile} User'),
                        subtitle: Text('હમણાં જ'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          currentPosts[index],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.thumb_up_outlined),
                            label: Text('Like'),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.comment_outlined),
                            label: Text('Comment'),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.share_outlined),
                            label: Text('Share'),
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
