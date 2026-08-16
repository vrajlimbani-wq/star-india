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
  // Authentication Fields
  final _loginIdentifierController = TextEditingController(); // Email or Phone
  final _passwordController = TextEditingController();

  // Signup Profile Details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _primaryPhoneController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _designationController = TextEditingController();
  final _companyOrGovtController = TextEditingController();

  // Social Links
  final _whatsappLinkController = TextEditingController();
  final _instagramLinkController = TextEditingController();
  final _facebookLinkController = TextEditingController();
  final _twitterLinkController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _selectedEducation = "પ્રાથમિક શિક્ષણ";
  String _selectedProfessionType = "ધંધો / બિઝનેસ";
  String _selectedProfile = "Personal";

  bool _isLogin = false;
  bool _isLoading = false;

  final List<String> _educationList = [
    "પ્રાથમિક શિક્ષણ",
    "માધ્યમિક શિક્ષણ",
    "ઉચ્ચતર માધ્યમિક શિક્ષણ",
    "કોલેજ",
    "ઉચ્ચતર કોલેજ",
    "ડિગ્રી / પ્રોફેશનલ",
  ];

  final List<String> _professionTypes = [
    "ધંધો / બિઝનેસ",
    "ખાનગી નોકરી (Private Job)",
    "સરકારી નોકરી (Govt Job)",
    "પ્રોફેશનલ / ફ્રીલાન્સર",
    "વિદ્યાર્થી (Student)",
  ];

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _submitAuth() async {
    final password = _passwordController.text.trim();

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('પાસવર્ડ ઓછામાં ઓછો 6 આંકડા/અક્ષરનો હોવો જોઈએ.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final identifier = _loginIdentifierController.text.trim();
        if (identifier.isEmpty) {
          throw Exception('કૃપા કરીને ઈમેલ અથવા મોબાઈલ નંબર દાખલ કરો.');
        }

        String authEmail = identifier;
        if (!identifier.contains('@')) {
          authEmail = '$identifier@starindia.app';
        }

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: authEmail,
          password: password,
        );
      } else {
        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();
        final email = _emailController.text.trim();
        final phone = _primaryPhoneController.text.trim();

        if (firstName.isEmpty || (email.isEmpty && phone.isEmpty)) {
          throw Exception('કૃપા કરીને નામ અને ઈમેલ અથવા 10 આંકડાનો મોબાઈલ નંબર ભરો.');
        }

        if (phone.isNotEmpty && phone.length != 10) {
          throw Exception('કૃપા કરીને માન્ય 10 આંકડાનો મોબાઈલ નંબર દાખલ કરો.');
        }

        String authEmail = email.isNotEmpty ? email : '$phone@starindia.app';

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: authEmail,
          password: password,
        );

        final fullName = '$firstName $lastName'.trim();

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'fullName': fullName,
          'primaryEmail': email,
          'primaryPhone': phone,
          'secondaryPhone': _secondaryPhoneController.text.trim(),
          'birthDate': _selectedBirthDate?.toIso8601String() ?? '',
          'city': _cityController.text.trim(),
          'bio': _bioController.text.trim(),
          'hobbies': _hobbiesController.text.trim(),
          'education': _selectedEducation,
          'professionType': _selectedProfessionType,
          'designation': _designationController.text.trim(),
          'companyOrGovt': _companyOrGovtController.text.trim(),
          'socialLinks': {
            'whatsapp': _whatsappLinkController.text.trim(),
            'instagram': _instagramLinkController.text.trim(),
            'facebook': _facebookLinkController.text.trim(),
            'twitter': _twitterLinkController.text.trim(),
          },
          'profileType': _selectedProfile,
          'language': widget.selectedLanguage,
          'accountCreatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        final displayName = _firstNameController.text.trim().isNotEmpty
            ? '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            : 'Star User';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainHomeScreen(
              userName: displayName,
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
  void dispose() {
    _loginIdentifierController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _primaryPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _hobbiesController.dispose();
    _designationController.dispose();
    _companyOrGovtController.dispose();
    _whatsappLinkController.dispose();
    _instagramLinkController.dispose();
    _facebookLinkController.dispose();
    _twitterLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          _isLogin ? 'Star India લોગિન' : 'Star India - એકાઉન્ટ બનાવો',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, size: 54, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 10),
            Text(
              _isLogin ? 'તમારા એકાઉન્ટમાં લોગિન કરો' : 'Star India માં નવી પ્રોફાઇલ બનાવો',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLogin) ...[
                      // Login Fields
                      TextField(
                        controller: _loginIdentifierController,
                        decoration: const InputDecoration(
                          labelText: 'ઈમેલ અથવા 10 આંકડાનો મોબાઈલ નંબર',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'પાસવર્ડ (ઓછામાં ઓછા 6 આંકડા)',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else ...[
                      // Signup - Section 1: Basic Info
                      const Text('વ્યક્તિગત વિગતો (Personal Details)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(labelText: 'ફર્સ્ટ નેમ *', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(labelText: 'લાસ્ટ નેમ', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        leading: const Icon(Icons.calendar_month, color: Color(0xFF1E3A8A)),
                        title: Text(
                          _selectedBirthDate == null
                              ? 'જન્મ તારીખ પસંદ કરો (Birth Date)'
                              : 'બર્થ ડેટ: ${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () => _selectBirthDate(context),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'શહેર / ગામ', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _bioController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'બાયો / તમારા વિશે ટૂંકમાં', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _hobbiesController,
                        decoration: const InputDecoration(labelText: 'તમારા શોખ / શું પસંદ છે તે', prefixIcon: Icon(Icons.favorite_border), border: OutlineInputBorder()),
                      ),

                      const SizedBox(height: 24),
                      // Signup - Section 2: Education & Profession
                      const Text('શિક્ષણ અને વ્યવસાય (Education & Work)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedEducation,
                        decoration: const InputDecoration(labelText: 'અભ્યાસ / શિક્ષણ લેવલ', border: OutlineInputBorder()),
                        items: _educationList.map((edu) => DropdownMenuItem(value: edu, child: Text(edu))).toList(),
                        onChanged: (val) => setState(() => _selectedEducation = val!),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedProfessionType,
                        decoration: const InputDecoration(labelText: 'વ્યવસાયનો પ્રકાર', border: OutlineInputBorder()),
                        items: _professionTypes.map((prof) => DropdownMenuItem(value: prof, child: Text(prof))).toList(),
                        onChanged: (val) => setState(() => _selectedProfessionType = val!),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _companyOrGovtController,
                        decoration: const InputDecoration(labelText: 'કંપનીનું નામ / સરકારી ખાતું / વ્યવસાયનું નામ', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _designationController,
                        decoration: const InputDecoration(labelText: 'ક્યાં સ્થાને / પદ પર છો (Designation)', border: OutlineInputBorder()),
                      ),

                      const SizedBox(height: 24),
                      // Signup - Section 3: Contact & Security
                      const Text('સંપર્ક અને સુરક્ષા (Contact & Login)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _primaryPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: '૧૦ આંકડાનો મોબાઈલ નંબર *', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _secondaryPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'બીજો મોબાઈલ નંબર (ઓપ્શનલ)', prefixIcon: Icon(Icons.phone_android), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'ઈમેલ એડ્રેસ', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'પાસવર્ડ બનાવો (ઓછામાં ઓછા 6 આંકડા) *', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                      ),

                      const SizedBox(height: 24),
                      // Signup - Section 4: Social Links
                      const Text('સોશિયલ મીડિયા લિંક્સ (Social Profiles)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _whatsappLinkController,
                        decoration: const InputDecoration(labelText: 'WhatsApp લિંક / નંબર', prefixIcon: Icon(Icons.chat), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _instagramLinkController,
                        decoration: const InputDecoration(labelText: 'Instagram લિંક / યુઝરનેમ', prefixIcon: Icon(Icons.camera_alt_outlined), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _facebookLinkController,
                        decoration: const InputDecoration(labelText: 'Facebook પ્રોફાઇલ લિંક', prefixIcon: Icon(Icons.facebook), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _twitterLinkController,
                        decoration: const InputDecoration(labelText: 'Twitter (X) પ્રોફાઇલ લિંક', prefixIcon: Icon(Icons.alternate_email), border: OutlineInputBorder()),
                      ),
                    ],

                    const SizedBox(height: 28),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _submitAuth,
                              child: Text(
                                _isLogin ? 'લોગિન કરો' : 'એકાઉન્ટ બનાવો અને શરૂ કરો',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? 'નવું એકાઉન્ટ બનાવવું છે? એકાઉન્ટ બનાવો' : 'પહેલેથી એકાઉન્ટ છે? લોગિન કરો',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
