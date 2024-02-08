import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/providers/storage_repository.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/Community.dart';
import 'package:routemaster/routemaster.dart';

// create a StreamProvider for the user communities
final userCommunitiesProvider = StreamProvider(
  // call getUserCommunites in the communityControllerProvider
  // This is just for not repating the code
  (ref) {
    final communityController = ref.watch(communityControllerProvider.notifier);
    return communityController.getUserCommunities();
  },
);

final getCommunityByNameProvider = StreamProvider.family(
  (ref, String name) {
    return ref
        .watch(communityControllerProvider.notifier)
        .getCommunityByName(name);
  },
);

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

// Now that we created the controller we need to provide it

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>(
  (ref) {
    return CommunityController(
      communityRepository: ref.watch(communityRepositoryProvider),
      ref: ref,
      storageRepository: ref.watch(storageRepositoryProvider),
    );
  },
);

// we are extending the StateNotifier just to know when it is loading and when it is not
class CommunityController extends StateNotifier<bool> {
  CommunityRepository _communityRepository;
  StorageRepository _storageRepository;
  // this ref is need to access the user provider

  Ref _ref;
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,

        // initialy the state is false, again the state is only for the purpose of loading or not
        super(false);

  // We need the context for the snackBar of errors

  void createCommunity(String name, BuildContext context) async {
    // loading
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? "";
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      // the user who creates the community is also a member of that community
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(community);

    // not loading
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, "Community Created Successfully");
        // to go back to the drawer screen
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;

    return _ref.read(communityRepositoryProvider).getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required Community community,
    required BuildContext context,
    required File? profileFile,
    required File? bannerFile,
    Uint8List? webProfileFile,
    Uint8List? webBannerFile,
  }) async {
    // loading
    state = true;

    if (profileFile != null || webProfileFile != null) {
      final res = await _storageRepository.storeFile(
        path: "cummunities/profile",
        id: community.name,
        file: profileFile,
        webFile: webProfileFile,
      );

      res.fold(
        (l) {
          showSnackBar(context, l.message);
        },
        (r) => community = community.copyWith(avatar: r),
      );
    }
    if (bannerFile != null || webBannerFile != null) {
      final res = await _storageRepository.storeFile(
          path: "cummunities/banner",
          id: community.name,
          file: bannerFile,
          webFile: webBannerFile);

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    // the updated community is passed
    final res = await _communityRepository.editCommunity(community);
    state = false;

    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        showSnackBar(context, "Saved Successfully");
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void joinCommunity(
    Community community,
    BuildContext context,
  ) async {
    final uid = _ref.watch(userProvider)!.uid;
    final res = await _communityRepository.joinCommunity(uid, community);
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, "Joined Successfully");
    });
  }

  void leaveCommunity(
    Community community,
    BuildContext context,
  ) async {
    final uid = _ref.watch(userProvider)!.uid;

    final res = await _communityRepository.leaveCommunity(uid, community);
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, "Unjoined Successfully");
    });
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold((l) => ErrorText(errorText: l.message), (r) {
      showSnackBar(context, "Moderators updated successfully");
      Routemaster.of(context).pop();
    });
  }
}
