import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateToEditProfileScreen(BuildContext context) {
    Routemaster.of(context).push("/edit-profile/${uid}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(postControllerProvider);
    final currentUser = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) {
              return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        SliverAppBar(
                          floating: true,
                          snap: true,
                          expandedHeight: 250,
                          flexibleSpace: Stack(
                            children: [
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl: user.banner,
                                  fit: BoxFit.cover,
                                ),
                              )
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                // Column
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage: CachedNetworkImageProvider(
                                      user.profilePic,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                // if it is not your profile don't show the edit Profile button
                                uid == currentUser.uid
                                    ? Align(
                                        alignment: Alignment.topLeft,
                                        child: TextButton(
                                          onPressed: () {
                                            navigateToEditProfileScreen(
                                                context);
                                          },
                                          child: Text("Edit Profile"),
                                        ),
                                      )
                                    : SizedBox(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "u/${user.name}",
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // to show the button
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text("${user.karma} karma"),
                              ],
                            ),
                          ),
                        )
                      ],
                  body: isLoading
                      ? const Loader()
                      : ref.watch(userPostsProvider(uid)).when(
                            data: (posts) {
                              return ListView.builder(
                                itemBuilder: (context, index) {
                                  print(posts[index]);
                                  return PostCard(post: posts[index]);
                                },
                                itemCount: posts.length,
                              );
                            },
                            error: (error, stackTrace) => ErrorText(
                              errorText: error.toString(),
                            ),
                            loading: () => const Loader(),
                          ));
            },
            error: (error, stackTrace) =>
                ErrorText(errorText: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
