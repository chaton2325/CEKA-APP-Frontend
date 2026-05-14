import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../models/comment.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/profile_screen.dart';
import '../utils/constants.dart';

class CommentBottomSheet extends StatefulWidget {
  final int postId;
  final List<Comment> initialComments;

  const CommentBottomSheet({super.key, required this.postId, required this.initialComments});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = false;
  int? _replyToId;
  String? _replyToUser;

  @override
  void initState() {
    super.initState();
    _comments = widget.initialComments;
  }

  Future<void> _refreshComments() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final updatedPost = await postProvider.getPostDetail(widget.postId);
    if (updatedPost != null && mounted) {
      setState(() {
        _comments = updatedPost.comments;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() => _isLoading = true);
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
        _isLoading = false;
      });
      _refreshComments();
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('Commentaires (${_comments.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _comments.isEmpty
                ? const Center(child: Text('Aucun commentaire pour le moment'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) => _buildCommentTile(_comments[index]),
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
                  Text('Réponse à @$_replyToUser', style: TextStyle(fontSize: 13, color: colorScheme.primary, fontWeight: FontWeight.w500)),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      hintText: _replyToUser != null ? 'Votre réponse...' : 'Ajouter un commentaire...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 12),
                _isLoading
                    ? Shimmer.fromColors(
                        baseColor: colorScheme.primary,
                        highlightColor: colorScheme.primary.withOpacity(0.5),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : IconButton(
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
          padding: EdgeInsets.only(left: isReply ? 40 : 0, bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(userId: comment.author.id)),
                  );
                },
                child: CircleAvatar(
                  radius: isReply ? 14 : 18,
                  backgroundImage: comment.author.profilePhotoUrl != null
                      ? NetworkImage('${AppConstants.baseUrl}${comment.author.profilePhotoUrl}')
                      : null,
                  child: comment.author.profilePhotoUrl == null ? const Icon(Icons.person, size: 18) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen(userId: comment.author.id)),
                            );
                          },
                          child: Text(comment.author.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
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
                          onTap: () async {
                            await Provider.of<PostProvider>(context, listen: false).toggleCommentLike(comment.id, isLiked);
                            _refreshComments();
                          },
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
                          child: Text('Répondre', style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (comment.replies.isNotEmpty)
          ...comment.replies.map((reply) => _buildCommentTile(reply, isReply: true)),
      ],
    );
  }
}
