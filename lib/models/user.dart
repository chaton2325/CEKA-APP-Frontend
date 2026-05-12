class User {
  final int id;
  final String username;
  final String? email;
  final String? bio;
  final String? profilePhotoUrl;
  final String? bannerPhotoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.bio,
    this.profilePhotoUrl,
    this.bannerPhotoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      profilePhotoUrl: json['profile_photo_url'],
      bannerPhotoUrl: json['banner_photo_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
      'banner_photo_url': bannerPhotoUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
