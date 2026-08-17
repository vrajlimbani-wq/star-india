import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/user_profile_screen.dart';

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

  void _showUserListBottomSheet(String collectionName, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUid)
                      .collection(collectionName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('કોઈ $title મળ્યા નથી.', style: const TextStyle(color: Colors.grey)));
                    }

                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final targetUid = docs[index].id;
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(targetUid).get(),
                          builder: (context, userSnap) {
                            String name = 'Star User';
                            String city = 'Star India';
                            if (userSnap.hasData && userSnap.data!.exists) {
                              final uData = userSnap.data!.data() as Map<String, dynamic>;
                              name = uData['fullName'] ?? uData['name'] ?? 'Star User';
                              city = uData['city'] ?? 'Star India';
                            }
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1E3A8A),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(city),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(targetUid: targetUid),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditProfileDialog(Map<String, dynamic> currentData) {
    final nameController = TextEditingController(text: currentData['fullName'] ?? '');
    final bioController = TextEditingController(text: currentData['bio'] ?? '');
    final hobbiesController = TextEditingController(text: currentData['hobbies'] ?? '');
    final cityController = TextEditingController(text: currentData['city'] ?? '');
    final stateController = TextEditingController(text: currentData['state'] ?? 'Gujarat');
    final educationController = TextEditingController(text: currentData['education'] ?? '');
    final professionController = TextEditingController(text: currentData['designation'] ?? currentData['professionType'] ?? '');
    final phone1Controller = TextEditingController(text: currentData['phone1'] ?? '');
    final phone2Controller = TextEditingController(text: currentData['phone2'] ?? '');
    final whatsappController = TextEditingController(text: currentData['whatsapp'] ?? '');
    final instagramController = TextEditingController(text: currentData['instagram'] ?? '');
    final facebookController = TextEditingController(text: currentData['facebook'] ?? '');
    final twitterController = TextEditingController(text: currentData['twitter'] ?? '');
    bool isContactVisible = currentData['isContactVisible'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                          _buildInputField(stateController, 'રાજ્ય (State)'),
                          _buildInputField(educationController, 'અભ્યાસ / ડિગ્રી (Education)'),
                          _buildInputField(professionController, 'ધંધો / નોકરી / પદ (Profession)'),
                          _buildInputField(phone1Controller, 'મોબાઈલ નંબર ૧ (Primary)', keyboardType: TextInputType.phone),
                          _buildInputField(phone2Controller, 'મોબાઈલ નંબર ૨ (Secondary)', keyboardType: TextInputType.phone),
                          _buildInputField(whatsappController, 'WhatsApp નંબર / લિંક'),
                          _buildInputField(instagramController, 'Instagram લિંક'),
                          _buildInputField(facebookController, 'Facebook લિંક'),
                          _buildInputField(twitterController, 'X (Twitter) લિંક'),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('સંપર્ક વિગત અન્યને બતાવો (Show Contact)', style: TextStyle(fontSize: 14)),
                            value: isContactVisible,
                            activeColor: const Color(0xFF1E3A8A),
                            onChanged: (val) {
                              setSheetState(() {
                                isContactVisible = val;
                              });
                            },
                          ),
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
                              'state': stateController.text.trim(),
                              'education': educationController.text.trim(),
                              'designation': professionController.text.trim(),
                              'phone1': phone1Controller.text.trim(),
                              'phone2': phone2Controller.text.trim(),
                              'whatsapp': whatsappController.text.trim(),
                              'instagram': instagramController.text.trim(),
                              'facebook': facebookController.text.trim(),
                              'twitter': twitterController.text.trim(),
                              'isContactVisible': isContactVisible,
                            }, SetOptions(merge: true));

                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('પ્રોફાઇલ વિગતો સફળતાપૂર્વક સેવ થઈ ગઈ છે!'),
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

                      // Followers / Following Interactive Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => _showUserListBottomSheet('followers', 'Followers'),
                            child: _buildStatCounter('followers', 'Followers'),
                          ),
                          Container(height: 25, width: 1, color: Colors.grey.shade300),
                          GestureDetector(
                            onTap: () => _showUserListBottomSheet('following', 'Following'),
                            child: _buildStatCounter('following', 'Following'),
                          ),
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
                                Expande
