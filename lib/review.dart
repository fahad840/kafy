import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kafy/booking_result.dart';
import 'package:kafy/utility.dart';
import 'package:geocoder/geocoder.dart';
import 'dto/doctor.dart';
import 'package:intl/intl.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'localization/app_translations.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


class Review extends StatefulWidget {
  @override
  _ReviewState createState() {
    return new _ReviewState();
  }
}

class _ReviewState extends State<Review> {
  final GlobalKey<ScaffoldState> _scafoldState = new GlobalKey<ScaffoldState>();

  List _services = [];
  List _selectedservices = [];
  var checkboxes = [];
  bool _changeval;
  int _totalPrice = 0;
  String _servicedata="";

  Map<String, bool> checkboxvalues = new Map();

  _getServices() {
    setState(() {
      _isLoading = true;
    });
    httpGet(SERVERURL + "doctors/services/${DOCTOR.id}").then((res) async {
      setState(() {
        _isLoading = false;
      });
      print("_getservices " + res.toString());

      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success
        setState(() {
          _services = resJson['services'];
          for (int i = 0; i < _services.length; i++) {
            checkboxes.add(false);
          }
        });
      } else {
        //       failed
        _scafoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red, content: Text(resJson['message'])));
      }
    }).catchError((error) {
//    connection error
      print("_getCategories error " + error);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAddress();
    _getServices();
  }

  getAddress() async {
    final coordinates = new Coordinates(
        double.parse(CUSTOMER.latLng.split(",")[0]),
        double.parse(CUSTOMER.latLng.split(",")[1]));
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _address = first.addressLine;
      lat = first.coordinates.latitude;
      lng = first.coordinates.longitude;
      _cordinates = "$lat,$lng";
    });
    print("${first.featureName} : ${first.addressLine}");
    print("$lat : $lng");
    print(_cordinates);
    //  print(widget._doctor.photoUrl);
  }

  var _visitTime = 'Select';
  var _visitDate=DateTime.now().toUtc().toString().split(" ")[0];
  var enableBooking = false;
  var _address = '';
  double lat, lng;
  String _cordinates;
  bool _isLoading = false;

  _bookNow() async {
    setState(() {
      _isLoading = true;
    });

    BOOKING["visit_time"] = _visitTime;
    httpPost(
        SERVERURL + "bookings/update",
        json.encode({
          "id": BOOKING["id"],
          "visit_time": _visitTime,
          "location": _cordinates,
          "totalPrice":_totalPrice,
          "services":_servicedata,
          "visit_date":_visitDate
        })).then((res) async {
      print(res);
      var resJson = json.decode(res);

      if (resJson['result'] == 1) {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (BuildContext context) => BookingResult()),
            (Route<dynamic> route) => false);
      }
    }).catchError((error) {
//    connection error
      print("loginMobile error " + error.toString());
      setState(() {
        _isLoading = false;
      });
      _scafoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(AppTranslations.of(context).text("connection_error"))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scafoldState,
        appBar: AppBar(
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          title: Text(AppTranslations.of(context).text('review')),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            AppTranslations.of(context).text("review_text"),
                            style: TextStyle(fontSize: 18.0),
                          )),
                      Container(
                        height: 80.0,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Image.network(
                                  FILESURL + "placeholder-profile.png"),
                              flex: 1,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      DOCTOR.name,
                                      style: mainFont,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          DOCTOR.avgRating,
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
//                                    LANG == "ar"
//                                        ? Text(
//                                            "${DOCTOR.fee} ${AppTranslations.of(context).text("sar")}",
//                                            style: TextStyle(fontSize: 16.0),
//                                          )
//                                        : Text(
//                                            "${AppTranslations.of(context).text("sar")}  ${DOCTOR.fee}",
//                                            style: TextStyle(fontSize: 16.0),
//                                          ),
                                  ],
                                ),
                              ),
                              flex: 3,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                                child: Text( AppTranslations.of(context).text("visit_date"))),
                            flex: 1,
                          ),
                          Expanded(
                            child: Center(
                                child: FlatButton(
                                  child: new Text(
                                    "$_visitDate",
                                    style: TextStyle(color: primaryColor),
                                  ),
                                  onPressed: () async {
                                   _selectIOSDate();
                                  },
                                )),
                            flex: 1,
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                                child: Text( AppTranslations.of(context).text("time"))),
                            flex: 1,
                          ),
                          Expanded(
                            child: Center(
                                child: FlatButton(
                              child: new Text(
                                "$_visitTime",
                                style: TextStyle(color: primaryColor),
                              ),
                              onPressed: () async {
                                TimeOfDay dsf = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                setState(() {
                                  enableBooking = true;
                                  _visitTime = dsf.hour.toString() +
                                      ':' +
                                      dsf.minute.toString();
                                });
                                print(dsf);
                              },
                            )),
                            flex: 1,
                          )
                        ],
                      ),
                      divider(),
                      tableWidget(
                          AppTranslations.of(context).text("location"),
                          _address),
                      _services != null
                          ? checkbox(_services, false)
                          : Container(),
                      divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: Text( AppTranslations.of(context).text("total_price")),
                            ),
                            flex: 1,
                          ),
                          Expanded(
                            child: Center(
                              child: Text("$_totalPrice SR"),
                            ),
                            flex: 1,
                          )
                        ],
                      )
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
                          child: Text(
                              AppTranslations.of(context).text("confirm") , style: TextStyle(fontFamily: 'Cairo'),),
                          onPressed: enableBooking
                              ? () {
                            for(int i=0;i<_selectedservices.length;i++)
                              {
                                _servicedata="$_servicedata"+"${_selectedservices[i]['id']}"+",";

                              }

                              _bookNow();
                                }
                              : null,
                          color: primaryColor,
                        )
                      : Row(
                          children: <Widget>[CircularProgressIndicator()],
                          mainAxisAlignment: MainAxisAlignment.center,
                        )
                ],
              ),
            )
          ],
        ));
  }

  Future _selectIOSDate() async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
          print('confirm $date');

          var formatter = new DateFormat('yyyy-MM-dd');
          String formatted = formatter.format(date);

