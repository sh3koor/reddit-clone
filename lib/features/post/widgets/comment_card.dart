import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../models/comment.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push("/user-profile/${uid}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getUserDataProvider(comment.uid)).when(
          data: (user) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => navigateToUserProfile(context, comment.uid),
                    child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(user.profilePic),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                navigateToUserProfile(context, comment.uid),
                            child: Text(
                              "u/${user.name}",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            comment.text,
                            style: TextStyle(fontWeight: FontWeight.w200),
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          error: (error, stackTrace) => ErrorText(
            errorText: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
