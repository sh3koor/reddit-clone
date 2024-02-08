import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_defs.dart';

// now we provide the StorageRepository

final storageRepositoryProvider = Provider((ref) {
  return StorageRepository(firebaseStorage: ref.watch(storageProvider));
});

class StorageRepository {
  final FirebaseStorage _firebaseStorage;
  StorageRepository({required firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  // path: users/banner
  // id: meme
  // total path: users/banner/meme
  FutureEither<String> storeFile(
      {required String path,
      required String id,
      File? file,
      Uint8List? webFile}) async {
    try {
      UploadTask uploadTask;
      // ref() is the root
      final ref = _firebaseStorage.ref().child(path).child(id);
      if (kIsWeb) {
        uploadTask = ref.putData(webFile!);
      } else {
        // saving the data in firebase storage
        uploadTask = ref.putFile(file!);
      }
      // to get the url of the saved data
      final taskSnapshot = await uploadTask;
      return right(await taskSnapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
