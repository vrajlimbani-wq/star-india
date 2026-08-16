import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'translations.dart';

class AuthScreen extends StatefulWidget {
  final String selectedLanguage;
  const AuthScreen({super.key, this.selectedLanguage = 'en'});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginIdentifierController = TextEditingController();
  final _passwordController = TextEditingController();

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

  final _whatsappLinkController = TextEditingController();
  final _instagramLinkController = TextEditingController();
  final _facebookLinkController = TextEditingController();
  final _twitterLinkController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _selectedEducation = "primary";
  String _selectedProfessionType = "business";
  String _selectedProfile = "Personal";

  bool _isLogin = false;
  bool _isLoading = false;

  String t(String key) {
    final lang = appTranslations[widget.selectedLanguage] ?? appTranslations['en']!;
    return lang[key] ?? (appTranslations['en']![key] ?? key);
  }

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
        SnackBar(content: Text(t('err_pwd_len'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final identifier = _loginIdentifierController.text.trim();
        if (identifier.isEmpty) {
          throw Exception(t('err_empty_login'));
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
          throw Exception(t('err_empty_name'));
        }

        if (phone.isNotEmpty && phone.length != 10) {
          throw Exception(t('err_phone_invalid'));
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
          t(_isLogin ? 'app_title_login' : 'app_title_signup'),
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
              t(_isLogin ? 'header_login' : 'header_signup'),
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
                      TextField(
                        controller: _loginIdentifierController,
                        decoration: InputDecoration(
                          labelText: t('login_id_label'),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: t('login_pwd_label'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ] else ...[
                      Text(t('sec_personal'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              decoration: InputDecoration(labelText: t('first_name'), border: const OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              decoration: InputDecoration(labelText: t('last_name'), border: const OutlineInputBorder()),
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
                              ? t('pick_birthdate')
                              : '${t('birthdate_is')} ${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () => _selectBirthDate(context),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _cityController,
                        decoration: InputDecoration(labelText: t('city'), prefixIcon: const Icon(Icons.location_city), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _bioController,
                        maxLines: 2,
                        decoration: InputDecoration(labelText: t('bio'), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _hobbiesController,
                        decoration: InputDecoration(labelText: t('hobbies'), prefixIcon: const Icon(Icons.favorite_border), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      Text(t('sec_work'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedEducation,
                        decoration: InputDecoration(labelText: t('edu_label'), border: const OutlineInputBorder()),
                        items: [
                          DropdownMenuItem(value: 'primary', child: Text(t('edu_primary'))),
                          DropdownMenuItem(value: 'secondary', child: Text(t('edu_secondary'))),
                          DropdownMenuItem(value: 'higher_sec', child: Text(t('edu_higher_sec'))),
                          DropdownMenuItem(value: 'college', child: Text(t('edu_college'))),
                          DropdownMenuItem(value: 'higher_college', child: Text(t('edu_higher_college'))),
                          DropdownMenuItem(value: 'degree', child: Text(t('edu_degree'))),
                        ],
                        onChanged: (val) => setState(() => _selectedEducation = val!),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedProfessionType,
                        decoration: InputDecoration(labelText: t('prof_label'), border: const OutlineInputBorder()),
                        items: [
                          DropdownMenuItem(value: 'business', child: Text(t('prof_business'))),
                          DropdownMenuItem(value: 'private', child: Text(t('prof_private'))),
                          DropdownMenuItem(value: 'govt', child: Text(t('prof_govt'))),
                          DropdownMenuItem(value: 'freelance', child: Text(t('prof_freelance'))),
                          DropdownMenuItem(value: 'student', child: Text(t('prof_student'))),
                        ],
                        onChanged: (val) => setState(() => _selectedProfessionType = val!),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _companyOrGovtController,
                        decoration: InputDecoration(labelText: t('company_name'), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _designationController,
                        decoration: InputDecoration(labelText: t('designation'), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      Text(t('sec_contact'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _primaryPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: t('phone_label'), prefixIcon: const Icon(Icons.phone), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _secondaryPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: t('sec_phone_label'), prefixIcon: const Icon(Icons.phone_android), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: t('email_label'), prefixIcon: const Icon(Icons.email_outlined), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: t('pwd_label'), prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      Text(t('sec_social'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _whatsappLinkController,
                        decoration: InputDecoration(labelText: t('whatsapp'), prefixIcon: const Icon(Icons.chat), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _instagramLinkController,
                        decoration: InputDecoration(labelText: t('instagram'), prefixIcon: const Icon(Icons.camera_alt_outlined), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _facebookLinkController,
                        decoration: InputDecoration(labelText: t('facebook'), prefixIcon: const Icon(Icons.facebook), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _twitterLinkController,
                        decoration: InputDecoration(labelText: t('twitter'), prefixIcon: const Icon(Icons.alternate_email), border: const OutlineInputBorder()),
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
                                t(_isLogin ? 'btn_login' : 'btn_signup'),
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
                t(_isLogin ? 'switch_to_signup' : 'switch_to_login'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
