import 'user.dart';

class Comment {
  final int id;
  final String content;
  final User author;
  final int postId;
  final int? parentId;
  final int likesCount;
  final List<User> likedBy;
  final List<Comment> replies;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.content,
    required this.author,
    required this.postId,
    this.parentId,
    required this.likesCount,
    required this.likedBy,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      author: User.fromJson(json['author']),
      postId: json['post_id'],
      parentId: json['parent_id'],
      likesCount: json['likes_count'] ?? 0,
      likedBy: (json['liked_by'] as List? ?? [])
          .map((u) => User.fromJson(u))
          .toList(),
      replies: (json['replies'] as List? ?? [])
          .map((c) => Comment.fromJson(c))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
