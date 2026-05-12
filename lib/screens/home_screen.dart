import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import '../providers/notification_provider.dart';
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

  Future<void> _launchTicketUrl() async {
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
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      extendBody: true, // Important for floating nav bar
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: NavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              indicatorColor: colorScheme.primary.withOpacity(0.15),
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                if (index == 3) {
                  _launchTicketUrl();
                } else {
                  setState(() => _currentIndex = index);
                }
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: notificationProvider.unreadCount > 0,
                    label: Text('${notificationProvider.unreadCount}'),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                  selectedIcon: const Icon(Icons.notifications_rounded),
                  label: 'Alertes',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.confirmation_number_outlined),
                  selectedIcon: Icon(Icons.confirmation_number_rounded),
                  label: 'Billet',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded),
            )
          : null,
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
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await postProvider.fetchPosts();
          if (mounted) {
            await Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
          }
        },
        color: colorScheme.primary,
        child: postProvider.isLoading && postProvider.posts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), // Added padding for floating nav bar
                itemCount: postProvider.posts.length + (postProvider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= postProvider.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return PostCard(post: postProvider.posts[index]);
                },
              ),
      ),
    );
  }
}
