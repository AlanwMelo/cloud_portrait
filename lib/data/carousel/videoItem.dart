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
  bool startPlaying = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    /*_controller = VideoPlayerController.network(widget.item.linkURL!)
      ..initialize().then((_) {
        _controller.play();
        startPlaying = true;
        setState(() {});

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      });*/

    _notifyWhenVideoEnds();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.canChange(true);
    return Container();
    /// remoção temporaria dos videos
    /*return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Container(),
    );*/
  }

  _notifyWhenVideoEnds() async {
    while (!startPlaying) {
      await Future.delayed(const Duration(seconds: 1));
    }
    while (_controller.value.duration != _controller.value.position) {
      await Future.delayed(const Duration(seconds: 1));
    }
    widget.canChange(true);
  }
}
