import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/carousel_slider.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseCollectionManager.dart';
import 'package:cloud_portrait/data/listSorter.dart';
import 'package:cloud_portrait/presentation/navigationText.dart';
import 'package:flutter/material.dart';

class ListViewer extends StatefulWidget {
  final CollectionReference firebasePath;
  final Function(Map) talkback;
  final Function(List<ListItem>) openList;

  const ListViewer(
      {super.key,
      required this.firebasePath,
      required this.talkback,
      required this.openList});

  @override
  State<StatefulWidget> createState() => _ListViewerState();
}

class _ListViewerState extends State<ListViewer> {
  ListSorter listSorter = ListSorter();
  FireBaseCollectionManager docManager = FireBaseCollectionManager();
  late double screenWidth;
  bool grid = true;
  bool sortType = false; //True = nome False = Data new>old
  bool sortByType = false;
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
          grid ? _gridViewer() : _listViewer(),
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
                  widget.talkback({'folder': folderPath});
                }
              }),
        ),
        underLine(),
      ],
    );
  }

  _sortAndViewMode() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 1),
                    child: Row(
                      children: [
                        const Text('Organizado por: '),
                        InkWell(
                            onTap: () {
                              sortType = !sortType;
                              _listSort();
                            },
                            child: SizedBox(
                              width: 110,
                              child: Text(
                                sortType ? 'Nome' : 'Data',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 1),
                    child: Row(
                      children: [
                        const Text('Separado por: '),
                        InkWell(
                            onTap: () {
                              sortByType = !sortByType;
                              _listSort();
                            },
                            child: SizedBox(
                              width: 120,
                              child: Text(
                                sortByType ? 'Tipo' : 'Sem separação',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _changeViewMode(),
          ],
        ),
        Container(
          height: 1,
          width: screenWidth,
          color: Colors.grey,
        )
      ],
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
                  ? const Icon(
                      Icons.list,
                      size: 30,
                    )
                  : const Icon(
                      Icons.grid_view_rounded,
                      size: 30,
                    ),
            ],
          )),
    );
  }

  _gridViewer() {
    return Expanded(
        child: GridView.builder(
            itemCount: listItems.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
            ),
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                onTap: () => _listTap(index),
                onLongPress: () => _listLongPress(index),
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

  _listViewer() {
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
        height: 110,
        child: Image.network(
          'https://i.pinimg.com/736x/76/03/5c/76035cea6383259ae8136fc2f24c339f.jpg',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      );
    } else if (listItems[index].subtype == 'image') {
      return SizedBox(
        height: 110,
        width: 500,
        child: Image.network(
          listItems[index].linkURL!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      );
    } else {
      return SizedBox(
        height: 110,
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
        if (data['specialIMG']) {
          listItems.add(ListItem(
            type: 'file',
            created: data['created'],
            modified: data['modified'],
            subtype: data['subtype'],
            fileLocation: data['firestorePath'],
            linkURL: data['fileURL'],
            name: data['displayName'],
            docPath: element.reference,
            specialIMG: data['specialIMG'],
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
          ));
        }
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

    _listSort();
  }

  _listTap(int index) {
    if (listItems[index].type == 'folder') {
      widget.talkback({'folder': listItems[index].docPath});
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => PortraitCarousel(
                    firebasePath: widget.firebasePath,
                    playlist: listItems,
                  )));
    }
  }

  _listLongPress(int index) async {
    /*late bool deleted;
    if (listItems[index].type == 'folder') {
      deleted = await docManager.deleteFolder(
          documentReference: listItems[index].docPath);
    } else {
      deleted = await docManager.deleteFile(
          documentReference: listItems[index].docPath,
          filePath: listItems[index].fileLocation);
    }
    if (deleted) {
      listItems.removeAt(index);
      setState(() {});
    }*/
  }

  _listSort() {
    //True = nome False = Data new>old
    if (sortType) {
      listItems = listSorter.sortAlphabetically(
          list: listItems, separatedByType: sortByType);
    } else {
      listItems = listSorter.sortByCreatedDate(
          list: listItems, separatedByType: sortByType);
    }
    widget.openList(listItems);
    _setStater();
  }

  _setStater() {
    if (mounted) {
      setState(() {});
    }
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
  final bool specialIMG;

  ListItem(
      {required this.name,
      required this.type,
      required this.modified,
      required this.created,
      this.taken,
      this.linkURL,
      this.thumbnailURL,
      this.subtype,
      this.docPath,
      this.fileLocation,
      this.specialIMG = false});
}
