import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<Map<String, String>> _trends = [
    {'tag': '#StarIndiaApp', 'posts': '52.4K Posts', 'category': 'Trending in Gujarat'},
    {'tag': '#AllInOnePlatform', 'posts': '31.2K Posts', 'category': 'Technology'},
    {'tag': '#DigitalIndia', 'posts': '140K Posts', 'category': 'India Trends'},
    {'tag': '#AhmedabadHub', 'posts': '18.5K Posts', 'category': 'Local'},
  ];

  Future<void> _toggleFollow(String targetUid, bool isFollowing) async {
    if (_currentUid.isEmpty || targetUid == _currentUid) return;

    final currentRef = FirebaseFirestore.instance.collection('users').doc(_currentUid);
    final targetRef = FirebaseFirestore.instance.collection('users').doc(targetUid);

    if (isFollowing) {
      await currentRef.collection('following').doc(targetUid).delete();
      await targetRef.collection('followers').doc(_currentUid).delete();
    } else {
      await currentRef.collection('following').doc(targetUid).set({
        'followedAt': FieldValue.serverTimestamp(),
      });
      await targetRef.collection('followers').doc(_currentUid).set({
        'followerAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _navigateToProfile(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(targetUid: uid),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search people, professions, cities...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildExploreContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('કોઈ યુઝર મળ્યા નથી.'));
        }

        final users = snapshot.data!.docs.where((doc) {
          if (doc.id == _currentUid) return false;
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['fullName'] ?? data['firstName'] ?? '').toString().toLowerCase();
          final city = (data['city'] ?? '').toString().toLowerCase();
          final profession = (data['professionType'] ?? data['designation'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery) || city.contains(_searchQuery) || profession.contains(_searchQuery);
        }).toList();

        if (users.isEmpty) {
          return const Center(child: Text('તમારી સર્ચ મુજબ કોઈ પ્રોફાઇલ નથી મળી.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            final targetUid = userDoc.id;
            final fullName = userData['fullName'] ?? '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
            final city = userData['city'] ?? '';
            final profession = userData['designation'] ?? userData['professionType'] ?? 'Star India User';

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                onTap: () => _navigateToProfile(targetUid),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                title: Text(
                  fullName.isNotEmpty ? fullName : 'Star User',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profession, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    if (city.isNotEmpty)
                      Text('📍 $city', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _toggleFollow(targetUid, isFollowing: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExploreContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          'Discover People',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').limit(10).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
              }
              final docs = snapshot.data!.docs.where((d) => d.id != _currentUid).toList();

              if (docs.isEmpty) {
                return const Center(child: Text('હજુ અન્ય યુઝર્સ જોડાયા નથી.'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final targetUid = docs[index].id;
                  final name = data['fullName'] ?? data['firstName'] ?? 'User';
                  final city = data['city'] ?? 'India';

                  return InkWell(
                    onTap: () => _navigateToProfile(targetUid),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Trending Topics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 10),
        ..._trends.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                title: Text(
                  t['tag']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                subtitle: Text('${t['category']} • ${t['posts']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ),
            )),
      ],
    );
  }
}
