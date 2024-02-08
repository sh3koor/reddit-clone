import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/Community.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    if (!isGuest) {
      return ref.watch(userCommunitiesProvider).when(
            data: (communities) {
              return ref
                  .watch(fetchUserCommunitiesPostsProvider(communities))
                  .when(
                    data: (posts) {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          print(posts[index]);
                          return PostCard(post: posts[index]);
                        },
                        itemCount: posts.length,
                      );
                    },
                    error: (error, stackTrace) {
                      return ErrorText(errorText: error.toString());
                    },
                    loading: () => const Loader(),
                  );
            },
            error: (error, stackTrace) {
              return ErrorText(
                errorText: error.toString(),
              );
            },
            loading: () => const Loader(),
          );
    } else {
      return ref.watch(guestPostsProvider).when(
            data: (posts) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  print(posts[index]);
                  return PostCard(post: posts[index]);
                },
                itemCount: posts.length,
              );
            },
            error: (error, stackTrace) {
              return ErrorText(errorText: error.toString());
            },
            loading: () => const Loader(),
          );
    }
  }
}
