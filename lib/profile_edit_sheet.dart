import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditSheet {
  static void open(BuildContext context, String uid, Map<String, dynamic> currentData) {
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
                          _buildInput(nameController, 'પૂરું નામ (Full Name)'),
                          _buildInput(bioController, 'બાયો (Bio)', maxLines: 2),
                          _buildInput(hobbiesController, 'શોખ / પસંદગીઓ (Hobbies)'),
                          _buildInput(cityController, 'શહેર (City)'),
                          _buildInput(stateController, 'રાજ્ય (State)'),
                          _buildInput(educationController, 'અભ્યાસ / ડિગ્રી (Education)'),
                          _buildInput(professionController, 'ધંધો / નોકરી / પદ (Profession)'),
                          _buildInput(phone1Controller, 'મોબાઈલ ૧', keyboardType: TextInputType.phone),
                          _buildInput(phone2Controller, 'મોબાઈલ ૨', keyboardType: TextInputType.phone),
                          _buildInput(whatsappController, 'WhatsApp'),
                          _buildInput(instagramController, 'Instagram'),
                          _buildInput(facebookController, 'Facebook'),
                          _buildInput(twitterController, 'X (Twitter)'),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('સંપર્ક વિગત અન્યને બતાવો', style: TextStyle(fontSize: 14)),
                            value: isContactVisible,
                            activeColor: const Color(0xFF1E3A8A),
                            onChanged: (val) {
                              setSheetState(() {
                                isContactVisible = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('users').doc(uid).set({
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

                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('પ્રોફાઇલ સેવ થઈ ગઈ!'),
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

  static Widget _buildInput(TextEditingController ctrl, String lbl, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: lbl,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

