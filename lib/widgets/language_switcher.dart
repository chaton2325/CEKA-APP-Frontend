import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_strings.dart';

/// A visible, animated FR/EN pill toggle with a sliding indicator.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  static const _optionWidth = 60.0;
  static const _height = 38.0;

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isFrench = languageProvider.isFrench;
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: context.tr('language'),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment:
                  isFrench ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: _optionWidth,
                height: _height,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangOption(
                  label: context.tr('french'),
                  shortLabel: 'FR',
                  selected: isFrench,
                  width: _optionWidth,
                  height: _height,
                  onTap: () => languageProvider.setLanguage(AppLanguage.fr),
                ),
                _LangOption(
                  label: context.tr('english'),
                  shortLabel: 'EN',
                  selected: !isFrench,
                  width: _optionWidth,
                  height: _height,
                  onTap: () => languageProvider.setLanguage(AppLanguage.en),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms, delay: 100.ms)
        .slideY(begin: -0.4, end: 0, curve: Curves.easeOutCubic);
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.shortLabel,
    required this.selected,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final String label;
  final String shortLabel;
  final bool selected;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: selected ? Colors.white : colorScheme.primary,
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Center(child: Text(shortLabel)),
          ),
        ),
      ),
    );
  }
}
