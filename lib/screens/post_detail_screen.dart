import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../models/media.dart';
import 'profile_screen.dart';
import '../widgets/comment_bottom_sheet.dart';
import '../widgets/media_grid.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/skeleton_post_detail.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(backgroundColor: colorScheme.surface),
        body: const SkeletonPostDetail(),
      );
    }
    
    if (_post == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(backgroundColor: colorScheme.surface),
        body: Center(child: Text(context.tr('postNotFound'))),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final isLiked = authProvider.user != null && _post!.isLikedBy(authProvider.user!.id);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(context.tr('details'), style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Section
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userId: _post!.author.id)),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _post!.author.profilePhotoUrl != null
                          ? NetworkImage('${AppConstants.baseUrl}${_post!.author.profilePhotoUrl}')
                          : null,
                      child: _post!.author.profilePhotoUrl == null 
                          ? Icon(Icons.person_rounded, color: colorScheme.primary) 
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _post!.author.username, 
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.3)
                          ),
                          Text(
                            DateFormat.yMMMd().add_jm().format(_post!.createdAt), 
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Post Content
            if (_post!.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _post!.content, 
                  style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF2C3E50))
                ),
              ),
            
            if (_post!.media.isNotEmpty) ...[
              const SizedBox(height: 20),
              
              // Images Grid
              if (_post!.media.any((m) => m.mediaType == MediaType.image))
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MediaGrid(media: _post!.media, showAll: true),
                ),
              
              const SizedBox(height: 16),
              
              // Video and Audio Players
              ..._post!.media.where((m) => m.mediaType != MediaType.image).map((m) {
                if (m.mediaType == MediaType.video) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.play_circle_fill_rounded, color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(m.filename, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        VideoPlayerWidget(url: m.url, autoPlay: false, isList: true),
                      ],
                    ),
                  );
                } else {
                  // Audio or other
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.audiotrack_rounded, color: colorScheme.primary),
                      ),
                      title: Text(m.filename, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(context.tr('audio'), style: const TextStyle(fontSize: 12)),
                      onTap: () {},
                    ),
                  );
                }
              }),
            ],
            
            const SizedBox(height: 24),
            
            // Interaction Bar
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  _DetailActionButton(
                    icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    label: '${_post!.likesCount}',
                    color: isLiked ? Colors.red : Colors.grey.shade700,
                    isActive: isLiked,
                    activeColor: Colors.red,
                    onTap: _toggleLikePost,
                  ),
                  const SizedBox(width: 12),
                  _DetailActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: '${_post!.comments.length}',
                    color: Colors.grey.shade700,
                    onTap: _showComments,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.share_rounded, color: Colors.grey.shade600),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Comments Section Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_rounded, color: colorScheme.primary.withOpacity(0.5), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    '${_post!.comments.length} ${context.tr('comments').toLowerCase()}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showComments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 0,
                    ),
                    child: Text(context.tr('viewAllComments')),
                  ),
                ],
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
  final Color? activeColor;
  final bool isActive;
  final VoidCallback onTap;

  const _DetailActionButton({
    required this.icon, 
    required this.label, 
    required this.color, 
    this.activeColor,
    this.isActive = false,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final finalColor = isActive ? (activeColor ?? color) : color;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? finalColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: finalColor),
            const SizedBox(width: 10),
            Text(
              label, 
              style: TextStyle(color: finalColor, fontWeight: FontWeight.w800, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}
