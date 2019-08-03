import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as platform;
import 'package:flutter/material.dart';
import 'searchScreen.dart';
import 'chatPage.dart';
import 'package:kafy/dto/category.dart';
import 'package:kafy/dto/customer.dart';
import 'package:kafy/localization.dart';
import 'bookingPage.dart';
import 'package:kafy/main.dart';
import 'package:kafy/utility.dart';
import 'historyPage.dart';
import 'languageSetting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'localization/app_translations.dart';


SharedPreferences prefs;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();
  Customer _customer = Customer.fromJson({});
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // var user;
  var _categories = [];
  var categories = <Category>[];
  var _selectedCategory;

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.getToken().then((token){
      print(token);
     CUSTOMER.deviceToken=token;
      updateToken();

    });
    _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print(" onLaunch called");
    }, onResume: (Map<String, dynamic> msg) {
      print(" onResume called");
    }, onMessage: (Map<String, dynamic> msg) {
      print(" onMessage called");
      print(msg);
    });
    _getUser();


//    _getLocation();
  }

//  _getPermissions() async {
//    Permission permission = Permission.AccessFineLocation;
//    bool res = (await SimplePermissions.requestPermission(permission)) as bool;
//
//    if (res) _getLocation();
//  }

//  _getPermissionsOpenSettings() async {
//    bool res = await SimplePermissions.openSettings();
//
////    if (res) _getLocation();
//  }

  _getUser() async {
    prefs = await SharedPreferences.getInstance();
    String _user = prefs.getString("user");
    if (_user != null) {
      setState(() {
        _customer = CUSTOMER;
        // user = json.decode(_user);
      });
    }
  }

  void updateToken() async {


    httpPost(SERVERURL + "customer/updateCustomerDeviceToken",json.encode(CUSTOMER)).then((res) async {

      var resJson = json.decode(res);
      print(res);
      if (resJson['result'] == 1) {
        // otp verified

      } else {
        //verification failed
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(AppTranslations.of(context).text("token_error")));
      }
    }).catchError((error) {
//    connection error
      SnackBar(
          backgroundColor: Colors.red,
          content:
          Text(AppTranslations.of(context).text("connection_error")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldState,
          drawer: Drawer(
            child: drawerList(context, _customer),
          ),
          appBar: AppBar(
            elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
            title: Text(AppTranslations.of(context).text('app_name')),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: AppTranslations.of(context).text("search"),
                ),
                Tab(
                  text: AppTranslations.of(context).text("chat"),
                ),
                Tab(
                  text: AppTranslations.of(context).text("bookings"),
                ),
              ],
            ),
          ),
          body: TabBarView(children: [
            new SearchPage(),
            new ChatPage(),
            new BookingPage(_scaffoldState)
          ]),
        ));
  }
}

signoutApp(BuildContext context) async {
  prefs = await SharedPreferences.getInstance();
  prefs.setString("user", null);

  Route route = MaterialPageRoute(builder: (context) => LoginPage());
  Navigator.pushReplacement(context, route);
}



Widget drawerList(BuildContext context, Customer customer) {
  return ListView(
    children: <Widget>[
      Container(
        height: 200.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              circleImage((customer != null && customer.photoUrl != null)
                  ? customer.photoUrl
                  : FILESURL + "placeholder-profile.png"),
              Text(
                customer != null ? customer.name : "NA",
                style: TextStyle(fontSize: 18.0),
              )
            ],
          ),
        ),
      ),
//      ListTile(
//        leading: Icon(Icons.photo_album),
//        title: Text('Map'),
//        onTap: () {
//          Navigator.of(context).pop();
//          Route route = CupertinoPageRoute(builder: (context) => ChatRooms());
//          Navigator.push(context, route);
//        },
//      ),
      ListTile(
        leading: Icon(Icons.photo_album),
        title: Text(AppTranslations.of(context).text("history")),
        onTap: () {
          Navigator.of(context).pop();
          Route route = MaterialPageRoute(builder: (context) => historyPage());
          Navigator.push(context, route);
        },
      ),

      ListTile(
        leading: Icon(Icons.language),
        title: Text(AppTranslations.of(context).text("language")),
        onTap: () {
          Navigator.of(context).pop();
          Route route = MaterialPageRoute(builder: (context) => languageSetting());
          Navigator.push(context, route);
        },
      ),
      ListTile(
        onTap: () {
          signoutApp(context);
        },
        leading: Icon(Icons.exit_to_app),
        title: Text(AppTranslations.of(context).text("logout")),
      ),
    ],
  );
}



class Person {
  Person(this.name, this.address);

  final String name, address;

  @override
  String toString() => name;
}
