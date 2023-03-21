import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/fileProcessing/fileProcessor.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseCollectionManager.dart';
import 'package:cloud_portrait/data/firestore_storage/firestoreFileManager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';

class FileUploader {
  FileProcessor fileProcessor = FileProcessor();
  FirestoreManager firestoreManager = FirestoreManager();
  FireBaseCollectionManager fireBaseCollectionManager =
      FireBaseCollectionManager();

  uploadFiles(
      {required List<PlatformFile> files,
      required CollectionReference collectionReference}) async {
    for (var file in files) {
      if (lookupMimeType(file.path!).toString().contains('image')) {
        Map fileInfo = await fileProcessor.generateImageInfo(File(file.path!));
        var imgURL = await firestoreManager.uploadImageAndGetURL(
            imagePath: file.path!,
            firestorePath:
                '${collectionReference.path}/${fileInfo['fileName']}');

        await fireBaseCollectionManager.addFileToCollection(
            collectionReference: collectionReference,
            imageInfo: fileInfo,
            subtype: 'image',
            urls: imgURL);
      } else if (lookupMimeType(file.path!).toString().contains('video')) {
        Map fileInfo =
            await fileProcessor.generateLocalVideoInfo(File(file.path!));

        var videoURL = await firestoreManager.uploadVideoAndGetURL(
            imagePath: file.path!,
            firestorePath:
                '${collectionReference.path}/${fileInfo['fileName']}');

        var videoThumb = await firestoreManager.uploadImageAndGetURL(
            imagePath: fileInfo['thumbnail'].path!,
            firestorePath:
                '${collectionReference.path}/${fileInfo['fileName']}_thumb');

        await fireBaseCollectionManager.addFileToCollection(
            collectionReference: collectionReference,
            imageInfo: fileInfo,
            subtype: 'video',
            urls: videoURL,
            thumbnail: videoThumb);
      }
    }

    debugPrint(
        '----------------------------<<<>>>---------------------------- Upload Finished ----------------------------<<<>>>----------------------------');



    return true;
  }
}
