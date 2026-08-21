import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CreatePostScreen extends StatefulWidget {
  final String? initialType;
  final String? userLanguage;

  const CreatePostScreen({
    super.key,
    this.initialType,
    this.userLanguage,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedMedia;
  bool _isVideo = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialType == 'video') {
      _isVideo = true;
    }
  }

  Future<void> _pickMedia({required bool isVideo}) async {
    final XFile? file = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (file != null) {
      setState(() {
        _selectedMedia = File(file.path);
        _isVideo = isVideo;
      });
    }
  }

  Future<String?> _uploadMediaToCloud(File mediaFile, bool isVideo) async {
    try {
      const String cloudName = "dk6zcx8vc";
      const String uploadPreset = "star_india_free";

      final String resourceType = isVideo ? "video" : "image";
      final Uri uri = Uri.parse(
          "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload");

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', mediaFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_captionController.text.trim().isEmpty && _selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કૃપા કરીને લખાણ અથવા ફોટો/વીડિયો પસંદ કરો')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? mediaUrl;
      if (_selectedMedia != null) {
        mediaUrl = await _uploadMediaToCloud(_selectedMedia!, _isVideo);
      }

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('posts').add({
        'caption': _captionController.text.trim(),
        'mediaUrl': mediaUrl ?? '',
        'isVideo': _isVideo,
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'User',
        'language': widget.userLanguage ?? 'gu',
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('પોસ્ટ સફળતાપૂર્વક અપલોડ થઈ ગઈ!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _submitPost,
            icon: const Icon(Icons.send),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('અપલોડ થઈ રહ્યું છે, કૃપા કરીને રાહ જુઓ...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "તમારો મેસેજ અથવા ન્યૂઝ અહીં લખો...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedMedia != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200,
                          ),
                          child: _isVideo
                              ? const Center(
                                  child: Icon(Icons.videocam,
                                      size: 64, color: Color(0xFF1E3A8A)),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedMedia!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedMedia = null;
                            });
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickMedia(isVideo: false),
                          icon: const Icon(Icons.image),
                          label: const Text('ફોટો પસંદ કરો'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickMedia(isVideo: true),
                          icon: const Icon(Icons.videocam),
                          label: const Text('વીડિયો પસંદ કરો'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                      ),
                      onPressed: _submitPost,
                      child: const Text('પોસ્ટ કરો',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
