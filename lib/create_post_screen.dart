import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  final String initialType; // 'photo' or 'video'
  final String userLanguage;
  const CreatePostScreen({super.key, required this.initialType, this.userLanguage = 'en'});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _mediaFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await _picker.pickMedia();
    if (pickedFile != null) {
      setState(() => _mediaFile = File(pickedFile.path));
    }
  }

  Future<void> _publishPost() async {
    if (_mediaFile == null) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(_mediaFile!);
      String downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'authorId': user.uid,
        'authorName': 'Star User',
        'text': _captionController.text.trim(),
        'mediaUrl': downloadUrl,
        'type': widget.initialType,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.initialType}'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: "Write your caption here...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _mediaFile != null
                ? Image.file(_mediaFile!, height: 250)
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: IconButton(
                      icon: const Icon(Icons.add_a_photo, size: 50),
                      onPressed: _pickMedia,
                    ),
                  ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                onPressed: _isLoading ? null : _publishPost,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Post to Star India", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
