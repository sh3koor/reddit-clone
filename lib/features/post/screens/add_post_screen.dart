import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/post/widgets/post_type.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToAddPostTypeScreen(String type, BuildContext context) {
    Routemaster.of(context).push("/add-post/${type}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        PostType(
          postIconType: Icons.image_outlined,
          onTap: () {
            navigateToAddPostTypeScreen("image", context);
          },
        ),
        PostType(
          postIconType: Icons.font_download_outlined,
          onTap: () {
            navigateToAddPostTypeScreen("text", context);
          },
        ),
        PostType(
          postIconType: Icons.link_outlined,
          onTap: () {
            navigateToAddPostTypeScreen("link", context);
          },
        ),
      ],
    );
  }
}
