import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kafy/dto/customer.dart';
import 'package:kafy/otp.dart';
import 'package:kafy/utility.dart';
import 'package:flutter/cupertino.dart';
import 'localization/app_translations.dart';

class RegisterPage extends StatefulWidget {
  Customer _customer;

  RegisterPage(this._customer);

  @override
  RegisterState createState() {
    return new RegisterState();
  }
}

class RegisterState extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textController = new TextEditingController();

    return new Scaffold(
      key: _scaffoldState,
      appBar: new AppBar(
        title: new Text(AppTranslations.of(context).text("register")),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    circleImage(widget._customer.photoUrl),
                    Text(
                      widget._customer.name,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      widget._customer.email,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    TextField(
                      controller: textController,
                      keyboardType: TextInputType.phone,
                      decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                          hintText: '966500000000',
                          labelText:  AppTranslations.of(context).text("mobile_number"),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.green,
                          ),
                          suffix: IconButton(
                              icon: Icon(Icons.arrow_right),
                              color: Colors.green,
                              onPressed: () {
                                widget._customer.phone = textController.text;
                                _signup(context);
                              }),
                          suffixStyle: const TextStyle(color: Colors.green)),
                    )
                  ],
                ),
              ),
            ),
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
    );
  }

  void _signup(BuildContext context) {
    setState(() {
      _isLoading = true;
    });
    httpPost(SERVERURL + "customer/checkuser", json.encode(widget._customer))
        .then((res) async {
      setState(() {
        _isLoading = false;
      });
      var resJson = json.decode(res);
      if (resJson['result'] == 0) {
        //user exists
        _scaffoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(AppTranslations.of(context).text("user_exists") +
                " " +
                widget._customer.phone)));
      } else if (resJson['result'] == 1) {
        //new exists
        _sendOTP();
      }
    }).catchError((error) {
//    connection error
      print("loginMobile error " + error.toString());
      setState(() {
        _isLoading = false;
      });
      _scaffoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(AppTranslations.of(context).text("connection_error"))));
    });
  }

  _sendOTP() {
    httpPost(SERVERURL + "customer/otp", json.encode(widget._customer))
        .then((res) async {
      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // otp sent
        Route route =
            MaterialPageRoute(builder: (context) => OTPPage(widget._customer));
        Navigator.push(context, route);
      } else {
        //sending otp failed
      }
    }).catchError((error) {
//    connection error
      _scaffoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(AppTranslations.of(context).text("connection_error"))));
    });
  }
}
