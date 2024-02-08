import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/theme/pallete.dart';

class PostType extends ConsumerWidget {
  final IconData postIconType;
  final VoidCallback onTap;
  const PostType({super.key, required this.postIconType, required this.onTap});
  final double _cardHeightWidth = 120;
  final double _iconSize = 60;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: _cardHeightWidth,
        width: _cardHeightWidth,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              postIconType,
              size: _iconSize,
            ),
          ),
          elevation: 16,
          color: currentTheme.backgroundColor,
        ),
      ),
    );
  }
}
