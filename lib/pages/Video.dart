import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoAnim extends StatefulWidget {
  final String? video;
  const VideoAnim({super.key, this.video});

  @override
  State<VideoAnim> createState() => _VideoAnimState();
}

class _VideoAnimState extends State<VideoAnim> {
  late VideoPlayerController video;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    video = VideoPlayerController.asset(widget.video!)
      ..initialize().then((e) {
        setState(() {});
        video.play();
        video.setLooping(true);
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [SizedBox(child: VideoPlayer(video))],
    );
  }
}
