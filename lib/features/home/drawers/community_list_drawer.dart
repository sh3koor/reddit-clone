import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/sign_in_button.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/Community.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});
  // to sperate logic from ui
  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push("/create-community");
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push("/r/${community.name}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = !ref.watch(userProvider)!.isAuthenticated;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? SignInButton()
                : ListTile(
                    leading: Icon(Icons.add),
                    title: Text("Create a community"),
                    onTap: () {
                      // Go To create community Screen
                      navigateToCreateCommunity(context);
                    },
                  ),
            if (!isGuest)
              // this is how you deal with streamProvider
              ref.watch(userCommunitiesProvider).when(
                    data: (communities) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            return ListTile(
                              onTap: () {
                                navigateToCommunity(context, community);
                              },
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    community.avatar),
                              ),
                              title: Text(
                                "r/${community.name}",
                              ),
                            );
                          },
                        ),
                      );
                    },
                    error: (error, stackTrace) {
                      // print(stackTrace);
                      return ErrorText(
                        errorText: error.toString(),
                      );
                    },
                    loading: () => const Loader(),
                  )
          ],
        ),
      ),
    );
  }
}
