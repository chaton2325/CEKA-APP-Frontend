import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../models/media.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  Post? _post;
  bool _isLoading = true;
  int? _replyToId;
  String? _replyToUser;

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

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final success = await Provider.of<PostProvider>(context, listen: false).addComment(
      widget.postId, 
      _commentController.text,
      parentId: _replyToId,
    );
    if (success && mounted) {
      _commentController.clear();
      setState(() {
        _replyToId = null;
        _replyToUser = null;
      });
      _fetchPost();
    }
  }

  void _toggleLikePost() async {
    if (_post == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLiked = authProvider.user != null && _post!.isLikedBy(authProvider.user!.id);
    
    await Provider.of<PostProvider>(context, listen: false).togglePostLike(_post!.id, isLiked);
    _fetchPost();
  }

  void _toggleLikeComment(Comment comment) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLiked = authProvider.user != null && comment.likedBy.any((u) => u.id == authProvider.user!.id);
    
    await Provider.of<PostProvider>(context, listen: false).toggleCommentLike(comment.id, isLiked);
    _fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator()));
    if (_post == null) return const Scaffold(backgroundColor: Colors.white, body: Center(child: Text('Post not found')));

    final authProvider = Provider.of<AuthProvider>(context);
    final isLiked = authProvider.user != null && _post!.isLikedBy(authProvider.user!.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          '${AppConstants.baseUrl}${_post!.media.firstWhere((m) => m.mediaType == MediaType.image).url}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                        subtitle: Text(m.mediaType == MediaType.video ? 'Video' : 'Audio', style: const TextStyle(fontSize: 12)),
                        onTap: () {},
                      ),
                    )),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _DetailActionButton(
                        icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        label: '${_post!.likesCount}',
                        color: isLiked ? Colors.red : colorScheme.secondary,
                        onTap: _toggleLikePost,
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.chat_bubble_outline_rounded, size: 22, color: colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text('${_post!.comments.length}', style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 40),
                  Text('Comments (${_post!.comments.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  ..._post!.comments.map((comment) => _buildCommentTile(comment)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_replyToUser != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: colorScheme.primary.withOpacity(0.05),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Replying to @$_replyToUser', style: TextStyle(fontSize: 13, color: colorScheme.primary, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _replyToId = null;
                      _replyToUser = null;
                    }),
                    child: Icon(Icons.close_rounded, size: 18, color: colorScheme.secondary),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 8, top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _replyToUser != null ? 'Write a reply...' : 'Add a comment...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addComment,
                  icon: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment, {bool isReply = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLiked = authProvider.user != null && comment.likedBy.any((u) => u.id == authProvider.user!.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: isReply ? 44 : 0, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundImage: comment.author.profilePhotoUrl != null
                    ? NetworkImage('${AppConstants.baseUrl}${comment.author.profilePhotoUrl}')
                    : null,
                child: comment.author.profilePhotoUrl == null ? const Icon(Icons.person, size: 18) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment.author.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        Text(DateFormat.yMMMd().format(comment.createdAt), style: TextStyle(fontSize: 11, color: colorScheme.secondary.withOpacity(0.6))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleLikeComment(comment),
                          child: Row(
                            children: [
                              Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded, size: 16, color: isLiked ? Colors.red : colorScheme.secondary),
                              const SizedBox(width: 4),
                              Text('${comment.likesCount}', style: TextStyle(fontSize: 12, color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => setState(() {
                            _replyToId = comment.id;
                            _replyToUser = comment.author.username;
                          }),
                          child: Text('Reply', style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...comment.replies.map((reply) => _buildCommentTile(reply, isReply: true)),
      ],
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
