import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserManager {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  getUserDisplayName(String userID) async {
    DocumentSnapshot userDoc = await _users.doc(userID).get();

    Map? userData = userDoc.data() as Map?;

    return userData!['displayName'];
  }
}
