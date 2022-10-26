import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

class PortraitCarousel extends StatefulWidget {
  const PortraitCarousel({super.key});

  @override
  State<StatefulWidget> createState() => _PortraitCarouselState();
}

class _PortraitCarouselState extends State<PortraitCarousel> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Wakelock.enable();
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
          options: CarouselOptions(
              height: 400.0, enableInfiniteScroll: false, viewportFraction: 1),
          items: [1, 2, 3, 4, 5].map((i) {
            return Builder(
              builder: (BuildContext context) {
                ValueNotifier<bool> isVisible = ValueNotifier(false);

                visible() async {
                  bool result = false;

                  isVisible.addListener(() {
                    result = isVisible.value;
                  });

                  while (!result) {
                    await Future.delayed(const Duration(seconds: 1));
                  }
                  return result;
                }

                return VisibilityDetector(
                  key: UniqueKey(),
                  child: FutureBuilder(
                    future: visible(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(color: Colors.amber),
                            child: Text(
                              'text $i',
                              style: TextStyle(fontSize: 16.0),
                            ));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 100) {
                      isVisible.value = true;
                      debugPrint(
                          'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
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
}
