import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/post_provider.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../widgets/post_card.dart';
import '../models/post.dart';
import '../models/user.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<Post> _userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    try {
      if (widget.userId == null || widget.userId == authProvider.user?.id) {
        _user = authProvider.user;
        if (_user != null) {
          _userPosts = await postProvider.fetchUserPosts(_user!.id);
        }
      } else {
        final response = await authProvider.apiService.getUserProfile(widget.userId!);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _user = User.fromJson(data['user']);
          _userPosts = await postProvider.fetchUserPosts(_user!.id);
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int _getTotalLikes() {
    return _userPosts.fold(0, (sum, post) => sum + post.likesCount);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _accountErrorMessage(String error) {
    if (error == 'invalid_current_password') {
      return context.tr('invalidCurrentPassword');
    }
    if (error == 'data_deletion_request_failed') {
      return context.tr('dataDeletionRequestFailed');
    }
    return context.tr('deleteAccountFailed');
  }

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('deleteAccountTitle')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('deleteAccountMessage')),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: context.tr('currentPassword')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    final password = passwordController.text.trim();
    passwordController.dispose();

    if (confirmed != true || password.isEmpty) return;

    final error = await context.read<AuthProvider>().deleteAccount(password);
    if (!mounted) return;

    if (error == null) {
      _showSnack(context.tr('deleteAccountSuccess'));
    } else {
      _showSnack(_accountErrorMessage(error));
    }
  }

  Future<void> _showDataDeletionRequestDialog() async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('requestDataDeletionTitle')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('requestDataDeletionMessage')),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: context.tr('reason')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.tr('sendRequest')),
            ),
          ],
        );
      },
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();

    if (confirmed != true) return;

    final error = await context.read<AuthProvider>().requestDataDeletion(reason);
    if (!mounted) return;

    _showSnack(error == null ? context.tr('dataDeletionRequestSent') : _accountErrorMessage(error));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isMe = _user != null && _user!.id == authProvider.user?.id;
    final totalLikes = _getTotalLikes();

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null) return Scaffold(body: Center(child: Text(context.tr('userNotFound'))));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            foregroundColor: const Color(0xFF102118),
            centerTitle: true,
            title: Text(
              _user!.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              if (isMe)
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  ),
                ),
              PopupMenuButton<AppLanguage>(
                tooltip: context.tr('language'),
                icon: const Icon(Icons.language_rounded),
                onSelected: (language) => context.read<LanguageProvider>().setLanguage(language),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: AppLanguage.fr,
                    child: Text(context.tr('french')),
                  ),
                  PopupMenuItem(
                    value: AppLanguage.en,
                    child: Text(context.tr('english')),
                  ),
                ],
              ),
              if (isMe)
                PopupMenuButton<String>(
                  tooltip: context.tr('accountActions'),
                  icon: const Icon(Icons.manage_accounts_rounded),
                  onSelected: (value) {
                    if (value == 'data_deletion') {
                      _showDataDeletionRequestDialog();
                    } else if (value == 'delete_account') {
                      _showDeleteAccountDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'data_deletion',
                      child: Row(
                        children: [
                          const Icon(Icons.privacy_tip_outlined, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(context.tr('requestDataDeletion'))),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete_account',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_forever_outlined, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.tr('deleteAccount'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (isMe)
                IconButton(
                  tooltip: context.tr('logout'),
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () => authProvider.logout(),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(user: _user!, postsCount: _userPosts.length, totalLikes: totalLikes),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user!.username,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _user!.email ?? '',
                        style: TextStyle(color: colorScheme.secondary.withOpacity(0.7), fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      if (_user!.bio != null && _user!.bio!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.primary.withOpacity(0.10)),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            _user!.bio!,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        )
                      else if (isMe)
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          ),
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(context.tr('addBio')),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            _user!.createdAt != null
                                ? '${context.tr('joinedIn')} ${DateFormat.yMMMM().format(_user!.createdAt!)}'
                                : context.tr('unknownJoinDate'),
                            style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: colorScheme.primary.withOpacity(0.10)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.article_rounded, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isMe ? context.tr('myPosts') : context.tr('posts'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
          if (_userPosts.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.10)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, color: colorScheme.primary, size: 30),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('noPostsYet'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _AnimatedProfilePostItem(
                    index: index,
                    child: PostCard(post: _userPosts[index]),
                  ),
                  childCount: _userPosts.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }
}

class _AnimatedProfilePostItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedProfilePostItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index % 5) * 35),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: colorScheme.secondary.withOpacity(0.75), fontSize: 11)),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;
  final int postsCount;
  final int totalLikes;

  const _ProfileHeader({
    required this.user,
    required this.postsCount,
    required this.totalLikes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 286,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.18),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (user.bannerPhotoUrl != null)
                      Image.network(
                        '${AppConstants.baseUrl}${user.bannerPhotoUrl}',
                        fit: BoxFit.cover,
                      )
                    else
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              colorScheme.primary,
                              const Color(0xFF59B36D),
                            ],
                          ),
                        ),
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF102118).withOpacity(0.66),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 24,
                      child: Text(
                        user.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 34,
            top: 164,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: colorScheme.surfaceVariant,
                backgroundImage: user.profilePhotoUrl != null
                    ? NetworkImage('${AppConstants.baseUrl}${user.profilePhotoUrl}')
                    : null,
                child: user.profilePhotoUrl == null
                    ? Icon(Icons.person, size: 42, color: colorScheme.primary)
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 218,
            child: Row(
              children: [
                _StatItem(label: context.tr('posts'), value: '$postsCount'),
                const SizedBox(width: 10),
                _StatItem(label: context.tr('likes'), value: '$totalLikes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
