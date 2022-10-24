import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyGoogleSignIn {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      bool userExists =
          await checkIfUserExistsByID(FirebaseAuth.instance.currentUser?.uid);

      if (!userExists) {
        _users.doc(FirebaseAuth.instance.currentUser?.uid).set({
          'name': googleUser?.displayName,
          'email': googleUser?.email,
        });
      }

      return googleUser;
    } catch (error) {
      print(error);
      return null;
    }
  }

  checkIfUserExistsByID(String? userID) async {
    DocumentSnapshot user = await _users.doc(userID).get();
    return user.exists;
  }
}
