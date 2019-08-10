import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kafy/dto/customer.dart';
import 'package:kafy/home.dart';
import 'package:kafy/localization.dart';
import 'package:kafy/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/app_translations.dart';

class OTPPage extends StatefulWidget {
  Customer customer;

  OTPPage(this.customer);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
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
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        title: Text(AppTranslations.of(context).text('verify')),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: BoxConstraints.expand(width: 100.0),
                child: TextField(
                  enableInteractiveSelection: false,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (String val) {
                    if (val.length == 4) {
                      widget.customer.otp = val;
                      verifyOTP();
                    }
                  },
                ),
              ), // end PinEntryTextField()
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

  void verifyOTP() {
    setState(() {
      _isLoading = true;
    });

    httpPost(SERVERURL + "customer/verifyotp", json.encode(widget.customer))
        .then((res) async {
      setState(() {
        _isLoading = false;
      });
      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // otp verified
        widget.customer = Customer.fromJson(resJson['customer']);

        CUSTOMER = widget.customer;
        CUSTOMER.photoUrl = null;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', json.encode(resJson['customer']));
        Route route = MaterialPageRoute(builder: (context) => Home());
        Navigator.pushReplacement(context, route);
      } else {
        //verification failed
        _scaffoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content:
                Text(AppTranslations.of(context).text("invalid_otp"))));
      }
    }).catchError((error) {
//    connection error
      setState(() {
        _isLoading = false;
      });
      _scaffoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(AppTranslations.of(context).text("connection_error"))));
    });
  }
}
