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
  createCollection(
      {required CollectionReference collectionReference,
      required String newCollectionName}) async {
    Map<String, dynamic> updated = {'updated': DateTime.now()};
    Map<String, dynamic> data = {'created': DateTime.now(), 'type': 'folder'};

    await collectionReference.doc(newCollectionName).set(updated);
    await collectionReference.doc(newCollectionName).set(data);
    return true;
  }

  addFileToCollection() {}

  addFolderToCollection(
      {required DocumentReference documentReference,
      required String newFolderName}) async {
    Map<String, dynamic> updated = {'updated': DateTime.now()};
    Map<String, dynamic> data = {'created': DateTime.now(), 'type': 'folder'};

    await documentReference.collection('files').doc(newFolderName).set(updated);
    await documentReference.collection('files').doc(newFolderName).set(data);
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
