import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _openEditProfileDialog(Map<String, dynamic> currentData) {
    final nameController = TextEditingController(text: currentData['fullName'] ?? '');
    final bioController = TextEditingController(text: currentData['bio'] ?? '');
    final hobbiesController = TextEditingController(text: currentData['hobbies'] ?? '');
    final cityController = TextEditingController(text: currentData['city'] ?? '');
    final educationController = TextEditingController(text: currentData['education'] ?? '');
    final professionController = TextEditingController(text: currentData['designation'] ?? currentData['professionType'] ?? '');
    final phone1Controller = TextEditingController(text: currentData['phone1'] ?? '');
    final phone2Controller = TextEditingController(text: currentData['phone2'] ?? '');
    final whatsappController = TextEditingController(text: currentData['whatsapp'] ?? '');
    final instagramController = TextEditingController(text: currentData['instagram'] ?? '');
    final facebookController = TextEditingController(text: currentData['facebook'] ?? '');
    final twitterController = TextEditingController(text: currentData['twitter'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'પ્રોફાઇલ એડિટ કરો',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      _buildInputField(nameController, 'પૂરું નામ (Full Name)'),
                      _buildInputField(bioController, 'બાયો (Bio)', maxLines: 2),
                      _buildInputField(hobbiesController, 'શોખ / પસંદગીઓ (Hobbies)'),
                      _buildInputField(cityController, 'શહેર (City)'),
                      _buildInputField(educationController, 'અભ્યાસ / ડિગ્રી (Education)'),
                      _buildInputField(professionController, 'ધંધો / નોકરી / પદ (Profession)'),
                      _buildInputField(phone1Controller, 'મોબાઈલ નંબર ૧ (Primary)', keyboardType: TextInputType.phone),
                      _buildInputField(phone2Controller, 'મોબાઈલ નંબર ૨ (Secondary)', keyboardType: TextInputType.phone),
                      _buildInputField(whatsappController, 'WhatsApp લિંક / નંબર'),
                      _buildInputField(instagramController, 'Instagram પ્રોફાઇલ લિંક'),
                      _buildInputField(facebookController, 'Facebook પ્રોફાઇલ લિંક'),
                      _buildInputField(twitterController, 'X (Twitter) લિંક'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('users').doc(_currentUid).set({
                          'fullName': nameController.text.trim(),
                          'bio': bioController.text.trim(),
                          'hobbies': hobbiesController.text.trim(),
                          'city': cityController.text.trim(),
                          'education': educationController.text.trim(),
                          'designation': professionController.text.trim(),
                          'phone1': phone1Controller.text.trim(),
                          'phone2': phone2Controller.text.trim(),
                          'whatsapp': whatsappController.text.trim(),
                          'instagram': instagramController.text.trim(),
                          'facebook': facebookController.text.trim(),
                          'twitter': twitterController.text.trim(),
                        }, SetOptions(merge: true));

                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('પ્રોફાઇલ વિગતો સેવ થઈ ગઈ છે!'),
                              backgroundColor: Color(0xFF1E3A8A),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('સેવ કરો (Save)', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('યુઝર લૉગિન નથી.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('લૉગઆઉટ'),
                  content: const Text('શું તમે ખરેખર લૉગઆઉટ કરવા માંગો છો?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('ના'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _signOut();
                      },
                      child: const Text('હા', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_currentUid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }

          final data = snapshot.hasData && snapshot.data!.exists
              ? snapshot.data!.data() as Map<String, dynamic>
              : <String, dynamic>{};

          final fullName = data['fullName'] ??
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          final profession = data['designation'] ?? data['professionType'] ?? 'Star India Member';
          final city = data['city'] ?? '';
          final bio = data['bio'] ?? '';
          final education = data['education'] ?? '';
          final hobbies = data['hobbies'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFF1E3A8A),
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName.isNotEmpty ? fullName : 'Star Account',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profession,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                      if (city.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(city, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                        ),
                      ],
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => _openEditProfileDialog(data),
                        icon: const Icon(Icons.edit, size: 16, color: Color(0xFF1E3A8A)),
                        label: const Text('પ્રોફાઇલ એડિટ કરો', style: TextStyle(color: Color(0xFF1E3A8A))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Followers / Following Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCounter('followers', 'Followers'),
                          Container(height: 25, width: 1, color: Colors.grey.shade300),
                          _buildStatCounter('following', 'Following'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Details Card (Education & Hobbies)
                if (education.isNotEmpty || hobbies.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (education.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.school, size: 18, color: Color(0xFF1E3A8A)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('અભ્યાસ: $education', style: const TextStyle(fontSize: 13.5))),
                              ],
                            ),
                          ),
                        if (hobbies.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.interests, size: 18, color: Color(0xFF1E3A8A)),
                              const SizedBox(width: 8),
                              Expanded(child: Text('શોખ: $hobbies', style: const TextStyle(fontSize: 13.5))),
                            ],
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                // My Posts Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.grid_on, size: 18, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Text(
                        'My Posts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildMyPosts(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCounter(String subCollection, String label) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUid)
          .collection(subCollection)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        );
      },
    );
  }

  Widget _buildMyPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('authorUid', isEqualTo: _currentUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Text(
                'તમે હજુ કોઈ પોસ્ટ મૂકી નથી.',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          );
        }

        final posts = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postData = posts[index].data() as Map<String, dynamic>;
            final content = postData['content'] ?? '';
            final likesCount = (postData['likes'] as List?)?.length ?? 0;

            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text('$likesCount likes', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
