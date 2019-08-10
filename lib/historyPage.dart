import 'package:flutter/material.dart';
import 'dart:convert';
import 'utility.dart';
import 'localization.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'localization/app_translations.dart';

class historyPage extends StatefulWidget {
  @override
  historyState createState() {
    // TODO: implement createState
    return historyState();
  }
}

class historyState extends State<historyPage> {
  List bookings;
  List doctors;
  List day = new List();
  List date = new List();
  List month = new List();
  double rating = 1;

  DateTime now;
  bool _isLoading = false;

  @override
  void initState() {
    getBookings();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController reasonController = new TextEditingController();

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text("history")),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
              itemCount: bookings != null ? bookings.length : 0,
              itemBuilder: (context, i) => new Container(
                  decoration: new BoxDecoration(boxShadow: [
                    new BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                    ),
                  ]),
                  child: Card(
                      margin: EdgeInsets.all(15),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "${month.elementAt(i)}",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "${date.elementAt(i)}",
                                    style: TextStyle(
                                        color: Colors.amber, fontSize: 40),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "${day.elementAt(i)}",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            new Container(
                              height: 80.0,
                              width: 1.0,
                              color: Colors.black26,
                              margin: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            AppTranslations.of(context)
                                                .text("Timming"),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                          ),
                                          Text(
                                            bookings.elementAt(i)['visit_time'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            AppTranslations.of(context)
                                                .text("Doctor"),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                          ),
                                          Text(
                                            doctors.elementAt(i)['name'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  new Container(
                                    height: 1,
                                    color: Colors.black26,
                                    margin: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(
                                            AppTranslations.of(context)
                                                .text("Status"),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                          ),
                                          Text(
                                            bookings.elementAt(i)['status'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                          )
                                        ],
                                      ),
                                      bookings.elementAt(i)['customer_rated'] ==
                                              0
                                          ? FlatButton(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                          AppTranslations.of(
                                                                  context)
                                                              .text("Rate"))),
                                                  Padding(
                                                    padding: EdgeInsets.all(1),
                                                  ),
                                                  Icon(
                                                    Icons.star_border,
                                                    color: Colors.amber,
                                                  )
                                                ],
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        new AlertDialog(
                                                            title: new Text(
                                                                AppTranslations.of(
                                                                        context)
                                                                    .text(
                                                                        "Rating")),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  Text(AppTranslations.of(
                                                                          context)
                                                                      .text(
                                                                          "please_rate")),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                  ),
                                                                  SmoothStarRating(
                                                                    allowHalfRating: false,
                                                                    starCount: 5,
                                                                    rating: rating,
                                                                    size: 45.0,
                                                                    onRatingChanged:
                                                                        (v) {
                                                                      rating = v;
                                                                      setState(
                                                                          () {rating = v;});
                                                                    },
                                                                    color: Colors
                                                                        .amber,
                                                                    borderColor:
                                                                        Colors
                                                                            .teal,
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                  ),
                                                                  new TextField(
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .done,
                                                                    enableInteractiveSelection:
                                                                        false,
                                                                    controller:
                                                                        reasonController,
                                                                    maxLines: 3,
                                                                    decoration: new InputDecoration(
                                                                        border: new OutlineInputBorder(
                                                                          borderRadius:
                                                                              const BorderRadius.all(
                                                                            const Radius.circular(6.0),
                                                                          ),
                                                                        ),
                                                                        filled: true,
                                                                        hintStyle: new TextStyle(color: Colors.grey[800]),
                                                                        hintText: AppTranslations.of(context).text("enter_review_here"),
                                                                        fillColor: Colors.white70),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: <
                                                                        Widget>[
                                                                      RaisedButton(
                                                                        child:
                                                                            Text(
                                                                          AppTranslations.of(context)
                                                                              .text("Submit"),
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                        color: Colors
                                                                            .teal,
                                                                        onPressed:
                                                                            () {
                                                                          if (reasonController
                                                                              .text
                                                                              .isEmpty) {
                                                                            SnackBar(
                                                                                backgroundColor: Colors.red,
                                                                                content: Text(AppTranslations.of(context).text("enter_review")));
                                                                          } else {
                                                                            sendReview(
                                                                                i,
                                                                                rating.toInt(),
                                                                                reasonController.text);
                                                                          }
                                                                        },
                                                                      ),
                                                                      RaisedButton(
                                                                        child:
                                                                            Text(
                                                                          AppTranslations.of(context)
                                                                              .text("Cancel"),
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                        color: Colors
                                                                            .teal,
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      )
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            )));
                                              },
                                            )
                                          : Row(
                                              children: <Widget>[
                                                Text(AppTranslations.of(context)
                                                    .text("Rated")),
                                                Padding(
                                                  padding: EdgeInsets.all(1),
                                                ),
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.lightGreen,
                                                )
                                              ],
                                            )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))))
        ],
      ),
    );
  }

  void getBookings() {
    String split;
    setState(() {
      _isLoading = true;
    });

    httpGet(SERVERURL + "bookings/endbookings/${CUSTOMER.id}")
        .then((res) async {
      setState(() {
        _isLoading = false;
      });
      var resJson = json.decode(res);
      print(res);
      if (resJson['result'] == 1) {
        // otp verified
        bookings = resJson['bookings'];
        doctors = resJson['doctors'];
        for (int i = 0; i < bookings.length; i++) {
          split = bookings
              .elementAt(i)['created']
              .toString()
              .split("T")
              .elementAt(0);
          print(split.split("-").elementAt(2));
          int createdday, createdmonth, createdyear;
          createdday = int.parse(split.split("-").elementAt(2));
          createdmonth = int.parse(split.split("-").elementAt(1));
          createdyear = int.parse(split.split("-").elementAt(0));
          now = new DateTime(createdyear, createdmonth, createdday);
          print(now);
          day.add(DateFormat('EEEE').format(now));
          date.add(DateFormat('d').format(now));
          month.add(DateFormat('MMMM').format(now));
        }
        print(day);
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
          content: Text(AppTranslations.of(context).text("connection_error")));
    });
  }

  void sendReview(int i, int rating, String review) {
    setState(() {
      _isLoading = true;
    });

    httpPost(
        SERVERURL + "bookings/sendReview",
        json.encode({
          "bookingId": bookings.elementAt(i)['id'],
          "doctor_id": bookings.elementAt(i)['doctor_id'],
          "customer_id": bookings.elementAt(i)['customer_id'],
          "review": review,
          "rating": rating
        })).then((res) async {
      setState(() {
        _isLoading = false;
      });
      var resJson = json.decode(res);
      print(res);
      if (resJson['result'] == 1) {
        Navigator.of(context).pop();
        getBookings();
      } else {
        //verification failed
        SnackBar(backgroundColor: Colors.red, content: Text("Error"));
      }
    }).catchError((error) {
//    connection error
      setState(() {
        _isLoading = false;
      });
      SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppTranslations.of(context).text("connection_error")));
    });
  }
}
