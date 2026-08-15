import 'package:flutter/material.dart';
import 'auth_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Choose Language / ભાષા પસંદ કરો'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Select your preferred language\nતમારી પસંદગીની ભાષા પસંદ કરો',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: languages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: const Icon(Icons.language, color: Colors.indigo),
                      title: Text(
                        lang['native']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(lang['name']!),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.indigo),
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

