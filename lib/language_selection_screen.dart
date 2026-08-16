import 'package:flutter/material.dart';
import 'auth_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
      {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
      {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
      {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
      {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
      {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
      {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
      {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
      {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
      {'code': 'or', 'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
      {'code': 'as', 'name': 'Assamese', 'native': 'অসমীয়া'},
      {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Welcome to Star India',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.language, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Choose Your Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'તમારી પસંદગીની ભાષા પસંદ કરો',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: languages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                        child: Text(
                          lang['code']!.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        lang['native']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(lang['name']!),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1E3A8A)),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthScreen(selectedLanguage: lang['code']!),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
