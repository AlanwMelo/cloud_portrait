import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseUserManager.dart';
import 'package:flutter/cupertino.dart';

class NavigationText extends StatefulWidget {
  final CollectionReference collectionReference;
  final Function(String) textTapped;

  const NavigationText(
      {super.key, required this.collectionReference, required this.textTapped});

  @override
  State<NavigationText> createState() => _NavigationTextState();
}

class _NavigationTextState extends State<NavigationText> {
  FirebaseUserManager firebaseUserManager = FirebaseUserManager();
  String displayName = '';
  String userID = '';
  List<String> folders = [];

  @override
  void initState() {
    getUserID(widget.collectionReference);
    getListItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: folders.length,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
              margin: const EdgeInsets.only(left: 4, right: 4),
              child: Center(
                  child: Text(
                folders[index],
                style: const TextStyle(fontSize: 18),
              )));
        },
        separatorBuilder: (BuildContext context, int index) => const Center(
          child: Text(
            '>',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  getUserID(CollectionReference collectionReference) async {
    String path = collectionReference.path;
    userID = path.replaceFirst('users/', '');
    userID = userID.substring(0, userID.indexOf('/'));

    displayName = await firebaseUserManager.getUserDisplayName(userID);
    folders.insert(0, displayName);
    setState(() {});
  }

  getListItems() {
    String path = widget.collectionReference.path;
    print(path);
    path = path.substring(path.indexOf('collections'));
    List foldersList = path.split('/');
    for (var element in foldersList) {
      if (element != 'files' && element != 'collections') {
        folders.add(element);
      }
    }
    setState(() {});
  }
}
