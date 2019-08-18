import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kafy/chatscreen.dart';
import 'package:kafy/dto/doctor.dart';
import 'package:kafy/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:kafy/utility/star_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/app_translations.dart';

class DoctorProfilePage extends StatefulWidget {
  Doctor doctor;

  DoctorProfilePage({this.doctor});

  @override
  DoctorProfilePageState createState() {
    return new DoctorProfilePageState();
  }
}

class DoctorProfilePageState extends State<DoctorProfilePage> {
  bool favToggle = false;
  var _reviews = [];
  var _categories = [];
  String status = "";
  var _services = [];

  var _isLoading = false;

  _getReviews() {
    _isLoading = true;
    httpGet(SERVERURL + "doctors/reviews/${widget.doctor.id}")
        .then((res) async {
      _isLoading = false;

      print("_getDoctors " + res.toString());

      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success

        print(resJson['reviews']);
        setState(() {
          _reviews = resJson['reviews'];
          _categories = resJson['subcategories'];
          if (_reviews.isEmpty) status = AppTranslations.of(context).text("no_data");
        });
      } else {
        //       failed
//        _scaffoldState.currentState.showSnackBar(SnackBar(
//            backgroundColor: Colors.red, content: Text(resJson['message'])));
      }
    }).catchError((error) {
      setState(() {
        status = "No Connection";
        _isLoading = false;
      });

//    connection error
      print("_getDoctors error " + error.toString());
    });
  }

  _getServices() {
    _isLoading = true;
    httpGet(SERVERURL + "doctors/services/${widget.doctor.id}")
        .then((res) async {
      _isLoading = false;

      print("_getDoctors " + res.toString());

      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success

        print(resJson['services']);
        setState(() {
          _services = resJson['services'];
          if (_reviews.isEmpty) status = AppTranslations.of(context).text("no_data");
        });
      } else {
        //       failed
//        _scaffoldState.currentState.showSnackBar(SnackBar(
//            backgroundColor: Colors.red, content: Text(resJson['message'])));
      }
    }).catchError((error) {
      setState(() {
        status = "No Connection";
        _isLoading = false;
      });

//    connection error
      print("_getDoctors error " + error.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUser();
    _getReviews();
    _getServices();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          title: Text(widget.doctor.name),
//          actions: <Widget>[
//            favToggle
//                ? IconButton(
//                    icon: Icon(
//                      Icons.favorite,
//                      color: Colors.red,
//                    ),
//                    onPressed: () {
//                      setState(() {
//                        favToggle = !favToggle;
//                      });
//                    })
//                : IconButton(
//                    icon: Icon(Icons.favorite),
//                    onPressed: () {
//                      setState(() {
//                        favToggle = !favToggle;
//                      });
//                    })
//          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: AppTranslations.of(context).text("profile"),
              ),
              Tab(
                text: AppTranslations.of(context).text("reviews"),
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 80.0,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Image.network(widget.doctor.photoUrl!=null?widget.doctor.photoUrl:FILESURL + "placeholder-profile.png"),
                                flex: 1,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.doctor.name,
                                        style: mainFont,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.doctor.avgRating,
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                color: disabledColor),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: primaryColor,
                                            size: 14.0,
                                          )
                                        ],
                                      ),
