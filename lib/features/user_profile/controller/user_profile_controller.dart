import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/core/providers/storage_repository.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/user_profile/repository/user_profile.dart';
import 'package:reddit_clone/models/UserModel.dart';
import 'package:routemaster/routemaster.dart';

// providing
final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>(
  (ref) {
    return UserProfileController(
      ref: ref,
      userProfileRepository: ref.watch(userProfileRepositoryProvider),
      storageRepository: ref.watch(storageRepositoryProvider),
    );
  },
);

// the class

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  UserProfileController(
      {required UserProfileRepository userProfileRepository,
      required StorageRepository storageRepository,
      required Ref ref})
      : _userProfileRepository = userProfileRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void editProfile({
    required UserModel user,
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
          path: "users/profile",
          id: user.uid,
          file: profileFile,
          webFile: webProfileFile);

      res.fold(
        (l) {
          showSnackBar(context, l.message);
        },
        (r) => user = user.copyWith(profilePic: r),
      );
    }
    if (bannerFile != null || webBannerFile != null) {
      final res = await _storageRepository.storeFile(
          path: "users/banner",
          id: user.uid,
          file: bannerFile,
          webFile: webBannerFile);

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }

    // the updated community is passed
    final res = await _userProfileRepository.editProfile(user);
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

  void updateUserKarma(UserKarma userKarma) async {
    final user = _ref.read(userProvider)!;
    final newUser = user.copyWith(karma: user.karma + userKarma.karma);
    final res = await _userProfileRepository.updateUserKarma(newUser);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => newUser));
  }
}
