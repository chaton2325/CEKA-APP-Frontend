import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/post_provider.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../widgets/post_card.dart';
import '../widgets/skeleton_post.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/media.dart';
import 'edit_profile_screen.dart';
import 'create_post_screen.dart';
import '../widgets/full_screen_media_viewer.dart';
import '../widgets/skeleton_profile.dart';

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
  bool _uploadingProfilePhoto = false;
  bool _uploadingBannerPhoto = false;
  final _picker = ImagePicker();

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

  Future<ImageSource?> _showImageSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(context.tr('takePhoto')),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(context.tr('chooseFromGallery')),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpdatePhoto(bool isProfilePhoto) async {
    final source = await _showImageSourceSheet();
    if (source == null || !mounted) return;

    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile == null || !mounted) return;

    setState(() {
      if (isProfilePhoto) {
        _uploadingProfilePhoto = true;
      } else {
        _uploadingBannerPhoto = true;
      }
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      profilePhoto: isProfilePhoto ? File(pickedFile.path) : null,
      bannerPhoto: isProfilePhoto ? null : File(pickedFile.path),
    );

    if (!mounted) return;

    setState(() {
      if (isProfilePhoto) {
        _uploadingProfilePhoto = false;
      } else {
        _uploadingBannerPhoto = false;
      }
      if (success) _user = authProvider.user;
    });

    if (!success) _showSnack(context.tr('updateFailed'));
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(context.tr('delete')),
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

    if (_isLoading) return const Scaffold(body: SkeletonProfile());
    if (_user == null) return Scaffold(body: Center(child: Text(context.tr('userNotFound'))));

    final navBarBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: Padding(
        // Lift the FAB above the floating custom nav bar when shown as a Home tab.
        padding: EdgeInsets.only(
          bottom: 82 + (navBarBottomPadding > 0 ? navBarBottomPadding : 20),
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            centerTitle: true,
            title: Text(
              _user!.username,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(
                  user: _user!,
                  postsCount: _userPosts.length,
                  totalLikes: totalLikes,
                  isMe: isMe,
                  uploadingProfilePhoto: _uploadingProfilePhoto,
                  uploadingBannerPhoto: _uploadingBannerPhoto,
                  onTapEditProfilePhoto: () => _pickAndUpdatePhoto(true),
                  onTapEditBanner: () => _pickAndUpdatePhoto(false),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user!.username,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                ),
                                Text(
                                  _user!.email ?? '',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) ...[
                            _ProfileSettingsButton(
                              authProvider: authProvider,
                              onShowDataDeletionDialog: _showDataDeletionRequestDialog,
                              onShowDeleteAccountDialog: _showDeleteAccountDialog,
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfileScreen()),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Text(context.tr('edit')),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_user!.bio != null && _user!.bio!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Text(
                            _user!.bio!,
                            style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF2C3E50)),
                          ),
                        )
                      else if (isMe)
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.primary.withOpacity(0.1), style: BorderStyle.solid),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(context.tr('addBio'), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade400),
                          const SizedBox(width: 8),
                          Text(
                            _user!.createdAt != null
                                ? '${context.tr('joinedIn')} ${DateFormat.yMMMM().format(_user!.createdAt!)}'
                                : context.tr('unknownJoinDate'),
                            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.grid_view_rounded, color: colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isMe ? context.tr('myPosts') : context.tr('posts'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
          if (_userPosts.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, color: colorScheme.primary.withOpacity(0.2), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('noPostsYet'),
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade400, fontSize: 16),
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
                  (context, index) => PostCard(post: _userPosts[index]),
                  childCount: _userPosts.length,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Text(value, style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _ProfileSettingsButton extends StatelessWidget {
  final AuthProvider authProvider;
  final VoidCallback onShowDataDeletionDialog;
  final VoidCallback onShowDeleteAccountDialog;

  const _ProfileSettingsButton({
    required this.authProvider,
    required this.onShowDataDeletionDialog,
    required this.onShowDeleteAccountDialog,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        tooltip: context.tr('accountActions'),
        icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
        onSelected: (value) {
          if (value == 'lang_fr') {
            context.read<LanguageProvider>().setLanguage(AppLanguage.fr);
          } else if (value == 'lang_en') {
            context.read<LanguageProvider>().setLanguage(AppLanguage.en);
          } else if (value == 'data_deletion') {
            onShowDataDeletionDialog();
          } else if (value == 'delete_account') {
            onShowDeleteAccountDialog();
          } else if (value == 'logout') {
            authProvider.logout();
          }
        },
        itemBuilder: (context) {
          final isFrench = context.read<LanguageProvider>().isFrench;
          return [
            PopupMenuItem(
              value: 'lang_fr',
              child: Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: isFrench ? colorScheme.primary : Colors.transparent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(context.tr('french'))),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'lang_en',
              child: Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: !isFrench ? colorScheme.primary : Colors.transparent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(context.tr('english'))),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'data_deletion',
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.tr('requestDataDeletion'))),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.tr('logout'))),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete_account',
              child: Row(
                children: [
                  const Icon(Icons.delete_forever_outlined, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('deleteAccount'),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;
  final int postsCount;
  final int totalLikes;
  final bool isMe;
  final bool uploadingProfilePhoto;
  final bool uploadingBannerPhoto;
  final VoidCallback onTapEditProfilePhoto;
  final VoidCallback onTapEditBanner;

  const _ProfileHeader({
    required this.user,
    required this.postsCount,
    required this.totalLikes,
    required this.isMe,
    required this.uploadingProfilePhoto,
    required this.uploadingBannerPhoto,
    required this.onTapEditProfilePhoto,
    required this.onTapEditBanner,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: user.bannerPhotoUrl != null ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FullScreenMediaViewer(
                      media: [Media(id: 0, url: user.bannerPhotoUrl!, mediaType: MediaType.image, filename: 'banner.jpg', position: 0)],
                      initialIndex: 0,
                    )),
                  );
                } : null,
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
                              colorScheme.secondary,
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
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe)
            Positioned(
              right: 24,
              top: 16,
              child: _PhotoEditBadge(
                icon: Icons.camera_alt_rounded,
                loading: uploadingBannerPhoto,
                onTap: onTapEditBanner,
              ),
            ),
          Positioned(
            left: 32,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: user.profilePhotoUrl != null ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FullScreenMediaViewer(
                          media: [Media(id: 0, url: user.profilePhotoUrl!, mediaType: MediaType.image, filename: 'profile.jpg', position: 0)],
                          initialIndex: 0,
                        )),
                      );
                    } : null,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.surfaceVariant,
                      backgroundImage: user.profilePhotoUrl != null
                          ? NetworkImage('${AppConstants.baseUrl}${user.profilePhotoUrl}')
                          : null,
                      child: user.profilePhotoUrl == null
                          ? Icon(Icons.person_rounded, size: 50, color: colorScheme.primary)
                          : null,
                    ),
                  ),
                  if (isMe)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: _PhotoEditBadge(
                        icon: Icons.edit_rounded,
                        size: 30,
                        loading: uploadingProfilePhoto,
                        onTap: onTapEditProfilePhoto,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 32,
            bottom: 0,
            child: Row(
              children: [
                _StatItem(label: context.tr('posts'), value: '$postsCount'),
                const SizedBox(width: 12),
                _StatItem(label: context.tr('likes'), value: '$totalLikes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoEditBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool loading;

  const _PhotoEditBadge({
    required this.icon,
    required this.onTap,
    this.size = 34,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: loading
            ? Padding(
                padding: EdgeInsets.all(size * 0.22),
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
