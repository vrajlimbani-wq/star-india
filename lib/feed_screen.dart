import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedScreen extends StatefulWidget {
  final String activeProfile;
  const FeedScreen({super.key, required this.activeProfile});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed (${widget.activeProfile})'),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Posts'), Tab(text: 'Shorts')]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('posts').where('profileType', isEqualTo: widget.activeProfile).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final posts = snapshot.data!.docs;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  var p = posts[index].data() as Map<String, dynamic>;
                  return Card(margin: const EdgeInsets.all(10), child: ListTile(title: Text(p['content'])));
                },
              );
            },
          ),
          const Center(child: Text("Shorts (Coming Soon!)")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _firestore.collection('posts').add({
            'content': 'નવી પોસ્ટ - ${widget.activeProfile}',
            'profileType': widget.activeProfile,
            'createdAt': FieldValue.serverTimestamp(),
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
