import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/post.dart';
import 'package:reddit_clone/responsive/responsive.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(Post post, WidgetRef ref, BuildContext context) {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvote(Post post, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).upvote(post, ref);
  }

  void downvote(Post post, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).downvote(post, ref);
  }

  void navigateToModTools(String communityName, BuildContext context) {
    Routemaster.of(context).push("/mod-tools/${communityName}");
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push("/user-profile/${uid}");
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push("/r/${communityName}");
  }

  void navigateToCommentsScreen(BuildContext context, String postId) {
    Routemaster.of(context).push("/post-comments/${postId}");
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isTypeImage = post.type == "image";
    final isTypeText = post.type == "text";
    final isTypeLink = post.type == "link";
    final deviceHeight = MediaQuery.of(context).size.height;
    final currentUser = ref.watch(userProvider)!;
    final isGuest = !currentUser.isAuthenticated;

    return Responsive(
      child: Column(
        children: [
          Container(
            decoration:
                BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 4, 0, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post creator inforamtion
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // navigateTo community
                                  navigateToCommunity(
                                      context, post.communityName);
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              post.communityProfilePic),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Column(children: [
                                  GestureDetector(
                                    onTap: () {
                                      navigateToCommunity(
                                          context, post.communityName);
                                    },
                                    child: Text(
                                      "r/${post.communityName}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => navigateToUserProfile(
                                        context, post.uid),
                                    child: Text(
                                      "u/${post.username}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  )
                                ]),
                              ),
                              Spacer(),
                              if (currentUser.uid == post.uid)
                                IconButton(
                                  onPressed: () {
                                    deletePost(post, ref, context);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Pallete.redColor,
                                  ),
                                )
                            ],
                          ),
                          if (post.awards.isNotEmpty)
                            // Awards
                            Container(
                              padding: const EdgeInsets.all(4),
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  print(post.awards[index]);
                                  return Image.asset(
                                      Constants.awards[post.awards[index]]!);
                                },
                                itemCount: post.awards.length,
                              ),
                            ),
                          // Post Title
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              post.title,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // Post Content
                          if (isTypeImage)
                            SizedBox(
                              height: deviceHeight * 0.35,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: post.link!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeLink)
                            Container(
                              height: deviceHeight * 0.25,
                              padding: EdgeInsets.all(8),
                              width: double.infinity,
                              child: AnyLinkPreview(
                                link: post.link!,
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                              ),
                            ),
                          if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                post.description!,
                                style: TextStyle(color: Colors.grey),
                              ),
                              padding: const EdgeInsets.all(8.0),
                            ),
                          // Post votes
                          if (!isGuest)
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    upvote(post, ref);
                                  },
                                  icon: Icon(
                                    Icons.arrow_upward,
                                    size: 30,
                                    color:
                                        post.upvotes.contains(currentUser.uid)
                                            ? Pallete.blueColor
                                            : Pallete.whiteColor,
                                  ),
                                ),
                                Text(
                                    "${post.upvotes.length - post.downvotes.length == 0 ? "Vote" : post.upvotes.length - post.downvotes.length}"),
                                IconButton(
                                  onPressed: () {
                                    downvote(post, ref);
                                  },
                                  icon: Icon(
                                    Icons.arrow_downward,
                                    size: 30,
                                    color:
                                        post.downvotes.contains(currentUser.uid)
                                            ? Pallete.redColor
                                            : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  onPressed: () {
                                    navigateToCommentsScreen(context, post.id);
                                  },
                                  icon: Icon(
                                    Icons.comment,
                                    size: 30,
                                  ),
                                ),
                                TextButton(
                                  child: Text(
                                      "${post.commentCount == 0 ? "Comment" : post.commentCount}"),
                                  onPressed: () => navigateToCommentsScreen(
                                      context, post.id),
                                ),
                                Spacer(),
                                ref
                                    .watch(getCommunityByNameProvider(
                                        post.communityName))
                                    .when(
                                      data: (community) {
                                        return community.mods
                                                .contains(currentUser.uid)
                                            ? IconButton(
                                                onPressed: () {
                                                  // Naivagate To Mod Tools
                                                  navigateToModTools(
                                                      community.name, context);
                                                },
                                                icon: Icon(Icons.security),
                                              )
                                            : SizedBox();
                                      },
                                      error: (error, stackTrace) => ErrorText(
                                          errorText: error.toString()),
                                      loading: () => const Loader(),
                                    ),
                                // awarding
                                IconButton(
                                  onPressed: () {
                                    print(currentUser.awards);
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                            ),
                                            itemCount:
                                                currentUser.awards.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final award =
                                                  currentUser.awards[index];

                                              return GestureDetector(
                                                onTap: () => awardPost(
                                                    ref, award, context),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                      Constants.awards[award]!),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.card_giftcard_outlined),
                                )
                              ],
                            )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
