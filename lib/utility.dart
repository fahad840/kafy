import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:kafy/dto/customer.dart';
import 'dto/doctor.dart';

const primaryColor = Colors.teal;
const primaryGrey = Color(0xFF5B5B5B);
const color_google = Color(0xFFDC4538);
const color_fb = Color(0xFF3B5998);
const disabledColor = Colors.grey;
const headerFont = TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0);
const mainFont = TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0);
const sDisabledFont = TextStyle(fontSize: 13.0, color: disabledColor);

var LANG = '';
final String SERVERURL = "http://192.168.8.146:8080/kafy/webapi/";
final String FILESURL = "http://192.168.8.146:8080/webapi/bookings/image/";
//final String SERVERURL = "http://192.168.43.101:8777/kafy/webap                                                                                                                                                                                                                                                                                                                                                                                                                                                                  i/";
//final String FILESURL = "http://192.168.43.101:8777/static/";
Customer CUSTOMER;
Doctor DOCTOR;
var BOOKING;

Future httpPost(String url, String data) async {
  print(data);

  var response = await http.post(url,
      headers: {'Content-Type': 'application/json'} , body: data);


  if (response.statusCode == 200) {
//    success
    return utf8.decode(response.bodyBytes);
  } else {
//    failed
    throw Exception('' + response.statusCode.toString());
  }
}


Future httpGet(String url) async {
  var connectivityResult = await (new Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.none) {
    // I am connected to a mobile network.

    var response = await http.get(url);
    if (response.statusCode == 200) {
//    success
      return utf8.decode(response.bodyBytes);
    } else {
//    failed
      throw Exception('' + response.statusCode.toString());
    }
  } else {
    throw Exception('No Internet');
  }
}


Widget circleImage(imageUrl) {
  return new Container(
      margin: EdgeInsets.all(10.0),
      width: 80.0,
      height: 80.0,
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.fill, image: new NetworkImage(imageUrl))));
}

Widget loader() {
  return Container(
    color: Colors.white,
    child: Center(
      child: defaultTargetPlatform == TargetPlatform.iOS
          ? CupertinoActivityIndicator()
          : CircularProgressIndicator(),
    ),
  );
}


Widget divider() {
  return Container(
    margin: EdgeInsets.all(15.0),
    color: Colors.black12,
    height: 1.0,
    width: double.infinity,
  );
}