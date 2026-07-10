import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
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
  final PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    // Refresh data on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Only navigate via NavBars
        children: const [
          _FeedPage(),
          NotificationScreen(),
          ProfileScreen(),
        ],
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      extendBody: true, // Allow body to flow under the custom bar
      bottomNavigationBar: _ModernGreenNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
          );
        },
        unreadNotifications: notificationProvider.unreadCount,
      ),
    );
  }
}

class _ModernGreenNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadNotifications;

  const _ModernGreenNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.unreadNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding > 0 ? bottomPadding : 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF102118), // Deep dark green
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Selection Background
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            left: (MediaQuery.of(context).size.width - 40) / 3 * currentIndex + 5,
            top: 10,
            child: Container(
              width: (MediaQuery.of(context).size.width - 40) / 3 - 10,
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 1.5),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GreenNavItem(
                icon: Icons.grid_view_rounded,
                label: context.tr('home'),
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _GreenNavItem(
                icon: Icons.notifications_active_rounded,
                label: context.tr('alerts'),
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                badgeCount: unreadNotifications,
              ),
              _GreenNavItem(
                icon: Icons.person_rounded,
                label: context.tr('profile'),
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GreenNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _GreenNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: isSelected ? 1.2 : 1.0,
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 26,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
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
    final navBarBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          'CEKA',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: -1,
          ),
        ),
        actions: [
          _CircleIconButton(
            icon: Icons.search_rounded,
            onTap: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(Provider.of<AuthProvider>(context, listen: false).apiService),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Extra padding for the floating nav bar
          itemCount: _calculateItemCount(postProvider),
          itemBuilder: (context, index) {
            // Initial Loading Skeletons
            if (postProvider.isLoading && postProvider.posts.isEmpty) {
              if (index == 0) return const _ComposerCard();
              return const SkeletonPost();
            }

            // Header is always at the top
            if (index == 0) {
              return const _ComposerCard();
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
              return const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SkeletonPost(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: Padding(
        // Lift the FAB above the floating custom nav bar (70px tall + its own bottom margin).
        padding: EdgeInsets.only(
          bottom: 82 + (navBarBottomPadding > 0 ? navBarBottomPadding : 20),
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
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
            context.tr('noPostsYet'),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF102118)),
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard();

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
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                backgroundImage: user?.profilePhotoUrl != null
                    ? NetworkImage('${AppConstants.baseUrl}${user!.profilePhotoUrl}')
                    : null,
                child: user?.profilePhotoUrl == null
                    ? Icon(Icons.person_rounded, color: colorScheme.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      context.tr('shareSomething'),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _ComposerAction(
                  icon: Icons.photo_library_rounded,
                  label: context.tr('media'),
                  color: colorScheme.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                  ),
                ),
              ),
              Container(width: 1, height: 26, color: Colors.grey.shade200),
              Expanded(
                child: _ComposerAction(
                  icon: Icons.confirmation_number_rounded,
                  label: context.tr('buyTicket'),
                  color: colorScheme.tertiary,
                  onTap: () => _launchTicketUrl(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ComposerAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
