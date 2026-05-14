import 'package:flutter/material.dart';
import '../models/media.dart';
import 'full_screen_media_viewer.dart';
import 'media_image.dart';
import 'video_player_widget.dart';

class MediaGrid extends StatelessWidget {
  final List<Media> media;
  final bool showAll;

  const MediaGrid({super.key, required this.media, this.showAll = false});

  @override
  Widget build(BuildContext context) {
    // Only handle images and videos in the grid
    final gridMedia = media.where((m) => m.mediaType == MediaType.image || m.mediaType == MediaType.video).toList();

    if (gridMedia.isEmpty) return const SizedBox.shrink();

    final displayMedia = showAll ? gridMedia : gridMedia.take(4).toList();

    return LayoutBuilder(builder: (context, constraints) {
      if (displayMedia.length == 1) {
        return _buildItem(context, displayMedia[0], gridMedia, 0, constraints.maxWidth, 250);
      } else if (displayMedia.length == 2) {
        return Row(
          children: [
            Expanded(child: _buildItem(context, displayMedia[0], gridMedia, 0, (constraints.maxWidth - 8) / 2, 200)),
            const SizedBox(width: 8),
            Expanded(child: _buildItem(context, displayMedia[1], gridMedia, 1, (constraints.maxWidth - 8) / 2, 200)),
          ],
        );
      } else if (displayMedia.length == 3) {
        return Column(
          children: [
            _buildItem(context, displayMedia[0], gridMedia, 0, constraints.maxWidth, 200),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildItem(context, displayMedia[1], gridMedia, 1, (constraints.maxWidth - 8) / 2, 150)),
                const SizedBox(width: 8),
                Expanded(child: _buildItem(context, displayMedia[2], gridMedia, 2, (constraints.maxWidth - 8) / 2, 150)),
              ],
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildItem(context, displayMedia[0], gridMedia, 0, (constraints.maxWidth - 8) / 2, 150)),
                const SizedBox(width: 8),
                Expanded(child: _buildItem(context, displayMedia[1], gridMedia, 1, (constraints.maxWidth - 8) / 2, 150)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildItem(context, displayMedia[2], gridMedia, 2, (constraints.maxWidth - 8) / 2, 150)),
                const SizedBox(width: 8),
                Expanded(child: _buildItem(context, displayMedia[3], gridMedia, 3, (constraints.maxWidth - 8) / 2, 150)),
              ],
            ),
          ],
        );
      }
    });
  }

  Widget _buildItem(BuildContext context, Media media, List<Media> allMedia, int index, double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FullScreenMediaViewer(media: allMedia, initialIndex: index)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (media.mediaType == MediaType.image)
                MediaImage(
                  media: media,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                )
              else
                // Use VideoPlayerWidget but with autoPlay: false for the feed preview
                VideoPlayerWidget(
                  url: media.url, 
                  autoPlay: false, 
                  isList: true
                ),
              
              // Add a play overlay for videos in the grid
              if (media.mediaType == MediaType.video)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
