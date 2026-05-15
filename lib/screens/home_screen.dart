import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/skeleton_post.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import '../providers/notification_provider.dart';
import '../utils/app_strings.dart';
import '../widgets/user_search_delegate.dart';
import 'ticket_webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const _FeedPage(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _ModernNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        unreadNotifications: notificationProvider.unreadCount,
      ),
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }
}

class _ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadNotifications;

  const _ModernNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.unreadNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding > 0 ? bottomPadding : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_rounded,
            outlineIcon: Icons.home_outlined,
            label: context.tr('home'),
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
            color: colorScheme.primary,
          ),
          _NavBarItem(
            icon: Icons.notifications_rounded,
            outlineIcon: Icons.notifications_none_rounded,
            label: context.tr('alerts'),
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
            color: colorScheme.primary,
            badgeCount: unreadNotifications,
          ),
          _NavBarItem(
            icon: Icons.person_rounded,
            outlineIcon: Icons.person_outline_rounded,
            label: context.tr('profile'),
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final int badgeCount;

  const _NavBarItem({
    required this.icon,
    required this.outlineIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? icon : outlineIcon,
                  color: isSelected ? color : Colors.grey.shade500,
                  size: 26,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Provider.of<PostProvider>(context, listen: false).fetchPosts();
    if (mounted) {
      await Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      Provider.of<PostProvider>(context, listen: false).fetchMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('CEKA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(Provider.of<AuthProvider>(context, listen: false).apiService),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          itemCount: _calculateItemCount(postProvider),
          itemBuilder: (context, index) {
            // Initial Loading Skeletons
            if (postProvider.isLoading && postProvider.posts.isEmpty) {
              if (index == 0) return const _FeedHeader();
              return const SkeletonPost();
            }

            // Header is always at the top
            if (index == 0) {
              return const _FeedHeader();
            }

            // Empty State (if not loading and no posts)
            if (postProvider.posts.isEmpty && !postProvider.isLoading) {
              return _buildEmptyState(context);
            }

            // Post Card
            final postIndex = index - 1;
            if (postIndex < postProvider.posts.length) {
              return PostCard(post: postProvider.posts[postIndex]);
            }

            // Loading More Indicator (Shimmer)
            if (postProvider.isLoadingMore) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: const SkeletonPost(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  int _calculateItemCount(PostProvider provider) {
    if (provider.isLoading && provider.posts.isEmpty) return 6; // Header + 5 skeletons
    if (provider.posts.isEmpty && !provider.isLoading) return 2; // Header + Empty state
    
    int count = provider.posts.length + 1; // Posts + Header
    if (provider.isLoadingMore) count++; // + Loading more
    return count;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            context.tr('noPostsYet') ?? 'Aucune publication pour le moment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 12),
          Text(
            'Soyez le premier à partager quelque chose !',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  Future<void> _launchTicketUrl(BuildContext context) async {
    const url = 'https://www.ebyaceka.org/register/form';
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } else {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TicketWebViewScreen(url: url)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('communityFeed'),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('feedSubtitle'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9), 
                        fontSize: 13, 
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => _launchTicketUrl(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.tertiary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.confirmation_number_rounded, color: colorScheme.tertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('buyTicket'),
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.tertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
