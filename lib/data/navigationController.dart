import 'package:cloud_firestore/cloud_firestore.dart';

class NavigationController {
  goToFolder({required DocumentReference documentReference}) {
    return documentReference.collection('files');
  }

  backOneLevel({required CollectionReference collectionReference}) {
    CollectionReference? newCollectionPath;
    String path = collectionReference.path;
    int subFolderLevel = '/'.allMatches(collectionReference.path).length;

    if (subFolderLevel <= 4) {
      int index = path.lastIndexOf('/');
      String newPath = path.substring(0, index);
      int newIndex = newPath.lastIndexOf('/');

      newCollectionPath =
          FirebaseFirestore.instance.collection(newPath.substring(0, newIndex));
      return newCollectionPath;
    }

    if (collectionReference.path.contains('filesaa')) {
      print(collectionReference.path);
      var i = collectionReference.path.lastIndexOf('/files');
      var a = collectionReference.path.replaceFirst('/files', '', i);
      print(a);
      var ii = a.lastIndexOf('/files');
      print(a.substring(0, ii));
    }
  }
}
