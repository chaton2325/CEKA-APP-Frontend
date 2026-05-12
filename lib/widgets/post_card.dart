import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary.withOpacity(0.28), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: colorScheme.surfaceVariant,
                      backgroundImage: post.author.profilePhotoUrl != null
                          ? NetworkImage('${AppConstants.baseUrl}${post.author.profilePhotoUrl}')
                          : null,
                      child: post.author.profilePhotoUrl == null 
                          ? Icon(Icons.person, color: colorScheme.primary) 
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.username,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(post.createdAt),
                          style: TextStyle(color: colorScheme.secondary.withOpacity(0.68), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (authProvider.user?.id == post.author.id)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: colorScheme.secondary),
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
                              title: const Text('Supprimer le post'),
                              content: const Text('Êtes-vous sûr de vouloir supprimer ce post ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success = await postProvider.deletePost(post.id);
                            if (context.mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Erreur lors de la suppression du post')),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(Icons.more_horiz, color: colorScheme.secondary),
                ],
              ),
              const SizedBox(height: 16),
              if (post.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    post.content,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              if (post.media.isNotEmpty) ...[
                MediaGrid(media: post.media),
                const SizedBox(height: 12),
                // Display non-image media as compact chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: post.media.where((m) => m.mediaType != MediaType.image).map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m.mediaType == MediaType.video ? Icons.videocam_rounded : Icons.audiotrack_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.filename,
                          style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Divider(height: 1, color: colorScheme.primary.withOpacity(0.08)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ActionButton(
                    icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    label: '${post.likesCount}',
                    color: isLiked ? Colors.red : colorScheme.secondary,
                    onTap: () => postProvider.togglePostLike(post.id, isLiked, userId: authProvider.user?.id),
                  ),
                  const SizedBox(width: 20),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${post.comments.length}',
                    color: colorScheme.secondary,
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
                    icon: Icon(Icons.share_outlined, color: colorScheme.secondary, size: 20),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
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
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
