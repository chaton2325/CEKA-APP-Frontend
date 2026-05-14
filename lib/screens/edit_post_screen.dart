import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../models/post.dart';
import '../models/media.dart';
import '../providers/post_provider.dart';
import '../utils/app_strings.dart';
import '../widgets/media_image.dart';
import '../widgets/video_player_widget.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _contentController;
  final List<File> _newMediaFiles = [];
  bool _replaceMedia = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'mp4', 'mov', 'webm', 'mkv', 
        'jpg', 'jpeg', 'png', 'webp'
      ],
    );

    if (result != null) {
      setState(() {
        _newMediaFiles.addAll(result.paths.where((path) => path != null).map((path) => File(path!)));
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _newMediaFiles.add(File(photo.path));
      });
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        _newMediaFiles.add(File(video.path));
      });
    }
  }

  void _showMediaOptions() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('addMedia'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MediaActionTile(
                  icon: Icons.camera_alt_rounded,
                  label: context.tr('camera'),
                  color: colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                _MediaActionTile(
                  icon: Icons.videocam_rounded,
                  label: context.tr('video'),
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _recordVideo();
                  },
                ),
                _MediaActionTile(
                  icon: Icons.photo_library_rounded,
                  label: context.tr('gallery'),
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final success = await Provider.of<PostProvider>(context, listen: false).updatePost(
      widget.post.id,
      content: _contentController.text,
      mediaFiles: _newMediaFiles.isNotEmpty ? _newMediaFiles : null,
      replaceMedia: _replaceMedia,
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('updatePostFailed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.tr('editPost')),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _isLoading
                ? Shimmer.fromColors(
                    baseColor: colorScheme.primary,
                    highlightColor: colorScheme.primary.withOpacity(0.5),
                    child: Container(
                      width: 80,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(context.tr('save')),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: context.tr('editYourText'),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    maxLines: null,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  if (widget.post.media.isNotEmpty && !_replaceMedia) ...[
                    Row(
                      children: [
                        Icon(Icons.perm_media_rounded, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(context.tr('currentMediaKept'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.post.media.length,
                        itemBuilder: (context, index) {
                          final media = widget.post.media[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (media.mediaType == MediaType.image)
                                  MediaImage(media: media, fit: BoxFit.cover)
                                else if (media.mediaType == MediaType.video)
                                  VideoPlayerWidget(url: media.url, autoPlay: false, isList: true)
                                else
                                  Container(
                                    color: colorScheme.primary.withOpacity(0.05),
                                    child: Icon(Icons.videocam_rounded, color: colorScheme.primary),
                                  ),
                                if (media.mediaType == MediaType.video)
                                  const Center(
                                    child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 32),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _replaceMedia ? colorScheme.error.withOpacity(0.05) : colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _replaceMedia,
                          activeColor: colorScheme.error,
                          onChanged: (val) => setState(() => _replaceMedia = val ?? false),
                        ),
                        Expanded(
                          child: Text(
                            context.tr('replaceExistingMedia'),
                            style: TextStyle(
                              color: _replaceMedia ? colorScheme.error : colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_newMediaFiles.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(context.tr('newMediaToAdd'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _newMediaFiles.length,
                      itemBuilder: (context, index) {
                        final file = _newMediaFiles[index];
                        final isImage = ['jpg', 'jpeg', 'png', 'webp'].any((ext) => file.path.toLowerCase().endsWith(ext));
                        
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (isImage)
                                Image.file(file, fit: BoxFit.cover)
                              else
                                Container(
                                  color: colorScheme.secondary.withOpacity(0.1),
                                  child: Icon(Icons.videocam_rounded, color: colorScheme.secondary),
                                ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: GestureDetector(
                                  onTap: () => setState(() => _newMediaFiles.removeAt(index)),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            color: Colors.white,
            child: Row(
              children: [
                _MediaButton(
                  icon: Icons.add_photo_alternate_outlined,
                  label: context.tr('media'),
                  onTap: _showMediaOptions,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MediaButton({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _MediaActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MediaActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
