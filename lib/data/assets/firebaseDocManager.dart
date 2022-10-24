import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireBaseDocManager {
  final CollectionReference appUserCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('collections');

  createDoc({required String collectionName}) async {
    Map<String, dynamic> updated = {'updated': DateTime.now()};
    Map<String, dynamic> data = {'created': DateTime.now(), 'type': 'folder'};

    await appUserCollection.doc(collectionName).set(updated);
    await appUserCollection.doc(collectionName).set(data);
    return true;
  }

  getDocs({required CollectionReference collection}) async {
    QuerySnapshot result = await appUserCollection.get();

    print(result.docs.length);
    result.docs.forEach((element) {
      print(element.data());
      print(element.id);
    });
    return result;
  }
}
