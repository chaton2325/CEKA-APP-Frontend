import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isMe = _user != null && _user!.id == authProvider.user?.id;
    final totalLikes = _getTotalLikes();

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null) return const Scaffold(body: Center(child: Text('Utilisateur non trouvé')));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
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
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        image: _user!.bannerPhotoUrl != null
                            ? DecorationImage(
                                image: NetworkImage('${AppConstants.baseUrl}${_user!.bannerPhotoUrl}'),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _user!.bannerPhotoUrl == null
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: -45,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: _user!.profilePhotoUrl != null
                              ? NetworkImage('${AppConstants.baseUrl}${_user!.profilePhotoUrl}')
                              : null,
                          child: _user!.profilePhotoUrl == null 
                              ? Icon(Icons.person, size: 40, color: colorScheme.primary) 
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _StatItem(label: 'Posts', value: '${_userPosts.length}'),
                      const SizedBox(width: 30),
                      _StatItem(label: 'Likes', value: '$totalLikes'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                            color: colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
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
                          label: const Text('Ajouter une biographie'),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            _user!.createdAt != null
                                ? 'Rejoint en ${DateFormat.yMMMM().format(_user!.createdAt!)}'
                                : 'Date d\'inscription inconnue',
                            style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        isMe ? 'Mes Publications' : 'Publications',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_userPosts.isEmpty)
            const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('Aucune publication pour le moment'),
              )),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PostCard(post: _userPosts[index]),
                  childCount: _userPosts.length,
                ),
              ),
            ),
          if (isMe)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: () => authProvider.logout(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Déconnexion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }
}
