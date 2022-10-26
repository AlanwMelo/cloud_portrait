import 'package:cloud_portrait/presentation/listViewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  final ListItem item;
  final Function(bool) canChange;

  const VideoItem({super.key, required this.item, required this.canChange});

  @override
  State<StatefulWidget> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.item.linkURL!)
      ..initialize().then((_) {
        _controller.play();
        setState(() {});

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      });

    _notifyWhenVideoEnds();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Container(),
    );
  }

  _notifyWhenVideoEnds() async {
    while (_controller.value.position != _controller.value.position) {
      await Future.delayed(const Duration(seconds: 1));
    }
    widget.canChange(true);
  }
}
