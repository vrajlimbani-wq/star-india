import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false; // પાસવર્ડ જોવા માટે

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // કન્ફર્મ પાસવર્ડ માટે
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  String _formatEmail(String input) {
    input = input.trim();
    if (input.contains('@')) return input;
    return '$input@starindia.app';
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _formatEmail(_identifierController.text);
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        final uid = userCredential.user?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'fullName': _nameController.text.trim(),
            'email': email,
            'city': _cityController.text.trim(),
            'professionType': _professionController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'ભૂલ આવી'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.star_rounded, size: 64, color: Color(0xFF1E3A8A)),
                  const SizedBox(height: 12),
                  Text(_isLogin ? 'Star India માં લૉગિન' : 'નવું એકાઉન્ટ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 24),
                  if (!_isLogin) ...[
                    _buildTextField(_nameController, 'પૂરું નામ', Icons.person_outline),
                    _buildTextField(_cityController, 'શહેર', Icons.location_city_outlined),
                    _buildTextField(_professionController, 'વ્યવસાય', Icons.work_outline),
                  ],
                  _buildTextField(_identifierController, 'ઈમેલ અથવા મોબાઈલ નંબર', Icons.account_circle_outlined),
                  const SizedBox(height: 12),
                  
                  // પાસવર્ડ ફિલ્ડ
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'પાસવર્ડ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (val) => (val == null || val.length < 6) ? 'ઓછામાં ઓછા 6 અક્ષર' : null,
                  ),
                  
                  if (!_isLogin) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'પાસવર્ડ કન્ફર્મ કરો',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (val) => val != _passwordController.text ? 'પાસવર્ડ મેચ થતો નથી' : null,
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuth,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? 'નવું એકાઉન્ટ બનાવો' : 'પહેલેથી એકાઉન્ટ છે? લૉગિન કરો'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(icon)),
        validator: (val) => (val == null || val.isEmpty) ? 'આ ખાલી ન રાખી શકાય' : null,
      ),
    );
  }
}
