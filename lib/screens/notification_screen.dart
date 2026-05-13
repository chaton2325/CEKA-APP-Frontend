import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(
        title: Text(context.tr('notifications')),
        actions: [
          if (notificationProvider.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: Text(context.tr('markAllRead')),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notificationProvider.fetchNotifications(),
        child: notificationProvider.isLoading && notificationProvider.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : notificationProvider.notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 64, color: colorScheme.secondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(context.tr('noNotifications'), style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: notificationProvider.notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = notificationProvider.notifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: notification.actor.profilePhotoUrl != null
                              ? NetworkImage('${AppConstants.baseUrl}${notification.actor.profilePhotoUrl}')
                              : null,
                          child: notification.actor.profilePhotoUrl == null ? const Icon(Icons.person) : null,
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              TextSpan(
                                text: notification.actor.username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: _getNotificationText(context, notification.type)),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().add_jm().format(notification.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: !notification.isRead
                            ? Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle))
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
                      );
                    },
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
