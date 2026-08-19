import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  final String initialType; // 'photo' or 'video'
  final String userLanguage; // 'en' or 'gu'

  const CreatePostScreen({
    super.key,
    this.initialType = 'photo',
    this.userLanguage = 'en',
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  String _t(String en, String gu) => widget.userLanguage == 'gu' ? gu : en;

  Future<void> _pickMedia() async {
    final XFile? file = widget.initialType == 'video'
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
      });
    }
  }

  Future<void> _publishPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('Please write something or select media.', 'કૃપા કરીને લખાણ લખો અથવા ફોટો પસંદ કરો.'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';
      final authorName = user?.displayName ?? 'Star User';

      String mediaUrl = '';
      if (_selectedFile != null) {
        final ext = widget.initialType == 'video' ? 'mp4' : 'jpg';
        final fileName = 'posts/${uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        
        // ફાઈલ અપલોડ ફિક્સ
        final uploadTask = await ref.putFile(_selectedFile!);
        mediaUrl = await uploadTask.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'authorUid': uid,
        'authorName': authorName,
        'text': text,
        'mediaUrl': mediaUrl,
        'mediaType': widget.initialType,
        'likes': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('Post uploaded successfully!', 'પોસ્ટ સફળતાપૂર્વક અપલોડ થઈ ગઈ!'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_t('Error', 'ભૂલ આવી')}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.initialType == 'video';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t('Create Post', 'નવી પોસ્ટ બનાવો'),
          style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _isLoading ? null : _publishPost,
              child: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_t('Post', 'પોસ્ટ'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: _t('Share your thoughts or update here...', 'તમારા વિચારો અથવા અપડેટ અહીં શેર કરો...'),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_selectedFile != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black12,
                    ),
                    child: isVideo
                        ? const Center(child: Icon(Icons.play_circle_fill, size: 50, color: Color(0xFF1E3A8A)))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_selectedFile!, fit: BoxFit.cover),
                          ),
                  ),
                  IconButton(
                    icon: const CircleAvatar(backgroundColor: Colors.black54, radius: 14, child: Icon(Icons.close, size: 16, color: Colors.white)),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ],
              ),
            const Divider(),
            ListTile(
              leading: Icon(isVideo ? Icons.video_call : Icons.add_photo_alternate, color: const Color(0xFF1E3A8A)),
              title: Text(
                isVideo ? _t('Add Video (Video / MP4)', 'વિડિઓ ઉમેરો (Video / MP4)') : _t('Add Photo (Photo / Image)', 'ફોટો ઉમેરો (Photo / Image)'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: _pickMedia,
            ),
          ],
        ),
      ),
    );
  }
}
