import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class FirestoreManager {
  final Reference _storageRef = FirebaseStorage.instance.ref();

  uploadImageAndGetURL(
      {required String imagePath, required String firestorePath}) async {
    List<String> result = [];
    // firestorePath example: 'users/cdwnImtdHuOHfgKbNfTwkZPxTo52/collections/PvSFNRwgTa6a1iwkTL2q/files'

    final imageRef = _storageRef.child(firestorePath);
    try {
      await imageRef.putFile(File(imagePath));
      result = [await imageRef.getDownloadURL(), imageRef.fullPath];
      return result;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  uploadVideoAndGetURL(
      {required String imagePath, required String firestorePath}) async {
    List<String> result = [];
    // firestorePath example: 'users/cdwnImtdHuOHfgKbNfTwkZPxTo52/collections/PvSFNRwgTa6a1iwkTL2q/files'

    final imageRef = _storageRef.child(firestorePath);
    try {
      await imageRef.putFile(
          File(imagePath), SettableMetadata(contentType: 'video/mp4'));
      result = [await imageRef.getDownloadURL(), imageRef.fullPath];
      debugPrint('Upload concluido');
      return result;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  deleteFolder(String path) async {
    final folderRef = _storageRef.child(path);
    try {
      ListResult postItems = await folderRef.list();
      postItems.items.forEach((item) {
        item.delete();
      });
    } catch (e) {
      print(e);
    }
  }

  deleteFile({required String? path}) {
    _storageRef.child(path!).delete();
  }

/*deleteFiles({required List<AddPhotosListItem> images, String? post}) {
    images.forEach((image) {
      late String path;

      if (image.fromFirebase) {
        path = 'posts/$post/${image.name}.jpg';
      } else {
        path = image.firebasePath!.replaceAll('/images', '');
        path = '$path.jpg';
      }
      try {
        _storageRef.child(path).delete();
      } catch (e) {
        print('Error on delete (firestore): $e');
      }
    });
  }*/
}