//      _scaffoldState.currentState
//          .showSnackBar(SnackBar(content: Text(picked.toString())));
          setState(() {

            _visitDate=formatted;
          });
        }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime.now(),
      lastDate: DateTime(2020)

    );

    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(picked);

//      _scaffoldState.currentState
//          .showSnackBar(SnackBar(content: Text(picked.toString())));
    setState(() {
      _visitDate=formatted;
    });
  }

  tableWidget(text, value) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Center(child: Text(text)),
              flex: 1,
            ),
            Expanded(
              child: Center(child: Text(value)),
              flex: 1,
            )
          ],
        ),
        divider()
      ],
    );
  }

//  Widget checkbox(services, bool boolValue) {
//    List<Widget> list = new List<Widget>();
//    for (var i = 0; i < services.length; i++) {
//      _changeval = checkboxes.elementAt(i);
//      print("${checkboxes.elementAt(i)} index $i");
////    checkboxvalues[services[i]['nameEn']]=boolValue;
//      list.add(Column(
//        mainAxisSize: MainAxisSize.max,
//        children: <Widget>[
//          Row(
//            mainAxisSize: MainAxisSize.max,
//            mainAxisAlignment: MainAxisAlignment.spaceAround,
//            children: <Widget>[
//              LANG == "ar"
//                  ? Text(services[i]['nameAr'])
//                  : Text(services[i]['nameEn']),
//              IconButton(
//                icon: new Icon(_changeval == true
//                    ? Icons.check_box
//                    : Icons.check_box_outline_blank),
//                color: _changeval == true ? Colors.teal : Colors.black26,
//                onPressed: () {
//                  setState(() {
//                    if (_changeval) {
//                      checkboxes.insert(i, false);
//                      _selectedservices.remove(services[i]);
//                      print("removed $_selectedservices");
//                      if (_totalPrice != 0) {
//                        _totalPrice =
//                            _totalPrice - int.parse(services[i]['fee']);
//                      }
//                    } else if(_changeval==false){
//                      checkboxes.insert(i, true);
//
//                      _selectedservices.add(services[i]);
//                      print("added $_selectedservices");
//
//                      if (_totalPrice >= 0) {
//                        _totalPrice =
//                            _totalPrice + int.parse(services[i]['fee']);
//                      }
//                    }
//                  });
//                },
//              )
//            ],
//          )
//        ],
//      ));
//    }
//
//    return new Wrap(children: list, spacing: 2.0, runSpacing: 0.1);
//  }


  Widget checkbox(services, bool boolValue) {
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < services.length; i++) {
      _changeval = checkboxes.elementAt(i);
      print("${checkboxes.elementAt(i)} index $i");
//    checkboxvalues[services[i]['nameEn']]=boolValue;
      list.add(Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(

                child:
                Center(
          child:  LANG == "ar"
              ? Text(services[i]['nameAr'])
              : Text(services[i]['nameEn'])  ,
                )

              ),

              Checkbox(
                value: _changeval,
                onChanged: (bool value) {
                  print("change value $value");
                  setState(() {
                    if (value) {
                      _changeval=value;
                      checkboxes.removeAt(i);
                      checkboxes.insert(i, value);
                      _selectedservices.add(services[i]);
                      print("added $_selectedservices");

                      if (_totalPrice >= 0) {
                        _totalPrice =
                            _totalPrice + int.parse(services[i]['fee']);
                      }
                    } else if(value==false){
                      _changeval=value;
                      checkboxes.removeAt(i);
                      checkboxes.insert(i, value);
                      _selectedservices.remove(services[i]);
                      print("removed $_selectedservices");
                      if (_totalPrice != 0) {
                        _totalPrice =
                            _totalPrice - int.parse(services[i]['fee']);
                      }
                    }
                  });

                },
              )
            ],
          )
        ],
      ));
    }

    return new Wrap(children: list, spacing: 2.0, runSpacing: 0.1);
  }
}
