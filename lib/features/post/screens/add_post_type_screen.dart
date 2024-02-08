import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/Community.dart';
import 'package:reddit_clone/theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostTypeState();
}

class _AddPostTypeState extends ConsumerState<AddPostTypeScreen> {
  late TextEditingController titleController;
  late TextEditingController textContentController;
  late TextEditingController linkController;
  File? postImage;
  Uint8List? bannerWebFile;
  Community? selectedCommunity;

  @override
  void initState() {
    titleController = TextEditingController();
    textContentController = TextEditingController();
    linkController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    textContentController.dispose();
    linkController.dispose();
    super.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      // if web
      if (kIsWeb) {
        setState(() {
          bannerWebFile = res.files.first.bytes;
        });
      }
      setState(() {
        postImage = File(res.files.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);

    final currentTheme = ref.watch(themeProvider);
    final isTypeImage = widget.type == "image";
    final isTypeText = widget.type == "text";
    final isTypeLink = widget.type == "link";
    return Scaffold(
        appBar: AppBar(
          title: Text("Post ${widget.type}"),
          actions: [
            TextButton(
                onPressed: () {
                  // which post to share

                  // text
                  if (isTypeText && titleController.text.isNotEmpty) {
                    ref.read(postControllerProvider.notifier).shareTextPost(
                        context: context,
                        title: titleController.text.trim(),
                        selectedCommunity: selectedCommunity!,
                        textContent: textContentController.text.trim());
                  }
                  // link
                  else if (isTypeLink &&
                      titleController.text.isNotEmpty &&
                      linkController.text.isNotEmpty) {
                    ref.read(postControllerProvider.notifier).shareLinkPost(
                        context: context,
                        title: titleController.text.trim(),
                        selectedCommunity: selectedCommunity!,
                        link: linkController.text.trim());
                  }
                  // image
                  else if (isTypeImage &&
                      titleController.text.isNotEmpty &&
                      (postImage != null || bannerWebFile != null)) {
                    ref.read(postControllerProvider.notifier).shareImagePost(
                        context: context,
                        title: titleController.text.trim(),
                        selectedCommunity: selectedCommunity!,
                        imageFile: postImage,
                        webFile: bannerWebFile);
                  } else {
                    showSnackBar(context, "Please Enter the fields correctly");
                  }
                },
                child: Text("Share"))
          ],
        ),
        body: isLoading
            ? const Loader()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      maxLength: 30,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: "Enter Title here",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Now check for each type to display in the screen
                    if (isTypeImage)
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
                              // if web
                              child: bannerWebFile != null
                                  ? Image.memory(bannerWebFile!)
                                  : postImage != null
                                      ? Image.file(postImage!)
                                      : const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        )),
                        ),
                      ),

                    // if text
                    if (isTypeText)
                      TextField(
                        controller: textContentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: "Enter Text Content Here",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                      ),
                    // if link
                    if (isTypeLink)
                      TextField(
                        controller: linkController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: "Enter The Link Here",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                      ),
                    // To Select The community that you are part of
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("Select Community"),
                    ),
                    // the stream should be watch
                    ref.watch(userCommunitiesProvider).when(
                          data: (communities) {
                            if (communities.isEmpty) {
                              return const SizedBox();
                            }
                            selectedCommunity ??= communities[0];
                            return DropdownButton(
                              value: selectedCommunity,
                              items: communities
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCommunity = value!;
                                });
                              },
                            );
                          },
                          error: (error, stackTrace) => ErrorText(
                            errorText: error.toString(),
                          ),
                          loading: () => const Loader(),
                        )
                  ],
                ),
              ));
  }
}
