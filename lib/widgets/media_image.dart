import 'package:flutter/material.dart';

import '../models/media.dart';
import '../utils/constants.dart';

String mediaImageUrl(Media media) => '${AppConstants.baseUrl}${media.url}';

class MediaImage extends StatelessWidget {
  final Media media;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MediaImage({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      mediaImageUrl(media),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;

        return _ImagePlaceholder(width: width, height: height);
      },
      errorBuilder: (context, error, stackTrace) {
        return _ImageError(width: width, height: height);
      },
    );

    if (borderRadius == null) return image;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }
}

NetworkImage mediaImageProvider(Media media) => NetworkImage(mediaImageUrl(media));

class _ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const _ImagePlaceholder({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  final double? width;
  final double? height;

  const _ImageError({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceVariant.withOpacity(0.6),
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: colorScheme.secondary,
        size: 28,
      ),
    );
  }
}
