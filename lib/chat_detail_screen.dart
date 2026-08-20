import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChatDetailScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  const ChatDetailScreen({
    super.key,
    required this.peerId,
    required this.peerName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ImagePicker _picker = ImagePicker();
  late String _chatId;
  String _userLanguage = 'en';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    List<String> ids = [_currentUid, widget.peerId];
    ids.sort();
    _chatId = ids.join('_');
    _fetchLanguage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchLanguage() async {
    if (_currentUid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(_currentUid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userLanguage = doc.data()?['language'] ?? 'en';
          });
        }
      } catch (_) {}
    }
  }

  String _t(String en, String gu, String hi) {
    if (_userLanguage == 'gu') return gu;
    if (_userLanguage == 'hi') return hi;
    return en;
  }

  Future<void> _sendMessage({String? text, String? mediaUrl, String type = 'text'}) async {
    final msgText = text ?? _messageController.text.trim();
    if (msgText.isEmpty && mediaUrl == null) return;

    if (text == null && mediaUrl == null) {
      _messageController.clear();
    }

    String lastMsg = type == 'image'
        ? _t('📷 Photo', '📷 ફોટો', '📷 फोटो')
        : (type == 'video' ? _t('🎥 Video', '🎥 વિડિયો', '🎥 वीडियो') : msgText);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'senderId': _currentUid,
      'text': msgText,
      'mediaUrl': mediaUrl ?? '',
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'participants': [_currentUid, widget.peerId],
      'lastMessage': lastMsg,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _pickAndSendMedia(ImageSource source, bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source, imageQuality: 70);

      if (file == null) return;

      final mediaFile = File(file.path);
      final int fileSizeInBytes = await mediaFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 16.0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _t(
                  'File size exceeds 16 MB limit.',
                  'ફાઈલ સાઈઝ ૧૬ MB કરતાં વધુ છે.',
                  'फ़ाइल का आकार 16 MB से अधिक है।',
                ),
              ),
            ),
          );
        }
        return;
      }

      setState(() => _isUploading = true);

      String ext = isVideo ? 'mp4' : 'jpg';
      String path = 'chat_media/$_chatId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      Reference ref = FirebaseStorage.instance.ref().child(path);

      UploadTask uploadTask = ref.putFile(mediaFile);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();

      await _sendMessage(
        text: '',
        mediaUrl: downloadUrl,
        type: isVideo ? 'video' : 'image',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _attachmentOption(
              icon: Icons.photo_library,
              color: Colors.purple,
              label: _t('Gallery', 'ગેલેરી', 'गैलरी'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSendMedia(ImageSource.gallery, false);
              },
            ),
            _attachmentOption(
              icon: Icons.camera_alt,
              color: Colors.pink,
              label: _t('Camera', 'કેમેરો', 'कैमरा'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSendMedia(ImageSource.camera, false);
              },
            ),
            _attachmentOption(
              icon: Icons.videocam,
              color: Colors.orange,
              label: _t('Video', 'વિડિયો', 'वीडियो'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSendMedia(ImageSource.gallery, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _startCalling(bool isVideo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isVideo
              ? _t('Video Calling', 'વિડિયો કોલિંગ', 'वीडियो कॉलिंग')
              : _t('Audio Calling', 'ઓડિયો કોલિંગ', 'ऑडियो कॉलिंग'),
        ),
        content: Text(
          '${_t("Calling", "કોલ થઈ રહ્યો છે", "कॉल हो रहा है")} ${widget.peerName}...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _t('End Call', 'કોલ કટ કરો', 'कॉल समाप्त करें'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.peerName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () => _startCalling(false),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () => _startCalling(true),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading)
            const LinearProgressIndicator(color: Color(0xFF1E3A8A), minHeight: 3),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _t('Say Hi! to start conversation', 'વાતચીત શરૂ કરવા મેસેજ મોકલો', 'बातचीत शुरू करने के लिए नमस्ते भेजें'),
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data() as Map<String, dynamic>;
                    bool isMe = msg['senderId'] == _currentUid;
                    String type = msg['type'] ?? 'text';
                    String text = msg['text'] ?? '';
                    String mediaUrl = msg['mediaUrl'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (type == 'image' && mediaUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  mediaUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (ctx, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (type == 'video' && mediaUrl.isNotEmpty)
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
                                ),
                              ),
                            if (text.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: mediaUrl.isNotEmpty ? 6.0 : 0.0),
                                child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF1E3A8A)),
                    onPressed: _showAttachmentSheet,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: _t('Type a message...', 'મેસેજ લખો...', 'संदेश लिखें...'),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
