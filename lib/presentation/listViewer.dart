import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/firebaseCollectionManager.dart';
import 'package:flutter/cupertino.dart';
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
    text(String text) {
      return Text(text);
    }

    underLine() {
      return Container(
        height: 1,
        color: Colors.grey,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: screenWidth,
          padding: const EdgeInsets.all(8),
          child: text('Path>path>Path'),
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
                crossAxisSpacing: 20,
                mainAxisSpacing: 20),
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                onTap: () {
                  widget.talkback({'folder': listItems[index].docPath});
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _listItemImage(),
                      _listItemName(listItems[index].name!),
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
              return Row(
                children: [
                  SizedBox(height: 50, width: 50, child: _listItemImage()),
                  Container(
                    margin: const EdgeInsets.only(
                        top: 2, bottom: 2, right: 8, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.red.withOpacity(0),
                          child: _listItemName(listItems[index].name!),
                        ),
                        Container(
                          color: Colors.red.withOpacity(0),
                          child: _listItemModifiedDate(),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }));
  }

  _listItemImage() {
    return SizedBox(
      height: 120,
      child: Image.network(
          'https://i.pinimg.com/736x/76/03/5c/76035cea6383259ae8136fc2f24c339f.jpg'),
    );
  }

  _listItemName(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  _listItemModifiedDate() {
    return const Text(
      'Modified Date',
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
    );
  }

  /// Data Processing \/
  _loadDocs() async {
    QuerySnapshot result =
        await docManager.getDocs(collection: widget.firebasePath);

    result.docs.forEach((element) {
      listItems.add(ListItem(
          type: 'folder',
          modified: '',
          taken: 'taken',
          name: element.id,
          docPath: element.reference));
      setState(() {});
    });
  }
}

class ListItem {
  final String type;
  final String? name;
  final String modified;
  final String taken;
  final DocumentReference? docPath;

  ListItem(
      {required this.type,
      this.name,
      this.docPath,
      required this.modified,
      required this.taken});
}
