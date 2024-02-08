import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/Community.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> modsUids = {};
  int buildCounter = 0;

  void addModUid(String uid) {
    setState(() {
      modsUids.add(uid);
    });
  }

  void removeModUid(String uid) {
    setState(() {
      modsUids.remove(uid);
    });
  }

  void saveMods(
      String communityName, BuildContext context, List<String> modsUids) {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(communityName, modsUids, context);
  }

  @override
  Widget build(BuildContext context) {
    // uids of the current mods of the community
    // it is a set because we don't want repeating values

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  saveMods(widget.name, context, modsUids.toList());
                },
                icon: Icon(Icons.done)),
          ],
        ),
        body: ref.watch(getCommunityByNameProvider(widget.name)).when(
              data: (community) {
                return ListView.builder(
                  itemCount: community.members.length,
                  itemBuilder: (context, index) {
                    final uid = community.members[index];
                    // to get the data of each user
                    return ref.watch(getUserDataProvider(uid)).when(
                          data: (user) {
                            if (buildCounter == 0) {
                              // just do the first time
                              modsUids = Set<String>.from(community.mods);
                            }
                            buildCounter++;
                            return CheckboxListTile(
                              title: Text(user.name),
                              onChanged: (value) {
                                if (value == true) {
                                  addModUid(user.uid);
                                } else {
                                  removeModUid(user.uid);
                                }
                              },
                              value: modsUids.contains(user.uid),
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(errorText: error.toString()),
                          loading: () => const Loader(),
                        );
                  },
                );
              },
              error: (error, stackTrace) =>
                  ErrorText(errorText: error.toString()),
              loading: () => const Loader(),
            ));
  }
}
