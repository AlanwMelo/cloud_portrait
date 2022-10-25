import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireBaseCollectionManager {
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
  addFileToCollection() {}

  createCollection(
      {required CollectionReference collectionReference,
      required String newFolderName}) async {
    Map<String, dynamic> updated = {'updated': DateTime.now()};
    Map<String, dynamic> data = {'created': DateTime.now(), 'type': 'folder'};

    print('Creating collection ${collectionReference.doc(newFolderName)}');

    await collectionReference.doc(newFolderName).set(updated);
    await collectionReference.doc(newFolderName).set(data);
    return true;
  }

  getDocs({required CollectionReference collection}) async {
    QuerySnapshot result = await collection.get();

    /*print(result.docs.length);
    result.docs.forEach((element) {
      print(element.data());
      print(element.id);
    });*/
    return result;
  }
}
