import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../screens/post_detail_screen.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../models/media.dart';
import '../screens/edit_post_screen.dart';
import 'comment_bottom_sheet.dart';
import 'media_grid.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final isLiked = authProvider.user != null && post.isLikedBy(authProvider.user!.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(postId: post.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    backgroundImage: post.author.profilePhotoUrl != null
                        ? NetworkImage('${AppConstants.baseUrl}${post.author.profilePhotoUrl}')
                        : null,
                    child: post.author.profilePhotoUrl == null 
                        ? Icon(Icons.person_rounded, color: colorScheme.primary) 
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.username,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(post.createdAt),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (authProvider.user?.id == post.author.id)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade600),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
                          );
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(context.tr('deletePost')),
                              content: Text(context.tr('deletePostConfirm')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(context.tr('cancel')),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: Text(context.tr('delete')),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success = await postProvider.deletePost(post.id);
                            if (context.mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.tr('deletePostError'))),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(context.tr('edit')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 14),
              if (post.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    post.content,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF2C3E50)),
                  ),
                ),
              if (post.media.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MediaGrid(media: post.media),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: post.media.where((m) => m.mediaType != MediaType.image).map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m.mediaType == MediaType.video ? Icons.play_circle_filled_rounded : Icons.audiotrack_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          m.filename,
                          style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _ActionButton(
                    icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    label: '${post.likesCount}',
                    color: isLiked ? Colors.red : Colors.grey.shade700,
                    activeColor: Colors.red,
                    isActive: isLiked,
                    onTap: () => postProvider.togglePostLike(post.id, isLiked, userId: authProvider.user?.id),
                  ),
                  const SizedBox(width: 12),
                  _ActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: '${post.comments.length}',
                    color: Colors.grey.shade700,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CommentBottomSheet(postId: post.id, initialComments: post.comments),
                      );
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.share_rounded, color: Colors.grey.shade600, size: 20),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? activeColor;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.activeColor,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final finalColor = isActive ? (activeColor ?? color) : color;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? finalColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: finalColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: finalColor, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
