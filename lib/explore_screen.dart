import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _userLanguage = 'en';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'All', 'en': 'All', 'gu': 'તમામ', 'hi': 'सभी'},
    {'id': 'Business', 'en': 'Business / Shop', 'gu': 'વેપાર / દુકાન', 'hi': 'व्यापार / दुकान'},
    {'id': 'Construction', 'en': 'Construction / Eng.', 'gu': 'બાંધકામ / એન્જિનિયર', 'hi': 'निर्माण / इंजीनियर'},
    {'id': 'Services', 'en': 'Services', 'gu': 'સેવાઓ', 'hi': 'सेवाएं'},
    {'id': 'Education', 'en': 'Education', 'gu': 'શિક્ષણ', 'hi': 'शिक्षा'},
    {'id': 'Other', 'en': 'Other', 'gu': 'અન્ય', 'hi': 'अन्य'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchLanguage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLanguage() async {
    if (_currentUid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(_currentUid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userLanguage = doc.data()?['language'] ?? 'en';
          });
        }
      } catch (_) {}
    }
  }

  String _t(String en, String gu, String hi) {
    if (_userLanguage == 'gu') return gu;
    if (_userLanguage == 'hi') return hi;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _t('Explore Star India', 'એક્સપ્લોર સ્ટાર ઈન્ડિયા', 'एक्सप्लोर स्टार इंडिया'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: _t(
                  'Search name, city, or profession...',
                  'નામ, શહેર અથવા વ્યવસાય શોધો...',
                  'नाम, शहर या व्यवसाय खोजें...',
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFEFF4FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['id'];
                final label = _t(cat['en'], cat['gu'], cat['hi']);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1E3A8A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat['id'] as String);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      _t('No members found', 'કોઈ સભ્યો મળ્યા નથી', 'कोई सदस्य नहीं मिला'),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                final users = snapshot.data!.docs.where((doc) {
                  if (doc.id == _currentUid) return false;
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullName'] ?? data['name'] ?? '').toString().toLowerCase();
                  final city = (data['city'] ?? '').toString().toLowerCase();
                  final profession = (data['profession'] ?? data['businessName'] ?? '').toString().toLowerCase();
                  final category = (data['category'] ?? 'Other').toString();

                  bool matchesSearch = name.contains(_searchQuery) ||
                      city.contains(_searchQuery) ||
                      profession.contains(_searchQuery);

                  bool matchesCategory = _selectedCategory == 'All' || category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      _t('No matching profiles found', 'કોઈ મેળ ખાતી પ્રોફાઈલ મળી નથી', 'कोई मिलती-जुलती प्रोफ़ाइल नहीं मिली'),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final user = userDoc.data() as Map<String, dynamic>;
                    final String name = user['fullName'] ?? user['name'] ?? _t('Star Member', 'સ્ટાર મેમ્બર', 'स्टार सदस्य');
                    final String profession = user['profession'] ?? user['businessName'] ?? _t('Member', 'મેમ્બર', 'सदस्य');
                    final String city = user['city'] ?? '';
                    final String photoUrl = user['photoUrl'] ?? '';

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              peerId: userDoc.id,
                              peerName: name,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                              child: photoUrl.isEmpty
                                  ? Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                profession,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                            if (city.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                  const SizedBox(width: 2),
                                  Text(
                                    city,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _t('Connect', 'જોડાઓ', 'जुड़ें'),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
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
        ],
      ),
    );
  }
}
