import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/post/widgets/comment_card.dart';
import 'package:routemaster/routemaster.dart';

import '../../../models/comment.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  // For web purposes we are passing the ID not the Post object
  final String postId;
  const CommentsScreen({required this.postId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentTextFieldController = TextEditingController();
  addComment(String content, String uid, String postId, BuildContext context) {
    ref
        .read(postControllerProvider.notifier)
        .addComment(content, uid, postId, context);
    setState(() {
      commentTextFieldController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return ref.watch(getPostByIdProvider(widget.postId)).when(
          data: (post) {
            return Scaffold(
              body: Column(
                children: [
                  PostCard(post: post),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      // to perform adding of the comment
                      onSubmitted: (value) {
                        addComment(commentTextFieldController.text, user.uid,
                            post.id, context);
                      },
                      controller: commentTextFieldController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Write a comment',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                  ),
                  Expanded(
                      child: ref
                          .watch(getPostCommentsProvider(widget.postId))
                          .when(
                            data: (comments) {
                              return ListView.builder(
                                itemBuilder: (context, index) {
                                  return CommentCard(
                                    comment: comments[index],
                                  );
                                },
                                itemCount: comments.length,
                              );
                            },
                            error: (error, stackTrace) => ErrorText(
                              errorText: error.toString(),
                            ),
                            loading: () => const Loader(),
                          ))
                ],
              ),
              appBar: AppBar(),
            );
          },
          error: (error, stackTrace) => ErrorText(errorText: error.toString()),
          loading: () => const Loader(),
        );
  }
}
