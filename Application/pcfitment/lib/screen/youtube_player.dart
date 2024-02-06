import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerPage extends StatefulWidget {
  final String toolbarTitle;
  final String id;

  const YoutubePlayerPage(
      {super.key, required this.toolbarTitle, required this.id});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  String titleLbl = '';

  late YoutubePlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = YoutubePlayerController(
        initialVideoId: widget.id,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          //mute: false,
          //disableDragSeek: false,
          //loop: false,
          //isLive: false,
          //forceHD: false,
          //enableCaption: true,
        ));

    /*..addListener(listener);
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;*/
  }

  /*@override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }*/

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      /*onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },*/
      player: YoutubePlayer(
        controller: _controller,
        liveUIColor: Colors.amber, // Change the color of the live UI
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ),
          body: Center(
            child: player,
          ),
        );
      },
    );
  }
}
