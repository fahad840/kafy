import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kafy/dto/customer.dart';
import 'package:kafy/localization.dart';
import 'package:kafy/otp.dart';
import 'package:kafy/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:kafy/utility/platform_widget.dart';
import 'localization/app_translations.dart';

class RegisterMobilePage extends StatefulWidget {
  Customer customer;

  RegisterMobilePage(this.customer);

  @override
  RegisterState createState() {
    return new RegisterState();
  }
}

class RegisterState extends State<RegisterMobilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  var _locations = [];
  int _radioValue1 = -1;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getCities();
  }
  @override
  Widget build(BuildContext context) {
    var textController;
      textController = new TextEditingController(text: widget.customer.phone);


    return new Scaffold(
      key: _scaffoldState,
      appBar: new AppBar(
        title: new Text(AppTranslations.of(context).text("register")),
      ),
      body: SingleChildScrollView(
    child:Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: textController,
                  keyboardType: TextInputType.phone,
                  inputFormatters:[
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: new InputDecoration(

                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      hintText: '966500000000',

                      labelText:
                          AppTranslations.of(context).text("mobile_number"),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Colors.green,
                      ),
                      suffix: IconButton(
                        icon: Icon(Icons.arrow_right),
                        color: Colors.transparent,
                      ),

                      suffixStyle: const TextStyle(color: Colors.green)),
                ),
                Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: formUI(),
                )
              ],
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
    ));
  }
  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
        case 0:
//          _scaffoldState.currentState
//              .showSnackBar(SnackBar(content: Text("Male")));
          widget.customer.gender = "Male";
          break;
        case 1:
//          _scaffoldState.currentState
//              .showSnackBar(SnackBar(content: Text("Female")));
          widget.customer.gender = "Female";
          break;
      }
    });
  }

  Widget formUI() {
    var textController = new TextEditingController();

    return new Column(
      children: <Widget>[
        TextFormField(
          validator: (val) {
            if (val.length < 3)
              return  AppTranslations.of(context).text("valid_name");
            else
              return null;
          },
          onSaved: (String val) {
            widget.customer.name = val;
          },
          decoration: InputDecoration(
              labelText: AppTranslations.of(context).text("name")),
          keyboardType: TextInputType.text,
        ),
        TextFormField(
          validator: validateEmail,
          decoration: InputDecoration(
              labelText: AppTranslations.of(context).text("email")),
          keyboardType: TextInputType.emailAddress,
          onSaved: (String val) {
            _checkuser(val);
          },
        ),

        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: DropdownButton<String>(
            isExpanded: true,
            value: widget.customer.location,
            hint:
            Text(AppTranslations.of(context).text("location")),
            items: _locations.map((var value) {
              return new DropdownMenuItem<String>(
                value:
                LANG=="en"?
                value['name_en']:value["name_ar"],
                child: LANG=="en"?new Text(value['name_en']):new Text(value['name_ar']),
              );
            }).toList(),
            onChanged: (String val) {
              setState(() {
                widget.customer.location = val;
              });

              print(val);
            },
          ),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Radio(
              value: 0,
              groupValue: _radioValue1,
              activeColor: primaryColor,
              onChanged: _handleRadioValueChange1,
            ),
            new Text(
              AppTranslations.of(context).text("male"),
              style: new TextStyle(fontSize: 16.0),
            ),
            Padding(
              padding: EdgeInsets.all(20),
            ),
            new Radio(
              value: 1,
              activeColor: primaryColor,
              groupValue: _radioValue1,
              onChanged: _handleRadioValueChange1,
            ),
            new Text(
              AppTranslations.of(context).text("female"),
              style: new TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),

        TextFormField(
          decoration: InputDecoration(
              labelText: AppTranslations.of(context).text("age")),
          keyboardType: TextInputType.number,
          onSaved: (String val) {
            widget.customer.age=val;
          },
        ),


        SizedBox(
          height: 10.0,
        ),
        PlatformButton(
          context: context,
          child: Container(
              height: 50.0,
              width: 260.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Text(
                    AppTranslations.of(context).text("register"),
                    style: TextStyle(color: Colors.white),
                  )
                ],
              )),
          padding: EdgeInsets.all(0.0),
          color: Colors.teal,
          onPressed: _validateInputs,
        )
      ],
    );
  }

  _getCities() {
    setState(() {
      _isLoading = true;
    });
    httpGet(SERVERURL + "doctors/cities").then((res) async {
      setState(() {
        _isLoading = false;
      });
      print("getCities " + res.toString());

      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success
        setState(() {
          _locations = resJson['cities'];
        });
      } else {
        //       failed
        _scaffoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red, content: Text(resJson['message'])));
      }
    }).catchError((error) {
//    connection error
      print("_getCities error " + error.toString());
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return AppTranslations.of(context).text("valid_email");
    else
      return null;
  }

  void _checkuser(String email) {
    widget.customer.email = email;
    httpPost(SERVERURL + "customer/checkuser", json.encode(widget.customer))
        .then((res) {
      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success validate otp
        _sendOTP();
      } else if (resJson['result'] == 0) {
        _scaffoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(AppTranslations.of(context).text("user_exists") +
                " " +
                widget.customer.email)));
      }
    }).catchError((error) {
      _scaffoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(AppTranslations.of(context).text("connection_error"))));
    });
  }

  _sendOTP() {
    if(widget.customer.phone.toString().startsWith("9665") && widget.customer.phone.toString().length==12) {
      httpPost(SERVERURL + "customer/otp", json.encode(widget.customer))
          .then((res) async {
        var resJson = json.decode(res);
        if (resJson['result'] == 1) {
          // otp sent
          Route route =
          MaterialPageRoute(builder: (context) => OTPPage(widget.customer));
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
    else{
      _scaffoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
          Text(AppTranslations.of(context).text("valid_num"))));
    }
  }
}
