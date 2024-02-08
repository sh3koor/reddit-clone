import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Failure.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/Community.dart';

// After creating the Repositroy Now we need to provide this repository
final communityRepositoryProvider = Provider(
  (ref) {
    return CommunityRepository(
      // passing the firestore
      ref.watch(firestoreProvider),
    );
  },
);

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository(this._firestore);

  FutureVoid createCommunity(Community community) async {
    try {
      // Creating a community
      // Calling firestore should be from the repository

      // Now we need to check that there is no community with the same name before
      final communityDoc = await _communities.doc(community.name).get();

      if (communityDoc.exists) {
        // already exists community with the same name
        throw "Community with the same name exits";
      }
      // IF community with same name does not exits
      return right(_communities.doc(community.name).set(community.toMap()));
      // Now we need to go to the controller to handle the logic of calling createCommunity function
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    // all communities where the user is part of
    return _communities
        .where("members", arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      event.docs.forEach((doc) {
        // for each community in that snapshot
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      });
      // for every snapshot we have a list of communities returned
      return communities;
    });
  }

//  if you want your app to automatically update whenever the community with the given name changes, you should use a Stream. If you only need to fetch the community's data once and don't care about updates, you could use a Future instead.
  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
          (event) => Community.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  // uid:id of the user to join
  // community: the community to join
  FutureVoid joinCommunity(String uid, Community community) async {
    try {
      Community newCommunity =
          community.copyWith(members: [...community.members, uid]);

      return right(
          _communities.doc(community.name).update(newCommunity.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String uid, Community community) async {
    try {
      // user already a memeber, pressing this means unjoin
      Community newCommunity =
          community.copyWith(members: community.members.delete(uid).toList());

      return right(
          _communities.doc(community.name).update(newCommunity.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({"mods": uids}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
