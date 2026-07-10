import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../utils/app_strings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _profileImage;
  File? _bannerImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _usernameController.text = user.username;
      _bioController.text = user.bio ?? '';
    }
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

  Future<void> _pickImage(bool isProfile) async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _bannerImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _save() async {
    final success = await Provider.of<AuthProvider>(context, listen: false).updateProfile(
      username: _usernameController.text,
      bio: _bioController.text,
      profilePhoto: _profileImage,
      bannerPhoto: _bannerImage,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('updateFailed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('editProfile')),
        actions: [
          auth.isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.white.withOpacity(0.5),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                )
              : IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(context.tr('profilePhoto')),
              trailing: _profileImage != null ? Image.file(_profileImage!, width: 50) : const Icon(Icons.add_a_photo),
              onTap: () => _pickImage(true),
            ),
            ListTile(
              title: Text(context.tr('bannerPhoto')),
              trailing: _bannerImage != null ? Image.file(_bannerImage!, width: 50) : const Icon(Icons.add_a_photo),
              onTap: () => _pickImage(false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: context.tr('username')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: context.tr('bio')),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
