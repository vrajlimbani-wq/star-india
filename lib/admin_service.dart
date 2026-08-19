import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // કોઈ યુઝરને બેન (Banned) કરવા માટેનું ફંક્શન
  Future<void> banUser(String userId) async {
    await _db.collection('users').doc(userId).update({
      'status': 'banned',
    });
  }

  // કોઈ યુઝરને ફરીથી એક્ટિવ (Active) કરવા માટે
  Future<void> activateUser(String userId) async {
    await _db.collection('users').doc(userId).update({
      'status': 'active',
    });
  }

  // કોઈ ખરાબ કમેન્ટ રિમૂવ કરવા માટે
  Future<void> removeComment(String postId, String commentId) async {
    await _db.collection('posts').doc(postId).collection('comments').doc(commentId).delete();
  }
}
