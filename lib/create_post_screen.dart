import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  final String initialType;
  final String userLanguage;
  const CreatePostScreen({
    super.key,
    required this.initialType,
    this.userLanguage = 'en',
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _mediaFile;
  bool _isLoading = false;
  late String _selectedType;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  String _t(String en, String gu, String hi) {
    if (widget.userLanguage == 'gu') return gu;
    if (widget.userLanguage == 'hi') return hi;
    return en;
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? pickedFile = _selectedType == 'video'
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source, imageQuality: 75);

      if (pickedFile != null) {
        setState(() => _mediaFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_t("Error picking file", "ફાઈલ પસંદ કરવામાં ભૂલ", "फ़ाइल चुनने में त्रुटि")}: $e')),
        );
      }
    }
  }

  Future<void> _publishPost() async {
    if (_mediaFile == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Please add a photo, video or write something.',
              'કૃપા કરીને ફોટો, વિડિયો અથવા લખાણ ઉમેરો.',
              'कृपया फोटो, वीडियो या कुछ टेक्स्ट जोड़ें।',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String authorUid = user?.uid ?? 'anonymous_user';
      String authorName = user?.displayName ?? 'Star User';
      String authorPhoto = '';

      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            final data = userDoc.data()!;
            authorName = data['fullName'] ?? data['name'] ?? authorName;
            authorPhoto = data['photoUrl'] ?? '';
          }
        } catch (_) {}
      }

      String downloadUrl = '';
      if (_mediaFile != null) {
        String ext = _selectedType == 'video' ? 'mp4' : 'jpg';
        String fileName = 'posts/${authorUid}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);

        UploadTask uploadTask = ref.putFile(_mediaFile!);
        TaskSnapshot snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'authorId': authorUid,
        'authorName': authorName,
        'authorPhoto': authorPhoto,
        'text': _captionController.text.trim(),
        'mediaUrl': downloadUrl,
        'type': _mediaFile == null ? 'text' : _selectedType,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
        'commentsCount': 0,
        'sharesCount': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t('Post published successfully!', 'પોસ્ટ સફળતાપૂર્વક શેર થઈ ગઈ!', 'पोस्ट सफलतापूर्वक शेयर हो गई!'),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t('Create Post', 'નવી પોસ્ટ બનાવો', 'नई पोस्ट बनाएं'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ChoiceChip(
                  label: Text(_t('Photo', 'ફોટો', 'फोटो')),
                  selected: _selectedType == 'photo',
                  selectedColor: const Color(0xFF1E3A8A),
                  labelStyle: TextStyle(color: _selectedType == 'photo' ? Colors.white : Colors.black),
                  onSelected: (selected) {
                    if (selected) setState(() { _selectedType = 'photo'; _mediaFile = null; });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(_t('Video / Reel', 'વિડિયો / રીલ', 'वीडियो / रील')),
                  selected: _selectedType == 'video',
                  selectedColor: const Color(0xFF1E3A8A),
                  labelStyle: TextStyle(color: _selectedType == 'video' ? Colors.white : Colors.black),
                  onSelected: (selected) {
                    if (selected) setState(() { _selectedType = 'video'; _mediaFile = null; });
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: _t(
                  'Write your thoughts or caption here...',
                  'તમારા વિચારો અથવા કેપ્શન અહીં લખો...',
                  'अपने विचार या कैप्शन यहाँ लिखें...',
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (_mediaFile != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _selectedType == 'video'
                          ? const Center(child: Icon(Icons.video_file, size: 60, color: Color(0xFF1E3A8A)))
                          : Image.file(_mediaFile!, fit: BoxFit.cover),
                    ),
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 14,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                    onPressed: () => setState(() => _mediaFile = null),
                  ),
                ],
              )
            else
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => _pickMedia(ImageSource.gallery),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, size: 36, color: const Color(0xFF1E3A8A)),
                          const SizedBox(height: 6),
                          Text(_t('Gallery', 'ગેલેરી', 'गैलरी'), style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    VerticalDivider(color: Colors.grey.shade300, indent: 20, endIndent: 20),
                    InkWell(
                      onTap: () => _pickMedia(ImageSource.camera),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 36, color: const Color(0xFF1E3A8A)),
                          const SizedBox(height: 6),
                          Text(_t('Camera', 'કેમેરો', 'कैमरा'), style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _publishPost,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        _t('Post to Star India', 'Star India પર પોસ્ટ કરો', 'Star India पर पोस्ट करें'),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
