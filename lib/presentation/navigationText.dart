import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseUserManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationText extends StatefulWidget {
  final CollectionReference collectionReference;
  final Function(DocumentReference) textTapped;

  const NavigationText(
      {super.key, required this.collectionReference, required this.textTapped});

  @override
  State<NavigationText> createState() => _NavigationTextState();
}

class _NavigationTextState extends State<NavigationText> {
  ScrollController scrollController = ScrollController();
  FirebaseUserManager firebaseUserManager = FirebaseUserManager();
  String displayName = '';
  String userID = '';
  List<List<String>> folders = [];

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
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: folders.length,
        itemBuilder: (BuildContext ctx, index) {
          return InkWell(
            onTap: () => _setFolderToNavigate(index),
            child: Container(
                margin: const EdgeInsets.only(left: 4, right: 4),
                child: Center(
                    child: Text(
                  folders[index][1],
                  style: const TextStyle(fontSize: 18),
                ))),
          );
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
    folders.insert(0, ['', displayName]);
    setState(() {});
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  getListItems() async {
    String path = widget.collectionReference.path;
    path = path.substring(path.indexOf('collections'));
    List foldersList = path.split('/');
    for (var element in foldersList) {
      if (element != 'files' && element != 'collections') {
        String path = widget.collectionReference.path.substring(5);

        DocumentReference doc = FirebaseFirestore.instance
            .collection('users')
            .doc('${path.substring(0, path.indexOf(element))}$element');

        DocumentSnapshot docData = await doc.get();
        Map data = docData.data() as Map;
        folders.add([element, data['displayName']]);
      }
    }
    setState(() {});
  }

  _setFolderToNavigate(int index) {
    String path = widget.collectionReference.path;

    if (index == 0) {
      path = '${path.substring(0, path.lastIndexOf('collections'))}collections';
    } else if (index == (folders.length - 1)) {
      debugPrint('last item, don\'t move!');
    } else {
      path =
          '${path.substring(0, path.lastIndexOf(folders[index][0]))}${folders[index][0]}';
    }
    widget.textTapped(
        FirebaseFirestore.instance.collection('users').doc(path.substring(5)));
  }
}
