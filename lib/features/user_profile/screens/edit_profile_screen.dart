import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/models/UserModel.dart';
import 'package:reddit_clone/responsive/responsive.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  Uint8List? webBannerFile;
  File? profileFile;
  Uint8List? webProfileFile;

  final TextEditingController userNameTextFieldController =
      TextEditingController();

  void editProfile(UserModel user) {
    ref.read(userProfileControllerProvider.notifier).editProfile(
          user: user,
          context: context,
          bannerFile: bannerFile,
          profileFile: profileFile,
          webBannerFile: webBannerFile,
          webProfileFile: webProfileFile,
        );
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() {
          webBannerFile = res.files.first.bytes;
        });
      }
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() {
          webProfileFile = res.files.first.bytes;
        });
      }
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userNameTextFieldController.text = ref.read(userProvider)!.name;
  }

  @override
  void dispose() {
    super.dispose();

    userNameTextFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => Scaffold(
            backgroundColor: currentTheme.backgroundColor,
            appBar: AppBar(
              title: Text("Edit Profile"),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () {
                    // to get the name changes
                    final newUser =
                        user.copyWith(name: userNameTextFieldController.text);
                    editProfile(newUser);
                  },
                  child: Text('Save'),
                )
              ],
            ),
            body: isLoading
                ? const Loader()
                : Responsive(
                  child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: selectBannerImage,
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color:
                                        currentTheme.textTheme.bodyMedium!.color!,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      height: 150,
                                      width: double.infinity,
                                      child: webBannerFile != null
                                          ? Image.memory(webBannerFile!)
                                          : bannerFile != null
                                              ? Image.file(bannerFile!)
                                              : user.banner.isEmpty ||
                                                      user.banner ==
                                                          Constants.bannerDefault
                                                  ? const Icon(
                                                      Icons.camera_alt_outlined,
                                                      size: 40,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: user.banner),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: selectProfileImage,
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundImage: webBannerFile != null
                                          ? Image.memory(webProfileFile!).image
                                          : profileFile != null
                                              ? Image.file(profileFile!).image
                                              : CachedNetworkImageProvider(
                                                  user.profilePic,
                                                ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        TextField(
                          controller: userNameTextFieldController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Name',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(18),
                          ),
                        ),
                      ],
                    ),
                ),
          ),
          error: (error, stackTrace) => ErrorText(
            errorText: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
