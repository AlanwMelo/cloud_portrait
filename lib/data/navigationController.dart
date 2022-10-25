import 'package:cloud_firestore/cloud_firestore.dart';

class NavigationController {
  goToFolder({required DocumentReference documentReference}) {
    return documentReference.collection('files');
  }

  /// Se estiver nas pastas de nivel mais alto volta para a raiz
  /// Se estiver em subpastas sobe um nivel
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
    } else {
      int index = collectionReference.path.lastIndexOf('/files');
      String newPath =
          collectionReference.path.replaceFirst('/files', '', index);
      int newIndex = newPath.lastIndexOf('/files');

      newCollectionPath = FirebaseFirestore.instance
          .collection('${newPath.substring(0, newIndex)}/files');
    }
    return newCollectionPath;
  }
}
