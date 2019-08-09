import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kafy/home.dart';
import 'package:kafy/utility.dart';
import 'localization/app_translations.dart';

class BookingResult extends StatefulWidget {
  @override
  BookingResultState createState() {
    return new BookingResultState();
  }
}

class BookingResultState extends State<BookingResult> {
  Future<bool> _onWillPop() {
//    return showDialog(
//          context: context,
//          builder: (context) => new AlertDialog(
//                title: new Text('Are you sure?'),
//                content: new Text('Do you want to exit an App'),
//                actions: <Widget>[
//                  new FlatButton(
//                    onPressed: () => Navigator.of(context).pop(false),
//                    child: new Text('No'),
//                  ),
//                  new FlatButton(
//                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
//                        new MaterialPageRoute(
//                            builder: (BuildContext context) => Home()),
//                        (Route<dynamic> route) => false),
//                    child: new Text('Yes'),
//                  ),
//                ],
//              ),
//        ) ??
//        false;

    return Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (BuildContext context) => Home()),
            (Route<dynamic> route) => false) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            appBar: AppBar(
              elevation:
                  Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
              title: Text(AppTranslations.of(context).text('booking_info')),
            ),
            body: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(10.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.checkCircle,
                      size: 91.0,
                      color: primaryColor,
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Text(
                  AppTranslations.of(context).text("booking_completed"),
                  style: mainFont,
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Text(
                  AppTranslations.of(context).text("booking_status_text"),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                RaisedButton(
                  child: Text( AppTranslations.of(context).text("Done"),style: TextStyle(color:Colors.white ),),
                  color: Colors.teal,

                  onPressed: ()
                  {
                    Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(builder: (BuildContext context) => Home()),
                            (Route<dynamic> route) => false);

                  },

                )
              ],
            )));
  }
}
