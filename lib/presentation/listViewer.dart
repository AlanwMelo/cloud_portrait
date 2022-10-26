import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseCollectionManager.dart';
import 'package:cloud_portrait/data/listSorter.dart';
import 'package:cloud_portrait/presentation/navigationText.dart';
import 'package:flutter/material.dart';

class ListViewer extends StatefulWidget {
  final CollectionReference firebasePath;
  final Function(Map) talkback;

  const ListViewer(
      {super.key, required this.firebasePath, required this.talkback});

  @override
  State<StatefulWidget> createState() => _ListViewerState();
}

class _ListViewerState extends State<ListViewer> {
  ListSorter listSorter = ListSorter();
  FireBaseCollectionManager docManager = FireBaseCollectionManager();
  late double screenWidth;
  bool grid = true;
  List<ListItem> listItems = [];

  @override
  void initState() {
    _loadDocs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _path(),
          _sortAndViewMode(),
          grid ? gridViewer() : listViewer(),
        ],
      ),
    );
  }

  _path() {
    underLine() {
      return Container(
        height: 1,
        color: Colors.grey,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: screenWidth,
          child: NavigationText(
              collectionReference: widget.firebasePath,
              textTapped: (folderPath) {
                if ('/'.allMatches(folderPath.path).length == 2) {
                  widget.talkback({'root': folderPath});
                } else {
                  print(folderPath);
                  widget.talkback({'folder': folderPath});
                }
              }),
        ),
        underLine(),
      ],
    );
  }

  _sortAndViewMode() {
    return Container(
      margin: const EdgeInsets.all(8),
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 150, child: Text('Organizar por:')),
          _changeViewMode(),
        ],
      ),
    );
  }

  _changeViewMode() {
    return InkWell(
      onTap: () {
        grid = !grid;
        setState(() {});
      },
      child: SizedBox(
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              grid
                  ? const Icon(Icons.list)
                  : const Icon(Icons.grid_view_rounded),
            ],
          )),
    );
  }

  gridViewer() {
    return Expanded(
        child: GridView.builder(
            itemCount: listItems.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
            ),
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                onTap: () {
                  _listTap(index);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _listItemImage(index),
                      _listItemName(listItems[index].name),
                    ],
                  ),
                ),
              );
            }));
  }

  listViewer() {
    return Expanded(
        child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
            itemCount: listItems.length,
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                onTap: () => _listTap(index),
                child: Row(
                  children: [
                    SizedBox(
                        height: 50, width: 50, child: _listItemImage(index)),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 2, bottom: 2, right: 8, left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.red.withOpacity(0),
                            child: _listItemName(listItems[index].name),
                          ),
                          Container(
                            color: Colors.red.withOpacity(0),
                            child: _listItemCreatedDate(index),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  _listItemImage(int index) {
    if (listItems[index].type == 'folder') {
      return SizedBox(
        height: 120,
        child: Image.network(
          'https://i.pinimg.com/736x/76/03/5c/76035cea6383259ae8136fc2f24c339f.jpg',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      );
    } else if (listItems[index].subtype == 'image') {
      return SizedBox(
        height: 120,
        width: 500,
        child: Image.network(
          listItems[index].linkURL!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      );
    } else {
      return SizedBox(
        height: 120,
        width: 500,
        child: Image.network(
          listItems[index].thumbnailURL!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      );
    }
  }

  _listItemName(String name) {
    return Text(
      name,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  _listItemCreatedDate(int index) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
        listItems[index].created.millisecondsSinceEpoch);

    return Text(
      '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}',
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
    );
  }

  /// Data Processing \/
  _loadDocs() async {
    QuerySnapshot result =
        await docManager.getDocs(collection: widget.firebasePath);

    for (var element in result.docs) {
      Map data = element.data() as Map;

      if (data['type'] == 'folder') {
        listItems.add(ListItem(
            type: 'folder',
            modified: Timestamp.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch),
            name: data['displayName'],
            docPath: element.reference,
            created: data['created']));
      } else if (data['subtype'] == 'image') {
        listItems.add(ListItem(
          type: 'file',
          created: data['created'],
          modified: data['modified'],
          subtype: data['subtype'],
          fileLocation: data['firestorePath'],
          linkURL: data['fileURL'],
          name: data['displayName'],
          docPath: element.reference,
        ));
      } else {
        listItems.add(ListItem(
            type: 'file',
            created: data['created'],
            modified: data['modified'],
            subtype: data['subtype'],
            fileLocation: data['firestorePath'],
            linkURL: data['fileURL'],
            name: data['displayName'],
            docPath: element.reference,
            thumbnailURL: data['thumbnail'][0]));
      }
    }

    listItems = await listSorter.sortByCreatedDate(list: listItems);
    setState(() {});
  }

  _listTap(int index) {
    widget.talkback({'folder': listItems[index].docPath});
  }
}

class ListItem {
  final String name;
  final String type;
  final Timestamp modified;
  final Timestamp created;
  final Timestamp? taken;
  final String? subtype;
  final String? linkURL;
  final String? thumbnailURL;
  final DocumentReference? docPath;
  final String? fileLocation;

  ListItem({
    required this.name,
    required this.type,
    required this.modified,
    required this.created,
    this.taken,
    this.linkURL,
    this.thumbnailURL,
    this.subtype,
    this.docPath,
    this.fileLocation,
  });
}
