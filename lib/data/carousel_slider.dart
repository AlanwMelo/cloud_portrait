import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_portrait/data/carousel/imageItem.dart';
import 'package:cloud_portrait/data/carousel/videoItem.dart';
import 'package:cloud_portrait/presentation/listViewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

// ignore: must_be_immutable
class PortraitCarousel extends StatefulWidget {
  List<ListItem>? playlist;

  PortraitCarousel({super.key, this.playlist});

  @override
  State<StatefulWidget> createState() => _PortraitCarouselState();
}

class _PortraitCarouselState extends State<PortraitCarousel> {
  CarouselController controller = CarouselController();
  int currentIndex = 0;
  List<ListItem> playListItems = [];

  @override
  void initState() {
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

  _nextFile(bool result) {
    if (result) {
      if (currentIndex == (playListItems.length - 1)) {
        controller.previousPage();
      } else {
        controller.nextPage();
      }
    }
  }
}
