import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  final String initialType;
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
    final XFile? pickedFile = widget.initialType == 'video'
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() => _mediaFile = File(pickedFile.path));
    }
  }

  Future<void> _publishPost() async {
    if (_mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo or video first.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String ext = widget.initialType == 'video' ? 'mp4' : 'jpg';
      String fileName = 'posts/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(_mediaFile!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      String authorName = user.displayName ?? 'Star User';
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()?['fullName'] != null) {
          authorName = userDoc.data()!['fullName'];
        }
      } catch (_) {}

      await FirebaseFirestore.instance.collection('posts').add({
        'authorId': user.uid,
        'authorName': authorName,
        'text': _captionController.text.trim(),
        'mediaUrl': downloadUrl,
        'type': widget.initialType,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.initialType == 'video' ? 'Video' : 'Photo'}'),
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
                ? Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.initialType == 'video'
                        ? const Center(child: Icon(Icons.video_file, size: 60, color: Color(0xFF1E3A8A)))
                        : Image.file(_mediaFile!, fit: BoxFit.cover),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: InkWell(
                      onTap: _pickMedia,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(widget.initialType == 'video' ? Icons.video_call : Icons.add_a_photo, size: 50, color: Colors.grey.shade600),
                          const SizedBox(height: 8),
                          Text(widget.initialType == 'video' ? "Select Video" : "Select Photo"),
                        ],
                      ),
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
