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
}

