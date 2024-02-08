import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  Future<void> signout(WidgetRef ref) async {
    ref.read(authControllerProvider.notifier).logout();
  }

  void navigateToUserProfile(String uid, BuildContext context) {
    Routemaster.of(context).push("/user-profile/${uid}");
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                navigateToUserProfile(currentUser.uid, context);
              },
              child: CircleAvatar(
                radius: 70,
                backgroundImage:
                    CachedNetworkImageProvider(currentUser.profilePic),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(currentUser.name),
            SizedBox(
              height: 10,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("My profile"),
              onTap: () {
                navigateToUserProfile(currentUser.uid, context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Pallete.redColor,
              ),
              onTap: () {
                signout(ref);
              },
              title: Text("Log out"),
            ),
            Switch.adaptive(
              // if dark it is open
              value: ref.watch(themeProvider.notifier).mode == eThemeMode.dark,
              onChanged: (value) {
                toggleTheme(ref);
              },
            )
          ],
        ),
      ),
    );
  }
}
