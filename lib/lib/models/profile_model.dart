class UserProfile {
  final String id;
  final String name;
  final String profileType; // Personal, Business, Creator, Private
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.profileType,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileType': profileType,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String docId) {
    return UserProfile(
      id: docId,
      name: map['name'] ?? '',
      profileType: map['profileType'] ?? 'Personal',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}
