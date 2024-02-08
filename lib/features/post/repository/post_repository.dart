import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';

import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/Community.dart';
import 'package:reddit_clone/models/post.dart';

import '../../../core/Failure.dart';
import '../../../models/comment.dart';

final postRepositoryProvider = Provider(
  (ref) {
    return PostRepository(firestore: ref.watch(firestoreProvider));
  },
);

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // getters
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid addPost(Post post) async {
    try {
      // post.id is the id in the db
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // fetch  posts of communities where the user is part of
  // communities are the user communtites
  Stream<List<Post>> fetchUserCommunitiesPosts(List<Community> communities) {
    // this will give the posts of the related communtites
    final res = _posts
        .where("communityName",
            whereIn: communities.map((e) => e.name).toList())
        .orderBy("createdAt", descending: true);

    // Now we create the the Stream of lists
    return res.snapshots().map((event) {
      List<Post> userCommunitiesPosts = [];
      event.docs.forEach(
        (post) {
          // post is a map comming from firestore
          userCommunitiesPosts.add(
            Post.fromMap(post.data() as Map<String, dynamic>),
          );
        },
      );
      return userCommunitiesPosts;
    });
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  void upvote(Post post, String uid) async {
    if (post.downvotes.contains(uid)) {
      // I am already putting it as a downvote
      _posts.doc(post.id).update({
        "downvotes": FieldValue.arrayRemove([uid])
      });
    }
    if (post.upvotes.contains(uid)) {
      // I am already upvoting
      // it means unupvote
      _posts.doc(post.id).update({
        "upvotes": FieldValue.arrayRemove([uid])
      });
    } else {
      _posts.doc(post.id).update({
        "upvotes": FieldValue.arrayUnion([uid])
      });
    }
  }

  void downvote(Post post, String uid) async {
    if (post.upvotes.contains(uid)) {
      // I am already putting it as a downvote
      _posts.doc(post.id).update({
        "upvotes": FieldValue.arrayRemove([uid])
      });
    }
    if (post.downvotes.contains(uid)) {
      // I am already upvoting
      // it means unupvote
      _posts.doc(post.id).update({
        "downvotes": FieldValue.arrayRemove([uid])
      });
    } else {
      _posts.doc(post.id).update({
        "downvotes": FieldValue.arrayUnion([uid])
      });
    }
  }

  // Fetch all posts of the user in all communities
  Stream<List<Post>> fetchUserPosts(String uid) {
    final res = _posts
        .where("uid", isEqualTo: uid)
        .orderBy("createdAt", descending: true);

    // Now we create the the Stream of lists
    return res.snapshots().map((event) {
      List<Post> userPosts = [];
      event.docs.forEach(
        (post) {
          // post is a map comming from firestore
          userPosts.add(
            Post.fromMap(post.data() as Map<String, dynamic>),
          );
        },
      );
      return userPosts;
    });
  }

  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

// Stream of list of comments
  Stream<List<Comment>> getPostComments(String postId) {
    final res = _comments
        .where("postId", isEqualTo: postId)
        .orderBy("createdAt", descending: true);

    return res.snapshots().map((event) {
      List<Comment> postComments = [];
      event.docs.forEach(
        (post) {
          // post is a map comming from firestore
          postComments.add(
            Comment.fromMap(post.data() as Map<String, dynamic>),
          );
        },
      );
      return postComments;
    });
  }

  FutureVoid addComment(Comment comment) async {
    try {
      // comment.id is the id in the db
      if (comment.text.isEmpty)
        return left(
          Failure("You did not write something"),
        );
      // update post comments number
      final postSnapshot = await _posts.doc(comment.postId).get();
      Post postData = postSnapshot.data() as Post;
      final newPost =
          postData.copyWith(commentCount: postData.commentCount + 1);
      _posts.doc(postData.id).set(newPost.toMap());

      return right(_comments.doc(comment.id).set(comment.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid awardPost(Post post, String award, String senderId) async {
    try {
      // update post
      _posts.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award]),
      });
      // update user

      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award]),
      });
      // update user

      return right(_users.doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