//                                      LANG == "ar"
//                                          ? Text(
//                                              "${widget.doctor.fee} ${AppTranslations.of(context).text("sar")}",
//                                              style: TextStyle(fontSize: 16.0),
//                                            )
//                                          : Text(
//                                              "${AppTranslations.of(context).text("sar")}  ${widget.doctor.fee}",
//                                              style: TextStyle(fontSize: 16.0),
//                                            ),
                                    ],
                                  ),
                                ),
                                flex: 3,
                              ),
                            ],
                          ),
                        ),
                        divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                  child: Text(
                                      "${widget.doctor.experience} "+AppTranslations.of(context).text("years_of_experience"))),
                              flex: 1,
                            ),
                            Expanded(
                              child: Center(
                                  child: Text("${widget.doctor.gender =="Male"?AppTranslations.of(context).text("male"):AppTranslations.of(context).text("female")}")),
                              flex: 1,
                            )
                          ],
                        ),
                        divider(),
                        Text(
                          AppTranslations.of(context).text("speciality"),
                          style: mainFont,
                        ),

                        specialityTab(_categories),
                        divider(),
                        Text(
                          AppTranslations.of(context).text("service_cost"),
                          style: mainFont,
                        ),
                        Padding(padding: EdgeInsets.only(top: 8.0)),
                        servicestab(_services),
                        divider(),

                        Text(
                          AppTranslations.of(context).text("description"),
                          style: mainFont,
                        ),
                        Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(widget.doctor.description),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    !_isLoading
                        ? CupertinoButton(
                            child: Text(AppTranslations.of(context).text("start_chat") ,style: TextStyle(fontFamily: 'Cairo'),),
                            onPressed: () {
                              _startBooking();
                            },
                            color: primaryColor,
                          )
                        : Row(
                            children: <Widget>[CircularProgressIndicator()],
                            mainAxisAlignment: MainAxisAlignment.center,
                          )
                  ],
                ),
              ),
            ],
          ),
          Container(
            child: Stack(
              children: <Widget>[
                ListView.builder(
                  shrinkWrap: false,
                  itemBuilder: (BuildContext context, int index) => Container(
                        margin: EdgeInsets.all(10.0),
                        child: _reviewUI(index),
                      ),
                  itemCount: _reviews.length,
                ),
                _isLoading ? loader() : Container(),
                _reviews.isEmpty && !_isLoading
                    ? Center(
                        child: Text(status),
                      )
                    : Container()
              ],
            ),
          )
        ]),
      ),
    );
  }

  _reviewUI(int index) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: new BoxDecoration(
        color: Colors.grey[200],
        borderRadius: new BorderRadius.circular(5.0),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("${_reviews[index]["customer_name"]}"),
            StarRating(
              rating: double.parse(_reviews[index]['rating'].toString()),
            ),
            Text("${_reviews[index]["posted_on"].toString().split("T")[0]}"),
            Padding(padding: EdgeInsets.all(5.0)),
            Text(_reviews[index]["review"]),
          ]),
    );
  }

  _startBooking() {
    setState(() {
      _isLoading = true;
    });
    String data = '{"customer_id": "' +
        user["id"].toString() +
        '","doctor_id": "' +
        widget.doctor.id.toString() +
        '"}';

    httpPost(SERVERURL + "bookings", data).then((res) {
      print("_startBooking $res");
      setState(() {
        _isLoading = false;
      });

      var resJson = json.decode(res);

      if (resJson['result'] == 1) {
//        success
//        Navigator.push(
//          context,
//          MaterialPageRoute(builder: (context) => FABTOP()),
//        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    customer: CUSTOMER,
                    booking: resJson["booking"],
                  )),
        );
      } else {
//        failed
      }
    }).catchError((onError) {
      debugPrint("_startBooking error" + onError.toString());
      setState(() {
        _isLoading = false;
      });
    });
  }

  var user;

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _user = prefs.getString("user");
    if (_user != null) {
      setState(() {
        user = json.decode(_user);
      });
    }
  }
}

Widget specialityTab(categories) {
  List<Widget> list = new List<Widget>();
  for (var i = 0; i < categories.length; i++) {
    list.add(Chip(
      label: LANG == 'ar'
          ? Text(categories[i]['name_ar'])
          : Text(categories[i]['name_en']),
    ));
  }
  return new Wrap(children: list, spacing: 2.0, runSpacing: 0.1);
}

Widget servicestab(categories) {
  List<Widget> list = new List<Widget>();
  for (var i = 0; i < categories.length; i++) {
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: LANG == 'ar'
              ? Text(categories[i]['nameAr'])
              : Text(categories[i]['nameEn']),

        ),

        Text("${categories[i]['fee']} SR",style: TextStyle(fontSize: 16,color: Colors.black) ),


      ],

    )

    );
  }
  return new Wrap(children: list, spacing: 2.0, runSpacing: 0.1);
}
