import 'package:flutter/material.dart';
import '../models/media.dart';
import 'full_screen_media_viewer.dart';
import 'media_image.dart';

class MediaGrid extends StatelessWidget {
  final List<Media> media;
  final bool showAll;

  const MediaGrid({super.key, required this.media, this.showAll = false});

  @override
  Widget build(BuildContext context) {
    final images = media.where((m) => m.mediaType == MediaType.image).toList();

    if (images.isEmpty) return const SizedBox.shrink();

    final displayImages = showAll ? images : images.take(4).toList();

    return LayoutBuilder(builder: (context, constraints) {
      if (displayImages.length == 1) {
        return _buildImage(context, displayImages[0], images, 0, constraints.maxWidth, 250);
      } else if (displayImages.length == 2) {
        return Row(
          children: [
            Expanded(child: _buildImage(context, displayImages[0], images, 0, (constraints.maxWidth - 8) / 2, 200)),
            const SizedBox(width: 8),
            Expanded(child: _buildImage(context, displayImages[1], images, 1, (constraints.maxWidth - 8) / 2, 200)),
          ],
        );
      } else if (displayImages.length == 3) {
        return Column(
          children: [
            _buildImage(context, displayImages[0], images, 0, constraints.maxWidth, 200),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildImage(context, displayImages[1], images, 1, (constraints.maxWidth - 8) / 2, 150)),
                const SizedBox(width: 8),
                Expanded(child: _buildImage(context, displayImages[2], images, 2, (constraints.maxWidth - 8) / 2, 150)),
              ],
            ),
          ],
        );
      } else if (showAll) {
        return Column(
          children: [
            for (var i = 0; i < displayImages.length; i += 2) ...[
              Row(
                children: [
                  Expanded(child: _buildImage(context, displayImages[i], images, i, (constraints.maxWidth - 8) / 2, 150)),
                  if (i + 1 < displayImages.length) ...[
                    const SizedBox(width: 8),
                    Expanded(child: _buildImage(context, displayImages[i + 1], images, i + 1, (constraints.maxWidth - 8) / 2, 150)),
                  ] else
                    const Spacer(),
                ],
              ),
              if (i + 2 < displayImages.length) const SizedBox(height: 8),
            ],
          ],
        );
      } else {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildImage(context, displayImages[0], images, 0, (constraints.maxWidth - 8) / 2, 150)),
                const SizedBox(width: 8),
                Expanded(child: _buildImage(context, displayImages[1], images, 1, (constraints.maxWidth - 8) / 2, 150)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildImage(context, displayImages[2], images, 2, (constraints.maxWidth - 8) / 2, 150)),
                const SizedBox(width: 8),
                Expanded(child: _buildImage(context, displayImages[3], images, 3, (constraints.maxWidth - 8) / 2, 150)),
              ],
            ),
          ],
        );
      }
    });
  }

  Widget _buildImage(BuildContext context, Media media, List<Media> allMedia, int index, double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FullScreenMediaViewer(media: allMedia, initialIndex: index)),
        );
      },
      child: MediaImage(
        media: media,
        width: width,
        height: height,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
