import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/fileProcessing/fileProcessor.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseCollectionManager.dart';
import 'package:cloud_portrait/data/firestore_storage/firestoreFileManager.dart';
import 'package:file_picker/file_picker.dart';
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
        Map fileInfo =
            await fileProcessor.generateLocalImageInfo(File(file.path!));
        var imgURL = await firestoreManager.uploadImageAndGetURL(
            imagePath: file.path!, firestorePath: '${collectionReference.path}/${fileInfo['fileName']}');

        await fireBaseCollectionManager.addFileToCollection(
            collectionReference: collectionReference,
            imageInfo: fileInfo,
            subtype: 'image',
            urls: imgURL);


      } else if (lookupMimeType(file.path!).toString().contains('video')) {}
    }

    return true;
  }
}
