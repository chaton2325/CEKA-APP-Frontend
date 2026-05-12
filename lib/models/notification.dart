import 'user.dart';

class NotificationModel {
  final int id;
  final String type;
  final User actor;
  final int? postId;
  final int? commentId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.actor,
    this.postId,
    this.commentId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      actor: User.fromJson(json['actor']),
      postId: json['post_id'],
      commentId: json['comment_id'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
