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
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/Community.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? prfileFile;
  Uint8List? webProfileFile;
  Uint8List? webBannerFile;
  void editCommunity(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        community: community,
        context: context,
        bannerFile: bannerFile,
        profileFile: prfileFile,
        webBannerFile: webBannerFile,
        webProfileFile: webProfileFile);
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (kIsWeb) {
      setState(() {
        webBannerFile = res!.files.first.bytes;
      });
    }
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (kIsWeb) {
      setState(() {
        webProfileFile = res!.files.first.bytes;
      });
    }
    if (res != null) {
      setState(() {
        prfileFile = File(res.files.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeProvider);

    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) => Scaffold(
            backgroundColor: currentTheme.backgroundColor,
            appBar: AppBar(
              title: Text("Edit Commmunity"),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () {
                    editCommunity(community);
                  },
                  child: Text('Save'),
                )
              ],
            ),
            body: isLoading
                ? const Loader()
                : Padding(
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
                              color: currentTheme.textTheme.bodyMedium!.color!,
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
                                        : community.banner.isEmpty ||
                                                community.banner ==
                                                    Constants.bannerDefault
                                            ? const Icon(
                                                Icons.camera_alt_outlined,
                                                size: 40,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: community.banner),
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
                                backgroundImage: webProfileFile != null
                                    ? Image.memory(webProfileFile!).image
                                    : prfileFile != null
                                        ? Image.file(prfileFile!).image
                                        : CachedNetworkImageProvider(
                                            community.avatar,
                                          ),
                              ),
                            ),
                          )
                        ],
                      ),
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
