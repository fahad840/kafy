import 'package:flutter/material.dart';
import 'dto/doctor.dart';
import 'utility.dart';
import 'localization.dart';
import 'chatScreendrawer.dart';
import 'dart:convert';
import 'localization/app_translations.dart';

class ChatPage extends StatefulWidget {
  @override
  ChatState createState() {
    // TODO: implement createState
    return new ChatState();
  }
}

class ChatState extends State<ChatPage> {
  bool _isLoading = false;
  List bookings;
  List doctors;

  @override
  void initState() {
    getBookings();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      Stack(
        children: <Widget>[

          _isLoading
              ? Container(
            color: Colors.black45,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : Container(),
      ListView.builder(
      itemCount: bookings!=null?
        bookings.length:0,
        itemBuilder: (context, i) => new Column(
          children: <Widget>[
            new Divider(
              height: 10.0,
            ),
            new ListTile(
              leading: new CircleAvatar(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey,
                backgroundImage: new NetworkImage(

                    doctors.elementAt(i)['photoUrl']!=null? doctors.elementAt(i)['photoUrl']:FILESURL + "placeholder-profile.png"),
              ),
              title: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    doctors.elementAt(i)['name'],
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
                  new Text(
                    "",
                    style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                ],
              ),
              subtitle: new Container(
                padding: const EdgeInsets.only(top: 5.0),
                child: new Text(
                  "",
                  style: new TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
              ),
              onTap: () {
                Route route = MaterialPageRoute(
                    builder: (context) =>
                        ChatScreenDrawer(customer:CUSTOMER , booking: bookings.elementAt(i)));
                Navigator.push(context, route);
              },
            ),
            _isLoading
                ? Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : Container()
          ],
        ),
      )

        ],
      );


  }

  void getBookings() {
    setState(() {
      _isLoading = true;
    });

    httpGet(SERVERURL + "bookings/customer/${CUSTOMER.id}").then((res) async {
      setState(() {
        _isLoading = false;
      });
      var resJson = json.decode(res);
      print(res);
      if (resJson['result'] == 1) {
        // otp verified
        bookings = resJson['bookings'];
        doctors=resJson['doctors'];

      } else {
        //verification failed
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(AppTranslations.of(context).text("invalid_otp")));
      }
    }).catchError((error) {
//    connection error
      setState(() {
        _isLoading = false;
      });
      SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(AppTranslations.of(context).text("connection_error")));
    });
  }
}
