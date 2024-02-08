import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/core/providers/storage_repository.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/repository/post_repository.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/models/Community.dart';
import 'package:reddit_clone/models/post.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../models/comment.dart';

// providing the fetchUserPosts for easy access
final fetchUserCommunitiesPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserCommunitiesPosts(communities);
});
final guestPostsProvider = StreamProvider((ref) {
  return ref.read(postControllerProvider.notifier).fetchGuestPosts();
});
final userPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(postControllerProvider.notifier).fetchUserPosts(uid);
});

final getPostCommentsProvider = StreamProvider.family(
  (ref, String postId) {
    return ref.watch(postControllerProvider.notifier).getPostComments(postId);
  },
);
final getPostByIdProvider = StreamProvider.family(
  (ref, String postId) {
    return ref.watch(postControllerProvider.notifier).getPostById(postId);
  },
);
// providing the controller
final postControllerProvider = StateNotifierProvider<PostController, bool>(
  (ref) {
    return PostController(
        postRepository: ref.watch(postRepositoryProvider),
        ref: ref,
        storageRepository: ref.watch(storageRepositoryProvider));
  },
);

class PostController extends StateNotifier<bool> {
  PostRepository _postRepository;
  StorageRepository _storageRepository;
  // this ref is need to access the user provider

  Ref _ref;
  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,

        // initialy the state is false, again the state is only for the purpose of loading or not
        super(false);

  // We need the context for the snackBar of errors

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String textContent,
  }) async {
    // loading
    state = true;
    // to create a random id
    String postId = Uuid().v1();
    final user = _ref.watch(userProvider);
    // creating the textPost
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user!.name,
      uid: user!.uid,
      type: "text",
      createdAt: DateTime.now(),
      // putting the text content
      description: textContent,
      awards: [],
    );
    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, "your post is posted");
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.textPost);
      Routemaster.of(context).pop();
    });
  }

  // Link post

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    // loading
    state = true;
    // to create a random id
    String postId = Uuid().v1();
    final user = _ref.watch(userProvider);
    // creating the linkPost
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user!.name,
      uid: user!.uid,
      type: "link",
      createdAt: DateTime.now(),
      // putting the text content
      link: link,
      awards: [],
    );
    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, "your post is posted");
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.linkPost);
      Routemaster.of(context).pop();
    });
  }

  // image post

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? imageFile,
    Uint8List? webFile,
  }) async {
    // loading
    state = true;
    // to create a random id
    String postId = Uuid().v1();
    final user = _ref.watch(userProvider);
    final imageUrlResult = await _storageRepository.storeFile(
        path: "posts/${selectedCommunity.name}",
        id: postId,
        file: imageFile,
        webFile: webFile);

    imageUrlResult.fold((l) {
      print(l.message);
      showSnackBar(context, l.message);
    }, (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user!.uid,
        type: "image",
        createdAt: DateTime.now(),
        // putting the image url as the link
        link: r,
        awards: [],
      );
      final res = await _postRepository.addPost(post);
      state = false;
      res.fold((l) {
        showSnackBar(context, l.message);
      }, (r) {
        showSnackBar(context, "your post is posted");
        _ref
            .read(userProfileControllerProvider.notifier)
            .updateUserKarma(UserKarma.imagePost);

        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserCommunitiesPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserCommunitiesPosts(communities);
    } else {
      // stream of empty list
      return Stream.value([]);
    }
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPosts();
  }

  void deletePost(Post post, BuildContext context) async {
    // isLoading
    state = true;
    final res = await _postRepository.deletePost(post);
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, "Post Deleted Successfully");
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.deletePost);
    });
    state = false;
  }

  void upvote(Post post, WidgetRef ref) async {
    final uid = ref.watch(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(Post post, WidgetRef ref) async {
    final uid = ref.watch(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  Stream<List<Post>> fetchUserPosts(String uid) {
    return _postRepository.fetchUserPosts(uid);
  }

  Stream<Post> getPostById(String uid) {
    return _postRepository.getPostById(uid);
  }

  Stream<List<Comment>> getPostComments(String postId) {
    return _postRepository.getPostComments(postId);
  }

  void addComment(
      String content, String uid, String postId, BuildContext context) async {
    final newComment = Comment(
        id: const Uuid().v1(),
        text: content,
        createdAt: DateTime.now(),
        postId: postId,
        uid: uid);
    final res = await _postRepository.addComment(newComment);

    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, "Your comment posted");
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.comment);
    });
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRepository.awardPost(post, award, user.uid);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
