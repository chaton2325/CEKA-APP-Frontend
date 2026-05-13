import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../models/media.dart';
import '../widgets/comment_bottom_sheet.dart';
import '../widgets/media_grid.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    final post = await Provider.of<PostProvider>(context, listen: false).getPostDetail(widget.postId);
    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
      });
    }
  }

  void _toggleLikePost() async {
    if (_post == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLiked = authProvider.user != null && _post!.isLikedBy(authProvider.user!.id);
    
    await Provider.of<PostProvider>(context, listen: false).togglePostLike(
      _post!.id, 
      isLiked, 
      userId: authProvider.user?.id
    );
    _fetchPost();
  }

  void _showComments() {
    if (_post == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(postId: _post!.id, initialComments: _post!.comments),
    ).then((_) => _fetchPost());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator()));
    if (_post == null) return Scaffold(backgroundColor: Colors.white, body: Center(child: Text(context.tr('postNotFound'))));

    final authProvider = Provider.of<AuthProvider>(context);
    final isLiked = authProvider.user != null && _post!.isLikedBy(authProvider.user!.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(context.tr('details'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: _post!.author.profilePhotoUrl != null
                      ? NetworkImage('${AppConstants.baseUrl}${_post!.author.profilePhotoUrl}')
                      : null,
                  child: _post!.author.profilePhotoUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_post!.author.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(DateFormat.yMMMd().add_jm().format(_post!.createdAt), style: TextStyle(color: colorScheme.secondary.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_post!.content.isNotEmpty)
              Text(_post!.content, style: const TextStyle(fontSize: 17, height: 1.5)),
            if (_post!.media.isNotEmpty) ...[
              const SizedBox(height: 16),
              if (_post!.media.any((m) => m.mediaType == MediaType.image))
                MediaGrid(media: _post!.media, showAll: true),
              const SizedBox(height: 12),
              ..._post!.media.where((m) => m.mediaType != MediaType.image).map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(m.mediaType == MediaType.video ? Icons.videocam_rounded : Icons.audiotrack_rounded, color: colorScheme.primary),
                  ),
                  title: Text(m.filename, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(m.mediaType == MediaType.video ? context.tr('video') : context.tr('audio'), style: const TextStyle(fontSize: 12)),
                  onTap: () {},
                ),
              )),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                _DetailActionButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  label: '${_post!.likesCount}',
                  color: isLiked ? Colors.red : colorScheme.secondary,
                  onTap: _toggleLikePost,
                ),
                const SizedBox(width: 24),
                _DetailActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${_post!.comments.length}',
                  color: colorScheme.secondary,
                  onTap: _showComments,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: colorScheme.secondary),
                  onPressed: () {},
                ),
              ],
            ),
            const Divider(height: 40),
            Center(
              child: TextButton.icon(
                onPressed: _showComments,
                icon: const Icon(Icons.comment_rounded),
                label: Text(context.tr('viewAllComments'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DetailActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
