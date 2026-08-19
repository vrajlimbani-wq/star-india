import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedLanguage = 'en';

  final Map<String, Map<String, String>> _text = {
    'en': {
      'welcome': 'Welcome to Star India',
      'sub': 'Select your preferred language',
      'name': 'Full Name',
      'emailOrPhone': 'Email or 10-digit Mobile',
      'password': 'Password (min 6 chars)',
      'confirmPassword': 'Confirm Password',
      'login': 'Login',
      'signup': 'Create Account',
      'toggleToSignup': "Don't have an account? Sign Up",
      'toggleToLogin': 'Already have an account? Login',
      'fillAll': 'Please fill all fields properly',
      'passMismatch': 'Passwords do not match',
      'banned': 'Your account has been suspended by Admin.',
    },
    'gu': {
      'welcome': 'સ્ટાર ઇન્ડિયા માં સ્વાગત છે',
      'sub': 'તમારી પસંદગીની ભાષા પસંદ કરો',
      'name': 'પૂરું નામ',
      'emailOrPhone': 'ઇમેઇલ અથવા ૧૦ આંકડાનો મોબાઇલ',
      'password': 'પાસવર્ડ (ઓછામાં ઓછા ૬ અક્ષર)',
      'confirmPassword': 'પાસવર્ડ ફરી દાખલ કરો',
      'login': 'લૉગિન કરો',
      'signup': 'એકાઉન્ટ બનાવો',
      'toggleToSignup': 'નવું એકાઉન્ટ બનાવવા માટે અહીં ક્લિક કરો',
      'toggleToLogin': 'પહેલેથી એકાઉન્ટ છે? લૉગિન કરો',
      'fillAll': 'કૃપા કરીને બધી વિગતો યોગ્ય રીતે ભરો',
      'passMismatch': 'પાસવર્ડ સરખા નથી',
      'banned': 'તમારું એકાઉન્ટ એડમિન દ્વારા સસ્પેન્ડ કરવામાં આવ્યું છે.',
    },
    'hi': {
      'welcome': 'स्टार इंडिया में आपका स्वागत है',
      'sub': 'अपनी पसंदीदा भाषा चुनें',
      'name': 'पूरा नाम',
      'emailOrPhone': 'ईमेल या १० अंकों का मोबाइल',
      'password': 'पासवर्ड (कम से कम ६ अक्षर)',
      'confirmPassword': 'पासवर्ड दोबारा दर्ज करें',
      'login': 'लॉगिन करें',
      'signup': 'खाता बनाएं',
      'toggleToSignup': 'नया खाता बनाने के लिए यहाँ क्लिक करें',
      'toggleToLogin': 'पहले से खाता है? लॉगिन करें',
      'fillAll': 'कृपया सभी विवरण सही से भरें',
      'passMismatch': 'पासवर्ड मेल नहीं खाते',
      'banned': 'आपका खाता एडमिन द्वारा निलंबित कर दिया गया है।',
    },
  };

  String _t(String key) => _text[_selectedLanguage]?[key] ?? _text['en']![key]!;

  Future<void> _submit() async {
    final input = _inputController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();

    if (input.isEmpty || password.isEmpty || (_isSignUp && (name.isEmpty || confirmPassword.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('fillAll')), backgroundColor: Colors.red),
      );
      return;
    }

    if (_isSignUp && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('passMismatch')), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = input.contains('@') ? input : '$input@starindia.app';
      UserCredential userCred;

      if (_isSignUp) {
        userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCred.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': name,
          'email': email,
          'phone': input.contains('@') ? '' : input,
          'language': _selectedLanguage,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCred.user!.uid;
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (doc.exists && doc.data()?['status'] == 'banned') {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_t('banned')), backgroundColor: Colors.red),
            );
          }
          return;
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'language': _selectedLanguage,
        }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _inputController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                icon: const Icon(Icons.language, color: Color(0xFF1E3A8A), size: 18),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFF1E3A8A),
                  child: Icon(Icons.star, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  _t('welcome'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 4),
                Text(_t('sub'), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 24),

                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: _t('name'),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1E3A8A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    labelText: _t('emailOrPhone'),
                    prefixIcon: const Icon(Icons.account_circle_outlined, color: Color(0xFF1E3A8A)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: _t('password'),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E3A8A)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 12),

                if (_isSignUp) ...[
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: _t('confirmPassword'),
                      prefixIcon: const Icon(Icons.lock_reset, color: Color(0xFF1E3A8A)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isSignUp ? _t('signup') : _t('login'),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? _t('toggleToLogin') : _t('toggleToSignup'),
                    style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
