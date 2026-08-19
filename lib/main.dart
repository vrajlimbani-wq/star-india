import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }
  runApp(const StarIndiaApp());
}

class StarIndiaApp extends StatelessWidget {
  const StarIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            ),
          );
        }
        // જો યુઝર અગાઉથી લૉગિન હોય તો સીધું ફીડ સ્ક્રીન ખુલશે (Auto-Login)
        if (snapshot.hasData && snapshot.data != null) {
          return const FeedScreen();
        }
        // નવા યુઝર માટે ભાષા પસંદગી અને લૉગિન પેજ
        return const WelcomeLoginScreen();
      },
    );
  }
}

class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String _selectedLanguage = 'en'; // મૂળભૂત ભાષા English

  final Map<String, Map<String, String>> _localized = {
    'en': {
      'welcome': 'Welcome to Star India',
      'sub': 'Select Language & Continue',
      'name': 'Full Name',
      'emailOrPhone': 'Email or Mobile Number',
      'password': 'Password',
      'login': 'Login',
      'signup': 'Create New Account',
      'toggleToSignup': "Don't have an account? Sign Up",
      'toggleToLogin': 'Already have an account? Login',
      'fillAll': 'Please fill all details',
      'success': 'Success!',
    },
    'gu': {
      'welcome': 'સ્ટાર ઇન્ડિયા માં સ્વાગત છે',
      'sub': 'ભાષા પસંદ કરો અને આગળ વધો',
      'name': 'પૂરું નામ',
      'emailOrPhone': 'ઇમેઇલ અથવા મોબાઇલ નંબર',
      'password': 'પાસવર્ડ',
      'login': 'લૉગિન કરો',
      'signup': 'નવું એકાઉન્ટ બનાવો',
      'toggleToSignup': 'એકાઉન્ટ નથી? નવું એકાઉન્ટ બનાવો',
      'toggleToLogin': 'પહેલેથી એકાઉન્ટ છે? લૉગિન કરો',
      'fillAll': 'કૃપા કરીને બધી વિગતો ભરો',
      'success': 'સફળ થયું!',
    },
    'hi': {
      'welcome': 'स्टार इंडिया में आपका स्वागत है',
      'sub': 'भाषा चुनें और आगे बढ़ें',
      'name': 'पूरा नाम',
      'emailOrPhone': 'ईमेल या मोबाइल नंबर',
      'password': 'पासवर्ड',
      'login': 'लॉगिन करें',
      'signup': 'नया खाता बनाएं',
      'toggleToSignup': 'खाता नहीं है? नया खाता बनाएं',
      'toggleToLogin': 'पहले से खाता है? लॉगिन करें',
      'fillAll': 'कृपया सभी विवरण भरें',
      'success': 'सफल हुआ!',
    },
  };

  String _t(String key) => _localized[_selectedLanguage]?[key] ?? _localized['en']![key]!;

  Future<void> _submit() async {
    final input = _inputController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (input.isEmpty || password.isEmpty || (_isSignUp && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('fillAll')), backgroundColor: Colors.red),
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
          'language': _selectedLanguage,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCred.user!.uid;
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
    _inputController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                icon: const Icon(Icons.language, color: Color(0xFF1E3A8A), size: 20),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(Icons.star, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                _t('welcome'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 4),
              Text(_t('sub'), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 30),

              if (_isSignUp) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _t('name'),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  labelText: _t('emailOrPhone'),
                  prefixIcon: const Icon(Icons.account_circle, color: Color(0xFF1E3A8A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _t('password'),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF1E3A8A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
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
    );
  }
}
