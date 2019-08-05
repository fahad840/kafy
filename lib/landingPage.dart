import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Example',
      home: VideoExample(),
    );
  }
}

class VideoExample extends StatefulWidget {
  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<VideoExample> {
  VideoPlayerController playerController;
  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    createVideo();
    playerController.play();
    playerController.setLooping(true);

    listener = () {
      setState(() {});
    };
  }

  void createVideo() {
    if (playerController == null) {
      playerController =
          VideoPlayerController.asset("resources/video/LoaderVideo-Kafy.mp4")
            ..addListener(listener)
            ..setVolume(1.0)
            ..initialize()
            ..play();
    } else {
      if (playerController.value.isPlaying) {
        playerController.pause();
      } else {
        playerController.initialize();
        playerController.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          child: (playerController != null
              ? VideoPlayer(
                  playerController,
                )
              : Container()),
        ),
        Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        onPressed: () {},
                        color: Colors.teal,
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        onPressed: () {},
                        color: Colors.teal,
                        child: Text(
                          "Register",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    )
                  ]),
            ))
      ],
    ));
  }
}
