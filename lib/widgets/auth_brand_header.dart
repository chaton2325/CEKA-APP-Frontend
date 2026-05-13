import 'package:flutter/material.dart';

import '../utils/constants.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key, required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
            colorScheme.tertiaryContainer,
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 16,
            child: _Ribbon(color: colorScheme.primary, width: 62),
          ),
          Positioned(
            right: 22,
            top: 26,
            child: _Ribbon(color: colorScheme.tertiary, width: 48),
          ),
          Positioned(
            left: 36,
            bottom: 22,
            child: _Ribbon(color: colorScheme.secondary, width: 44),
          ),
          Positioned(
            right: 36,
            bottom: 18,
            child: _Ribbon(color: colorScheme.primary, width: 68),
          ),
          Center(
            child: Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  AppConstants.logoUrl,
                  fit: BoxFit.cover,
                  semanticLabel: semanticLabel,
                  errorBuilder: (context, error, stackTrace) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      Icons.celebration_rounded,
                      color: colorScheme.primary,
                      size: 48,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        value: loadingProgress.expectedTotalBytes == null
                            ? null
                            : loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.35,
      child: Container(
        width: width,
        height: 10,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
