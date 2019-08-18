import 'package:flutter/material.dart';
import 'utility.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'localization/app_translations.dart';

class BookingPage extends StatefulWidget {
  GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();

  BookingPage(this._scaffoldState);

  @override
  BookingState createState() {
    // TODO: implement createState
    return new BookingState();
  }
}

class BookingState extends State<BookingPage> {
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

    TextEditingController reasonController = new TextEditingController();


    // TODO: implement build
    return Stack(
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
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[

                        Expanded(
                          child:  Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              color:bookings.elementAt(i)['status']=='accpeted'? Colors.lightGreen:Colors.amber[500],
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  bookings.elementAt(i)['status']=='accpeted'?
                                  AppTranslations.of(context).text("booking_accepted"):AppTranslations.of(context).text("waiting_approval"),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            height: 80,
                            width: 80,
                            child:  CircleAvatar(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.grey,
                              backgroundImage: new NetworkImage(
                                  doctors.elementAt(i)['photoUrl']!=null?doctors.elementAt(i)['photoUrl']:FILESURL + "placeholder-profile.png"),
                            ),
                          ),
                          Expanded(
                            child:
                          Column(
                            children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 20 ,bottom: 10),
                                  child: Text(doctors.elementAt(i)['name'],textAlign: TextAlign.center,style: TextStyle(fontSize: 18)),
                                ) ,

                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: Text(AppTranslations.of(context).text("visit_on")+ " ${bookings.elementAt(i)['visit_date']} at ${bookings.elementAt(i)['visit_time']}",textAlign: TextAlign.center,style: TextStyle(fontSize: 18)),

                              )

                            ],
                          )
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),

                    ),
                    Divider(
                      height: 1,
                      color: Colors.black,

                    ),

                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          new RawMaterialButton(
                            onPressed: () => launch("tel://+${doctors.elementAt(i)['phone']}"),
                            child: new Icon(
                              Icons.call,
                              color: Colors.teal,
                              size: 25.0,
                            ),
                            shape: new CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(15.0),
                          ),
                          new RawMaterialButton(
                            onPressed: () {

                              showDialog(
                                  context: context,
                                  builder: (_) => new AlertDialog(
                                    title: new Text(AppTranslations.of(context).text("Confirmation")),
                                    content:SingleChildScrollView(child:
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                    AppTranslations.of(context).text("enter_reason")),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                        ),
                                        new TextField(
                                          enableInteractiveSelection: false,
                                          controller: reasonController,
                                          maxLines: 3,
                                          textInputAction: TextInputAction.done,
                                          decoration:
                                          new InputDecoration(
                                              border:
                                              new OutlineInputBorder(
                                                borderRadius:
                                                const BorderRadius
                                                    .all(
                                                  const Radius
                                                      .circular(
                                                      6.0),
                                                ),
                                              ),
                                              filled: true,
                                              hintStyle:
                                              new TextStyle(
                                                  color: Colors
                                                      .grey[
                                                  800]),
                                              hintText:
                                              AppTranslations.of(context).text("enter_reason_here"),
                                              fillColor:
                                              Colors.white70),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: <Widget>[
                                            RaisedButton(
                                              child: Text(
                                                AppTranslations.of(context).text("Submit"),
                                                style: TextStyle(
                                                    color:
                                                    Colors.white),
                                              ),
                                              color: Colors.teal,
                                              onPressed: () {
                                                if (reasonController
                                                    .text.isEmpty) {
                                                  SnackBar(
                                                      backgroundColor:
                                                      Colors.red,
                                                      content: Text(
                                                          AppTranslations.of(context).text(
                                                              "enter_reason")));
                                                } else {
                                                  Navigator.pop(context);

                                                  _isLoading?
                                                  null:rejectBooking(
                                                      bookings.elementAt(i)['id']
                                                          .toString(),
                                                      reasonController
                                                          .text);
                                                }
                                              },
                                            ),
                                            RaisedButton(
                                              child: Text(
                                                AppTranslations.of(context).text("Cancel"),
                                                style: TextStyle(
                                                    color:
                                                    Colors.white),
                                              ),
                                              color: Colors.teal,

                                              onPressed: () {
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
                            child: new Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 25.0,
                            ),
                            shape: new CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(15.0),
                          ),
                        ],

                      ),
                    ),




//                    new ListTile(
//                      leading: new
//                      title: new Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          new Text(
//                            "name",
//                            style: new TextStyle(fontWeight: FontWeight.bold),
//                          ),
//                          new Text(
//                            "",
//                            style: new TextStyle(color: Colors.grey, fontSize: 14.0),
//                          ),
//                        ],
//                      ),
//                    ),

                  ],
                )
                )
            )
        )
      ],
    );
  }

  void getBookings() {
    setState(() {
      _isLoading = true;
    });
    print(CUSTOMER.id);
    httpGet(SERVERURL + "bookings/confirmBooking/${CUSTOMER.id}").then((res) async {
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
      widget._scaffoldState.currentState.showSnackBar(
          SnackBar(backgroundColor: Colors.green, content: Text(AppTranslations.of(context).text("connection_error"))));



    });
  }

  void rejectBooking(String bookingId, String reason) {
    setState(() {
      _isLoading = true;
    });

    httpPost(SERVERURL + "bookings/rejectBooking",
        json.encode({"id": bookingId, "reason": reason,"rejected_by":"User"})).then((res) async {
      setState(() {
        _isLoading = false;
      });
      var resJson = json.decode(res);
      print(res);
      if (resJson['result'] == 1) {

        widget._scaffoldState.currentState.showSnackBar(
            SnackBar(backgroundColor: Colors.green, content: Text(AppTranslations.of(context).text("cancel_success"))));


        getBookings();
      } else {
        //verification failed
//        SnackBar(backgroundColor: Colors.red, content: Text("Error"));
      }
    }).catchError((error) {
//    connection error
      setState(() {
        _isLoading = false;
      });
//      SnackBar(
//          backgroundColor: Colors.red,
//          content:
//          Text(AppTranslations.of(context).text("connection_error")));
    });
  }
}
