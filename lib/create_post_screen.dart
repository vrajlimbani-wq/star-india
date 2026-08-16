import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedMedia;
  bool _isVideo = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // ફોટો સિલેક્ટ કરવા માટે
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _isVideo = false;
      });
    }
  }

  // રીલ/વીડિયો સિલેક્ટ કરવા માટે
  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _isVideo = true;
      });
    }
  }

  // ફાયરબેઝમાં અપલોડ કરવા માટે
  Future<void> _uploadPost() async {
    if (_selectedMedia == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કૃપા કરીને ફોટો/વીડિયો અથવા કેપ્શન ઉમેરો')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? mediaUrl;
      final user = FirebaseAuth.instance.currentUser;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // 1. Firebase Storage માં મીડિયા અપલોડ
      if (_selectedMedia != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child(_isVideo ? 'reels' : 'posts')
            .child('${user?.uid ?? "guest"}_$timestamp.${_isVideo ? "mp4" : "jpg"}');

        await ref.putFile(_selectedMedia!);
        mediaUrl = await ref.getDownloadURL();
      }

      // 2. Cloud Firestore માં પોસ્ટનો ડેટા સેવ કરવો
      await FirebaseFirestore.instance.collection(_isVideo ? 'reels' : 'posts').add({
        'userId': user?.uid ?? 'guest',
        'userName': user?.displayName ?? 'Vraj Limbani',
        'caption': _captionController.text.trim(),
        'mediaUrl': mediaUrl ?? '',
        'type': _isVideo ? 'reel' : 'post',
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isVideo ? 'Reel સફળતાપૂર્વક અપલોડ થઈ!' : 'Post સફળતાપૂર્વક અપલોડ થઈ!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('અપલોડમાં એરર આવી: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('નવી પોસ્ટ / Reel બનાવો', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _uploadPost,
                  child: const Text('શેર કરો', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'તમારા વિચારો અથવા કેપ્શન અહીં લખો...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedMedia != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                child: _isVideo
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_collection, size: 50, color: Color(0xFF1E3A8A)),
                            SizedBox(height: 8),
                            Text('Video/Reel સિલેક્ટ થયેલ છે'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedMedia!, fit: BoxFit.cover),
                      ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('ફોટો પસંદ કરો'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.video_library),
                  label: const Text('Reel પસંદ કરો'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
