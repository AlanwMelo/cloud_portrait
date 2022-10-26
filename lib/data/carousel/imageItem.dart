import 'dart:async';

import 'package:cloud_portrait/presentation/listViewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageItem extends StatefulWidget {
  final ListItem item;
  final Function(bool) canChange;

  const ImageItem({super.key, required this.item, required this.canChange});

  @override
  State<StatefulWidget> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
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
    return Center(
      child: widget.item.specialIMG
          ? Container()
          : Image.network(widget.item.linkURL!),
    );
  }
}
