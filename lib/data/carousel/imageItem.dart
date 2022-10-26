import 'dart:async';

import 'package:cloud_portrait/presentation/listViewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

class ImageItem extends StatefulWidget {
  final ListItem item;
  final Function(bool) canChange;

  const ImageItem({super.key, required this.item, required this.canChange});

  @override
  State<StatefulWidget> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  late Timer timer;
  late Duration duration;

  @override
  void initState() {
    widget.item.specialIMG
        ? duration = const Duration(minutes: 2)
        : const Duration(minutes: 1);
    timer = Timer.periodic(duration, (timer) {
      widget.canChange(true);
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.item.specialIMG
        ? Panorama(
            animSpeed: 1,
            child: Image.network(widget.item.linkURL!),
          )
        : Image.network(widget.item.linkURL!);
  }
}
