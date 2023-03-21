import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/carousel/imageItem.dart';
import 'package:cloud_portrait/data/carousel/videoItem.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseCollectionManager.dart';
import 'package:cloud_portrait/presentation/listViewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

// ignore: must_be_immutable
class PortraitCarousel extends StatefulWidget {
  final CollectionReference firebasePath;
  List<ListItem>? playlist;

  PortraitCarousel({super.key, this.playlist, required this.firebasePath});

  @override
  State<StatefulWidget> createState() => _PortraitCarouselState();
}

class _PortraitCarouselState extends State<PortraitCarousel> {
  FireBaseCollectionManager docManager = FireBaseCollectionManager();
  CarouselController controller = CarouselController();
  int currentIndex = 0;
  List<ListItem> playListItems = [];
  List<ListItem> foldersList = [];
  int folderIndex = 0;
  int jumpToPage = 0;

  @override
  void initState() {
    _reloadFolders();
    //_loadFoldersList(widget.playlist!);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Wakelock.enable();

    for (var item in widget.playlist!) {
      if (item.type != 'folder') {
        playListItems.add(item);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
              onPageChanged: (index, reason) => currentIndex = index,
              height: MediaQuery.of(context).size.height,
              enableInfiniteScroll: false,
              viewportFraction: 1),
          items: playListItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                ValueNotifier<bool> isVisible = ValueNotifier(false);

                visible() async {
                  bool result = false;

                  isVisible.addListener(() {
                    result = isVisible.value;
                  });

                  while (!result) {
                    await Future.delayed(const Duration(milliseconds: 500));
                  }
                  return result;
                }

                return VisibilityDetector(
                  key: UniqueKey(),
                  // Os arquivos só são carregados do firebase quando o item está completamente visivel
                  child: FutureBuilder(
                    future: visible(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        return _carouselChild(item);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 100) {
                      isVisible.value = true;
                      debugPrint(
                          'Widget ${visibilityInfo.key} is $visiblePercentage% visible');
                    }
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  _carouselChild(ListItem item) {
    if (item.subtype == 'image') {
      return ImageItem(
        item: item,
        canChange: (result) {
          _nextFile(result);
        },
      );
    } else {
      return VideoItem(
          item: item,
          canChange: (result) {
            _nextFile(result);
          });
    }
  }

  _nextFile(bool result) async {
    if (result) {
      // Se for o ultimo item da lista
      if (currentIndex == (playListItems.length - 1)) {
        // Se for a ultima pasta
        if (folderIndex == (foldersList.length - 1)) {
          jumpToPage = 0;
          folderIndex = 0;
          await _reloadFolders();
        } else {
          folderIndex = folderIndex + 1;
          jumpToPage = 0;
        }
        playListItems.clear();
        _loadCarrouselFromFolder(folderIndex);
      } else {
        controller.nextPage();
      }
    }
  }

  _loadFoldersList(List<ListItem> list) async {
    for (var item in list) {
      foldersList.add(item);
    }
    _loadCarrouselFromFolder(folderIndex);
    return true;
  }

  _loadCarrouselFromFolder(int currentIndex) async {
    FireBaseCollectionManager collectionManager = FireBaseCollectionManager();
    QuerySnapshot result = await collectionManager.getDocs(
        collection: foldersList[currentIndex].docPath?.collection('files'));

    for (var element in result.docs) {
      Map data = element.data() as Map;

      if (data['type'] == 'folder') {
      } else if (data['subtype'] == 'image') {
        if (data['specialIMG']) {
          playListItems.add(ListItem(
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
          playListItems.add(ListItem(
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
        playListItems.add(ListItem(
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
    playListItems.sort((a, b) => b.created.compareTo(a.created));
    controller.jumpToPage(jumpToPage);
    setState(() {});
  }

  _reloadFolders() async {
    List<ListItem> thisList = [];
    _loadFoldersList(widget.playlist!);
    foldersList.clear();
    QuerySnapshot result =
        await docManager.getDocs(collection: widget.firebasePath);

    for (var element in result.docs) {
      Map data = element.data() as Map;

      if (data['type'] == 'folder') {
        thisList.add(ListItem(
            type: 'folder',
            modified: Timestamp.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch),
            name: data['displayName'],
            docPath: element.reference,
            created: data['created']));
      }
    }
    await _loadFoldersList(thisList);
    print(foldersList.length);
    return true;
  }
}
