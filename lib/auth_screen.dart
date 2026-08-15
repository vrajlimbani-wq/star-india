import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class AuthScreen extends StatefulWidget {
  final String selectedLanguage;
  const AuthScreen({super.key, this.selectedLanguage = 'en'});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = false;
  bool _isLoading = false;
  String _selectedProfile = "Personal";

  Map<String, Map<String, String>> get _texts => {
        'en': {
          'app_title_login': 'Star India Login',
          'app_title_signup': 'Star India - Create Account',
          'heading_login': 'Log in to your account',
          'heading_signup': 'Create a new account',
          'name_label': 'Full Name',
          'profile_type': 'Profile Type',
          'email_label': 'Email Address',
          'password_label': 'Password',
          'btn_login': 'Log In',
          'btn_signup': 'Sign Up',
          'switch_to_signup': 'Need an account? Sign Up',
          'switch_to_login': 'Already have an account? Log In',
          'error_fill': 'Please fill all required fields.',
        },
        'gu': {
          'app_title_login': 'સ્ટાર ઇન્ડિયા લોગિન',
          'app_title_signup': 'સ્ટાર ઇન્ડિયા - એકાઉન્ટ બનાવો',
          'heading_login': 'તમારા એકાઉન્ટમાં લોગિન કરો',
          'heading_signup': 'નવું એકાઉન્ટ બનાવો',
          'name_label': 'પૂરું નામ',
          'profile_type': 'પ્રોફાઇલ પ્રકાર',
          'email_label': 'ઈમેલ એડ્રેસ',
          'password_label': 'પાસવર્ડ',
          'btn_login': 'લોગિન કરો',
          'btn_signup': 'એકાઉન્ટ બનાવો',
          'switch_to_signup': 'નવું એકાઉન્ટ બનાવવું છે? Sign Up કરો',
          'switch_to_login': 'પહેલેથી એકાઉન્ટ છે? Log In કરો',
          'error_fill': 'કૃપા કરીને બધી વિગતો ભરો.',
        },
        'hi': {
          'app_title_login': 'स्टार इंडिया लॉगिन',
          'app_title_signup': 'स्टार इंडिया - खाता बनाएं',
          'heading_login': 'अपने खाते में लॉगिन करें',
          'heading_signup': 'नया खाता बनाएं',
          'name_label': 'पूरा नाम',
          'profile_type': 'प्रोफ़ाइल प्रकार',
          'email_label': 'ईमेल पता',
          'password_label': 'पासवर्ड',
          'btn_login': 'लॉगिन करें',
          'btn_signup': 'साइन अप करें',
          'switch_to_signup': 'नया खाता बनाना है? Sign Up करें',
          'switch_to_login': 'पहले से खाता है? Log In करें',
          'error_fill': 'कृपया सभी आवश्यक फ़ील्ड भरें।',
        },
      };

  String tr(String key) {
    final lang = _texts[widget.selectedLanguage] ?? _texts['en']!;
    return lang[key] ?? key;
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('error_fill'))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'profileType': _selectedProfile,
          'language': widget.selectedLanguage,
          'createdAt': Timestamp.now(),
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainHomeScreen(
              userName: name.isNotEmpty ? name : email.split('@')[0],
              profileType: _selectedProfile,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red.shade700, content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(tr(_isLogin ? 'app_title_login' : 'app_title_signup'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.indigo.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.stars_rounded, size: 64, color: Colors.indigo),
              ),
              const SizedBox(height: 12),
              Text(
                tr(_isLogin ? 'heading_login' : 'heading_signup'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: tr('name_label'), prefixIcon: const Icon(Icons.person_outline), border: const OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedProfile,
                          decoration: InputDecoration(labelText: tr('profile_type'), prefixIcon: const Icon(Icons.badge_outlined), border: const OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Personal', child: Text('Personal Profile')),
                            DropdownMenuItem(value: 'Business', child: Text('Business Profile')),
                            DropdownMenuItem(value: 'Creator', child: Text('Creator Profile')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedProfile = val);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: tr('email_label'), prefixIcon: const Icon(Icons.email_outlined), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: tr('password_label'), prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: _submitAuth,
                                child: Text(tr(_isLogin ? 'btn_login' : 'btn_signup'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(tr(_isLogin ? 'switch_to_signup' : 'switch_to_login'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.indigo)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
