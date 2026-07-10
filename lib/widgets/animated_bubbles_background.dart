import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Soft floating bubbles used as decorative background on auth screens.
class AnimatedBubblesBackground extends StatelessWidget {
  const AnimatedBubblesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bubbles = <_BubbleSpec>[
      _BubbleSpec(
        size: 150,
        left: -50,
        top: -50,
        color: colorScheme.primary,
        opacity: 0.08,
        duration: 6200,
      ),
      _BubbleSpec(
        size: 90,
        right: -30,
        top: 120,
        color: colorScheme.tertiary,
        opacity: 0.10,
        duration: 5200,
      ),
      _BubbleSpec(
        size: 55,
        left: 24,
        top: 260,
        color: colorScheme.secondary,
        opacity: 0.12,
        duration: 4600,
      ),
      _BubbleSpec(
        size: 120,
        right: -10,
        bottom: 160,
        color: colorScheme.primary,
        opacity: 0.07,
        duration: 7000,
      ),
      _BubbleSpec(
        size: 70,
        left: -20,
        bottom: 90,
        color: colorScheme.secondary,
        opacity: 0.10,
        duration: 5000,
      ),
      _BubbleSpec(
        size: 42,
        right: 70,
        bottom: 30,
        color: colorScheme.tertiary,
        opacity: 0.12,
        duration: 4200,
      ),
    ];

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(children: bubbles.map(_buildBubble).toList()),
      ),
    );
  }

  Widget _buildBubble(_BubbleSpec b) {
    return Positioned(
      left: b.left,
      right: b.right,
      top: b.top,
      bottom: b.bottom,
      child:
          Container(
                width: b.size,
                height: b.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: b.color.withOpacity(b.opacity),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -22,
                duration: b.duration.ms,
                curve: Curves.easeInOut,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveX(
                begin: 0,
                end: 12,
                duration: (b.duration * 1.3).round().ms,
                curve: Curves.easeInOut,
              ),
    );
  }
}

class _BubbleSpec {
  const _BubbleSpec({
    required this.size,
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.color,
    required this.opacity,
    required this.duration,
  });

  final double size;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final Color color;
  final double opacity;
  final int duration;
}
