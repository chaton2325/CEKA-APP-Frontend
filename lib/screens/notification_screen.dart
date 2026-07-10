import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          context.tr('notifications'),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (notificationProvider.notifications.any((n) => !n.isRead))
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => notificationProvider.markAllAsRead(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.done_all_rounded, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('markAllRead'),
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: notificationProvider.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notificationProvider.notifications[index];
                      final typeStyle = _notificationTypeStyle(notification.type, colorScheme);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: notification.isRead ? Colors.white : colorScheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                                      backgroundImage: notification.actor.profilePhotoUrl != null
                                          ? NetworkImage('${AppConstants.baseUrl}${notification.actor.profilePhotoUrl}')
                                          : null,
                                      child: notification.actor.profilePhotoUrl == null
                                          ? Icon(Icons.person_rounded, color: colorScheme.primary)
                                          : null,
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: typeStyle.$2,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: Icon(typeStyle.$1, size: 11, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14.5),
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
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat.yMMMd().add_jm().format(notification.createdAt),
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8, top: 6),
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (25 * (index % 12)).ms).slideY(
                        begin: 0.05,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
      ),
    );
  }

  (IconData, Color) _notificationTypeStyle(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'post_like':
      case 'comment_like':
        return (Icons.favorite_rounded, Colors.red);
      case 'post_comment':
      case 'comment_reply':
        return (Icons.mode_comment_rounded, colorScheme.tertiary);
      default:
        return (Icons.notifications_rounded, colorScheme.primary);
    }
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
