import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/notification_provider.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../screens/post_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(context.tr('notifications')),
        actions: [
          if (notificationProvider.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: Text(context.tr('markAllRead')),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notificationProvider.fetchNotifications(),
        child: notificationProvider.isLoading && notificationProvider.notifications.isEmpty
            ? _buildSkeletonList()
            : notificationProvider.notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_none_rounded, size: 64, color: colorScheme.primary.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          context.tr('noNotifications'),
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notificationProvider.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notificationProvider.notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: notification.isRead ? Colors.white.withOpacity(0.7) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notification.isRead ? Colors.grey.withOpacity(0.05) : colorScheme.primary.withOpacity(0.1),
                          ),
                          boxShadow: [
                            if (!notification.isRead)
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: notification.isRead ? Colors.transparent : colorScheme.primary.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: notification.actor.profilePhotoUrl != null
                                  ? NetworkImage('${AppConstants.baseUrl}${notification.actor.profilePhotoUrl}')
                                  : null,
                              child: notification.actor.profilePhotoUrl == null 
                                  ? Icon(Icons.person_rounded, color: colorScheme.primary) 
                                  : null,
                            ),
                          ),
                          title: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
                              children: [
                                TextSpan(
                                  text: notification.actor.username,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                TextSpan(
                                  text: _getNotificationText(context, notification.type),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat.yMMMd().add_jm().format(notification.createdAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                            ),
                          ),
                          trailing: !notification.isRead
                              ? Container(
                                  width: 10, 
                                  height: 10, 
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary, 
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                )
                              : null,
                          onTap: () {
                            if (!notification.isRead) {
                              notificationProvider.markAsRead(notification.id);
                            }
                            if (notification.postId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PostDetailScreen(postId: notification.postId!)),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 12, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 10, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNotificationText(BuildContext context, String type) {
    final translationKey = {
      'post_comment': 'notifPostComment',
      'comment_reply': 'notifCommentReply',
      'post_like': 'notifPostLike',
      'comment_like': 'notifCommentLike',
    }[type];
    if (translationKey != null) return context.tr(translationKey);

    switch (type) {
      case 'post_comment':
        return ' a commenté votre post.';
      case 'comment_reply':
        return ' a répondu à votre commentaire.';
      case 'post_like':
        return ' a aimé votre post.';
      case 'comment_like':
        return ' a aimé votre commentaire.';
      default:
        return context.tr('notifInteraction');
    }
  }
}
