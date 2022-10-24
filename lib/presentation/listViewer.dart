import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListViewer extends StatefulWidget {
  const ListViewer({super.key});

  @override
  State<StatefulWidget> createState() => _ListViewerState();
}

class _ListViewerState extends State<ListViewer> {
  late double screenWidth;
  bool grid = true;

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
          _dataViewer(),
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
          SizedBox(
              width: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [Icon(Icons.list)],
              )),
        ],
      ),
    );
  }

  _dataViewer() {
    bool grid = true;

    listViewer() {
      return Container();
    }

    return grid ? gridViewer() : listViewer();
  }

  gridViewer() {
    return Expanded(
        child: GridView.builder(
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20),
            itemBuilder: (BuildContext ctx, index) {
              return Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 120,
                      child: Image.network(
                          'https://i.pinimg.com/736x/76/03/5c/76035cea6383259ae8136fc2f24c339f.jpg'),
                    ),
                    const Expanded(
                      child: Text(
                        'Folder/File Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}
