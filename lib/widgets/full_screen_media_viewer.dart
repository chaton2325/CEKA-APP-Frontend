import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../models/media.dart';
import 'media_image.dart';

class FullScreenMediaViewer extends StatelessWidget {
  final List<Media> media;
  final int initialIndex;

  const FullScreenMediaViewer({super.key, required this.media, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: PhotoViewGallery.builder(
        itemCount: media.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: mediaImageProvider(media[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
