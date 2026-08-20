import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _activeProfileType = 'Personal';

  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'Hindi (हिन्दी)',
    'gu': 'Gujarati (ગુજરાતી)',
    'mr': 'Marathi (मराठी)',
  };

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _userData = doc.data();
          _activeProfileType = _userData?['activeProfileType'] ?? 'Personal';
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _t(String en, String gu, String hi) {
    final lang = _userData?['language'] ?? 'en';
    if (lang == 'gu') return gu;
    if (lang == 'hi') return hi;
    return en;
  }

  Future<void> _changeLanguage(String langCode) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'language': langCode});
      setState(() => _userData?['language'] = langCode);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _switchProfileType(String newType) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'activeProfileType': newType});
      setState(() => _activeProfileType = newType);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_t("Switched to", "પ્રોફાઇલ બદલાઈ:", "प्रोफ़ाइल बदली:")} $newType',
            ),
          ),
        );
      }
    }
  }

  void _showProfileSwitcherDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t('Switch Profile', 'પ્રોફાઇલ સ્વિચ કરો', 'प्रोफ़ाइल बदलें'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(_t('Personal Profile', 'વ્યક્તિગત પ્રોફાઇલ', 'व्यक्तिगत प्रोफ़ाइल')),
              trailing: _activeProfileType == 'Personal' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                Navigator.pop(ctx);
                _switchProfileType('Personal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center, color: Colors.indigo),
              title: Text(_t('Business / Shop Profile', 'વેપાર / બિઝનેસ પ્રોફાઇલ', 'व्यापार / दुकान प्रोफ़ाइल')),
              trailing: _activeProfileType == 'Business' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                Navigator.pop(ctx);
                _switchProfileType('Business');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(_t('Creator Profile', 'ક્રિએટર પ્રોફાઇલ', 'क्रिएटर प्रोफ़ाइल')),
              trailing: _activeProfileType == 'Creator' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                Navigator.pop(ctx);
                _switchProfileType('Creator');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userData?['fullName'] ?? '');
    final bioController = TextEditingController(text: _userData?['bio'] ?? '');
    final cityController = TextEditingController(text: _userData?['city'] ?? '');
    final professionController = TextEditingController(text: _userData?['profession'] ?? '');
    final eduController = TextEditingController(text: _userData?['education'] ?? '');
    bool showPhone = _userData?['showPhone'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _t('Edit Profile', 'પ્રોફાઇલ સુધારો', 'प्रोफ़ाइल संपादित करें'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: _t('Full Name', 'પૂરું નામ', 'पूरा नाम'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(
                    labelText: _t('Bio', 'બાયો / પરિચય', 'बायो / परिचय'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: professionController,
                  decoration: InputDecoration(
                    labelText: _t('Profession / Business', 'વ્યવસાય / ધંધો', 'व्यवसाय / कार्य'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: _t('City / State', 'શહેર / રાજ્ય', 'शहर / राज्य'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: eduController,
                  decoration: InputDecoration(
                    labelText: _t('Education', 'અભ્યાસ / શિક્ષણ', 'शिक्षा'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: Text(_t('Show Phone to Public', 'અન્ય યુઝર્સને ફોન નંબર બતાવો', 'फोन नंबर अन्य उपयोगकर्ताओं को दिखाएं')),
                  value: showPhone,
                  onChanged: (val) => setModalState(() => showPhone = val),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                  onPressed: () async {
                    final user = _auth.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                        'fullName': nameController.text.trim(),
                        'bio': bioController.text.trim(),
                        'profession': professionController.text.trim(),
                        'city': cityController.text.trim(),
                        'education': eduController.text.trim(),
                        'showPhone': showPhone,
                      }, SetOptions(merge: true));
                      Navigator.pop(ctx);
                      _fetchProfile();
                    }
                  },
                  child: Text(_t('Save Details', 'સાચવો', 'सहेजें'), style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('Select Language', 'ભાષા પસંદ કરો', 'भाषा चुनें')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (ctx, index) {
              String key = _languages.keys.elementAt(index);
              return ListTile(
                title: Text(_languages[key]!),
                trailing: _userData?['language'] == key ? const Icon(Icons.check, color: Color(0xFF1E3A8A)) : null,
                onTap: () => _changeLanguage(key),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _auth.currentUser;
    final String name = _userData?['fullName'] ?? _userData?['name'] ?? user?.displayName ?? 'Star Member';
    final String photoUrl = _userData?['photoUrl'] ?? '';
    final String profession = _userData?['profession'] ?? _userData?['businessName'] ?? '';
    final String city = _userData?['city'] ?? '';
    final String bio = _userData?['bio'] ?? '';
    final String education = _userData?['education'] ?? '';
    final String phone = _userData?['phone'] ?? user?.phoneNumber ?? '';
    final bool showPhone = _userData?['showPhone'] ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _t('Profile', 'પ્રોફાઇલ', 'प्रोफ़ाइल'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account, color: Colors.white),
            tooltip: _t('Switch Profile', 'પ્રોફાઇલ સ્વિચ કરો', 'प्रोफ़ाइल बदलें'),
            onPressed: _showProfileSwitcherDialog,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: _t('Edit', 'સુધારો', 'संपादित करें'),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFF1E3A8A),
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: Icon(
                      _activeProfileType == 'Business'
                          ? Icons.business_center
                          : (_activeProfileType == 'Creator' ? Icons.star : Icons.person),
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_activeProfileType Profile',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bio, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(_t('Posts', 'પોસ્ટ્સ', 'पोस्ट्स'), '${_userData?['postsCount'] ?? 0}'),
                  _buildDivider(),
                  _buildStatItem(_t('Followers', 'ફોલોઅર્સ', 'फॉलोअर्स'), '${_userData?['followersCount'] ?? 0}'),
                  _buildDivider(),
                  _buildStatItem(_t('Following', 'ફોલોઇંગ', 'फॉलोइंग'), '${_userData?['followingCount'] ?? 0}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                if (profession.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.work_outline, color: Color(0xFF1E3A8A)),
                    title: Text(_t('Profession', 'વ્યવસાય / પદ', 'व्यवसाय / पद')),
                    subtitle: Text(profession),
                  ),
                if (city.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.location_city, color: Color(0xFF1E3A8A)),
                    title: Text(_t('City', 'શહેર', 'शहर')),
                    subtitle: Text(city),
                  ),
                if (education.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.school_outlined, color: Color(0xFF1E3A8A)),
                    title: Text(_t('Education', 'શિક્ષણ', 'शिक्षा')),
                    subtitle: Text(education),
                  ),
                if (phone.isNotEmpty && showPhone)
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: Color(0xFF1E3A8A)),
                    title: Text(_t('Phone', 'મોબાઇલ નંબર', 'फ़ोन नंबर')),
                    subtitle: Text(phone),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF1E3A8A)),
                  title: Text(_t('Change Language', 'ભાષા બદલો', 'भाषा बदलें')),
                  subtitle: Text(_languages[_userData?['language'] ?? 'en'] ?? 'English'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showLanguageDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(_t('Logout', 'લોગ આઉટ', 'लॉग आउट'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    await _auth.signOut();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300);
  }
}
