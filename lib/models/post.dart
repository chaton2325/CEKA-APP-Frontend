import 'user.dart';
import 'comment.dart';
import 'media.dart';

class Post {
  final int id;
  final String content;
  final User author;
  final List<Media> media;
  final int likesCount;
  final List<User> likedBy;
  final List<Comment> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.content,
    required this.author,
    required this.media,
    required this.likesCount,
    required this.likedBy,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      author: User.fromJson(json['author']),
      media: (json['media'] as List? ?? [])
          .map((m) => Media.fromJson(m))
          .toList(),
      likesCount: json['likes_count'] ?? 0,
      likedBy: (json['liked_by'] as List? ?? [])
          .map((u) => User.fromJson(u))
          .toList(),
      comments: (json['comments'] as List? ?? [])
          .map((c) => Comment.fromJson(c))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool isLikedBy(int userId) {
    return likedBy.any((u) => u.id == userId);
  }
}
