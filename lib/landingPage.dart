import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'localization/app_translations_delegate.dart';
import 'localization/application.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/app_translations.dart';
import 'main.dart';
import 'registermobile.dart';
import 'dto/customer.dart';
import 'utility.dart';
import 'home.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
//  MapView.setApiKey("AIzaSyDLwsfPUlJLwLBrpEKcHlodvd9ksnSQWsM");
  runApp(new LandingPage());
}
SharedPreferences prefs;

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.teal,
  accentColor: Colors.amber[400],
  fontFamily: 'Cairo'
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.teal,
  accentColor: Colors.amber[400],
    fontFamily: 'Cairo'
);

class LandingPage extends StatelessWidget {
  Locale locale;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafy',
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (this.locale == null) {
            this.locale = Locale('ar');
            print(deviceLocale);
          }
          return this.locale;
        },
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          AppTranslationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: application.supportedLocales()
        // Arabic
        // ... other locales the app supports
        ,
        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? kIOSTheme
            : kDefaultTheme,

      home: MyAppState(),
    );
  }


}

class MyAppState extends StatefulWidget {

  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<MyAppState> {
  AppTranslationsDelegate _newLocaleDelegate;

  VideoPlayerController playerController;
  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    _getUser(context);
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;

    playerController = VideoPlayerController.asset("resources/video/LoaderVideo-Kafy.mp4")
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    playerController.play();
    playerController.setLooping(true);


  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
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
    return
         Scaffold(
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
                            onPressed: () {
                              Route route = MaterialPageRoute(builder: (context) => MyApp());
                              Navigator.pushReplacement(context, route);
                            },
                            color: Colors.teal,
                            child: Text(
                              AppTranslations.of(context).text("login"),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
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
                            onPressed: () {
                              Customer customer=new Customer();
                              Route route = MaterialPageRoute(builder: (context) => RegisterMobilePage(customer));
                              Navigator.pushReplacement(context, route);
                            },
                            color: Colors.teal,
                            child: Text(
                              AppTranslations.of(context).text("register"),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        )
                      ]),
                ))
          ],
        ));
  }

  _getUser(context) async {
    prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("user");
    if (user != null) {
      CUSTOMER = Customer.fromJson(json.decode(user));
      Route route = MaterialPageRoute(builder: (context) => Home());
      Navigator.pushReplacement(context, route);
    }
  }
}
