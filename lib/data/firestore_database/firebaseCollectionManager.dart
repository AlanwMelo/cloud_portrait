import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/firestore_storage/firestoreFileManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FireBaseCollectionManager {
  FirestoreManager firestoreManager = FirestoreManager();

  getUserCollection() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('collections');
  }

  /// Usa a referencia do firebase para criar uma nova pasta
  /// Ex: final CollectionReference appUserCollection = FirebaseFirestore.instance
  ///       .collection('users')
  ///       .doc(FirebaseAuth.instance.currentUser?.uid)
  ///       .collection('collections');
  addFileToCollection(
      {required CollectionReference collectionReference,
      required Map imageInfo,
      required var urls,
      required String subtype,
      var thumbnail}) {
    DocumentReference doc = collectionReference.doc();

    Map<String, dynamic> data = {
      "type": "file",
      "displayName": imageInfo['fileName'],
      "orientation": imageInfo['orientation'],
      "created": imageInfo['dateTime'],
      "modified": DateTime.now(),
      "taken": imageInfo['dateTime'],
      "subtype": subtype,
      "specialIMG": imageInfo['specialIMG'],
      "docPath": doc.path,
      "firestorePath": urls[1],
      "fileURL": urls[0],
    };

    if (thumbnail != null) {
      data.addAll({"thumbnail": thumbnail});
    }

    doc.set(data);
  }

  createCollection(
      {required CollectionReference collectionReference,
      required String newFolderName}) async {
    DocumentReference doc = collectionReference.doc();
    Map<String, dynamic> updated = {'updated': DateTime.now()};
    Map<String, dynamic> data = {
      'created': DateTime.now(),
      'type': 'folder',
      'displayName': newFolderName
    };

    debugPrint('Creating collection ${collectionReference.doc(doc.id)}');

    await collectionReference.doc(doc.id).set(updated);
    await collectionReference.doc(doc.id).set(data);
    return true;
  }

  getDocs({required CollectionReference? collection}) async {
    QuerySnapshot? result = await collection?.get();

    return result;
  }

  deleteFile(
      {required DocumentReference? documentReference,
      required String? filePath}) {
    try {
      firestoreManager.deleteFile(path: filePath);
      documentReference?.delete();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  deleteFolder({
    required DocumentReference? documentReference,
  }) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference docFiles = documentReference!.collection('files');
    try {
      WriteBatch batch = db.batch();
      firestoreManager.deleteFolder(documentReference.path);
      documentReference.delete();
      QuerySnapshot files = await docFiles.get();
      for (var doc in files.docs) {
        batch.delete(doc.reference);
      }
      batch.commit();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
