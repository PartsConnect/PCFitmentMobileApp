import 'package:flutter/material.dart';
import 'package:vimeo_player_flutter/vimeo_player_flutter.dart';

class VimeoPlayerPage extends StatefulWidget {
  final String toolbarTitle;
  final String id;

  const VimeoPlayerPage(
      {super.key, required this.toolbarTitle, required this.id});

  @override
  State<VimeoPlayerPage> createState() => _VimeoPlayerPageState();
}

class _VimeoPlayerPageState extends State<VimeoPlayerPage> {
  String titleLbl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: Center(
        child: Container(
          height: 220,
          color: Colors.white,
          child: VimeoPlayer(
            videoId: widget.id,
          ),
        ),
      ),

      /*body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              color: Colors.white,
              child: AspectRatio(
                aspectRatio: orientation == Orientation.landscape ? 16 / 9 : 9 / 16,
                child: VimeoPlayer(
                  videoId: widget.id,
                ),
              ),
            ),
          );
        },
      ),*/
    );
  }
}
