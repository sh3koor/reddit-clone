import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/Community.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push("/mod-tools/$name");
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  void leaveCommunity(
      WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .leaveCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) {
              // to show certain actions
              final isModerator = community.mods.contains(user.uid);
              final isJoined = community.members.contains(user.uid);
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    expandedHeight: 150,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: community.banner,
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
                                community.avatar,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "r/${community.name}",
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              if (!isGuest)
                                // to show the button
                                isModerator
                                    ? OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25),
                                        ),
                                        onPressed: () {
                                          navigateToModTools(context);
                                        },
                                        child: Text("Mod Tools"),
                                      )
                                    : OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25),
                                        ),
                                        onPressed: () {
                                          // check if the user already joined or not
                                          if (community.members
                                              .contains(user.uid)) {
                                            leaveCommunity(
                                                ref, community, context);
                                          } else {
                                            joinCommunity(
                                                ref, community, context);
                                          }
                                        },
                                        child:
                                            Text(isJoined ? "Joined" : "Join"),
                                      )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("${community.members.length} members")
                        ],
                      ),
                    ),
                  )
                ],
                body: Text("Display Community Posts"),
              );
            },
            error: (error, stackTrace) =>
                ErrorText(errorText: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
