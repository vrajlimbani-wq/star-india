import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<String> posts = ['Welcome to Star India App!', 'Building residential projects in Ahmedabad.', 'Exploring new features today.'];

  void _addNewPost() {
    setState(() {
      posts.insert(0, 'New Post: My fresh update!');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('New post added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Star India - Feed & Shorts'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: _addNewPost,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Text('U1'),
                  ),
                  title: Text('Vraj Limbani'),
                  subtitle: Text('Just now'),
                ),
                Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        posts[index],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
