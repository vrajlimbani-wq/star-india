import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  final String initialType; // 'post', 'reel', અથવા 'story'

  const CreatePostScreen({super.key, this.initialType = 'post'});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedMedia;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // ફોટો સિલેક્ટ કરવા માટે (માત્ર પોસ્ટ માટે)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
    }
  }

  // વીડિયો સિલેક્ટ કરવા માટે (રીલ અને સ્ટોરી માટે)
  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
    }
  }

  // ફાયરબેઝમાં અપલોડ કરવા માટે
  Future<void> _uploadContent() async {
    if (_selectedMedia == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કૃપા કરીને મીડિયા અથવા લખાણ ઉમેરો')),
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
      final bool isVideo = widget.initialType != 'post';
      final String collectionName = widget.initialType == 'reel'
          ? 'reels'
          : widget.initialType == 'story'
              ? 'stories'
              : 'posts';

      // 1. Firebase Storage માં મીડિયા અપલોડ
      if (_selectedMedia != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child(collectionName)
            .child('${user?.uid ?? "guest"}_$timestamp.${isVideo ? "mp4" : "jpg"}');

        await ref.putFile(_selectedMedia!);
        mediaUrl = await ref.getDownloadURL();
      }

      // 2. Cloud Firestore માં ડેટા સેવ કરવો
      await FirebaseFirestore.instance.collection(collectionName).add({
        'userId': user?.uid ?? 'guest',
        'userName': user?.displayName ?? 'Vraj Limbani',
        'caption': _captionController.text.trim(),
        'mediaUrl': mediaUrl ?? '',
        'type': widget.initialType,
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        if (widget.initialType == 'story')
          'expiresAt': DateTime.now().add(const Duration(hours: 24)),
      });

      if (mounted) {
        String successMsg = 'પોસ્ટ સફળતાપૂર્વક અપલોડ થઈ!';
        if (widget.initialType == 'reel') successMsg = 'Reel સફળતાપૂર્વક અપલોડ થઈ!';
        if (widget.initialType == 'story') successMsg = 'Status / Story સફળતાપૂર્વક અપલોડ થઈ!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg)),
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
    // સ્ક્રીન મુજબ ટાઇટલ અને હિન્ટ સેટ કરવું
    String appBarTitle = 'નવી પોસ્ટ બનાવો';
    String hintText = 'તમારા વિચારો અથવા કેપ્શન અહીં લખો...';
    Color primaryColor = const Color(0xFF1E3A8A);

    if (widget.initialType == 'reel') {
      appBarTitle = 'નવી Reel / શોર્ટ વિડિયો અપલોડ કરો';
      hintText = 'Reel માટે કેપ્શન અને હેશટેગ (#) ઉમેરો...';
      primaryColor = Colors.orange.shade800;
    } else if (widget.initialType == 'story') {
      appBarTitle = 'વિડિયો સ્ટેટસ / સ્ટોરી ઉમેરો';
      hintText = 'સ્ટેટસ કેપ્શન લખો (ઓપ્શનલ)...';
      primaryColor = Colors.green.shade700;
    }

    final bool isVideoType = widget.initialType != 'post';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: const TextStyle(color: Colors.white, fontSize: 18)),
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
                  onPressed: _uploadContent,
                  child: const Text('શેર કરો', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedMedia != null)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                child: isVideoType
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_collection, size: 50, color: primaryColor),
                            const SizedBox(height: 8),
                            Text(
                              widget.initialType == 'reel'
                                  ? 'Reel વિડિયો સિલેક્ટ થયેલ છે'
                                  : 'Status વિડિયો સિલેક્ટ થયેલ છે',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedMedia!, fit: BoxFit.cover),
                      ),
              ),
            const SizedBox(height: 20),

            // ઓપ્શન મુજબ માત્ર જરૂરી બટન જ દેખાશે
            if (widget.initialType == 'post')
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('ગેલેરીમાંથી ફોટો પસંદ કરો'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              )
            else if (widget.initialType == 'reel')
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('ગેલેરીમાંથી Reel / વિડિયો પસંદ કરો'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              )
            else if (widget.initialType == 'story')
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.history_toggle_off),
                label: const Text('24 કલાક માટે વિડિયો સ્ટેટસ પસંદ કરો'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
