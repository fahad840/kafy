import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kafy/booking_result.dart';
import 'package:kafy/dto/customer.dart';
import 'package:kafy/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kafy/register.dart';
import 'package:kafy/registermobile.dart';
import 'package:kafy/utility.dart';
import 'package:kafy/landingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'localization/app_translations_delegate.dart';
//import 'package:map_view/map_view.dart';
import 'localization/application.dart';
import 'localization/app_translations.dart';


//final ThemeData kIOSTheme = new ThemeData(
//    primaryColor: Colors.grey[100],
//    primarySwatch: Colors.orange,
//    accentColor: Colors.teal,
//    primaryColorBrightness: Brightness.light);\

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.teal,
  accentColor: Colors.amber[400],
    fontFamily: 'Cairo'

);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.teal,
  accentColor: Colors.amber[400],
    fontFamily: 'Cairo'

);

SharedPreferences prefs;
MediaQueryData queryData;

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  AppTranslationsDelegate _newLocaleDelegate;
  Locale locale;

@override
  void initState() {
    // TODO: implement initState
  _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
  application.onLocaleChanged = onLocaleChange;


  super.initState();
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }

  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Kafy',
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (this.locale == null) {
           this.locale = Locale('ar');
          print(deviceLocale);
        }
        return this.locale;
      },
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        AppTranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales:
        application.supportedLocales()// Arabic
        // ... other locales the app supports
      ,
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        '/Home': (BuildContext context) => new Home(),
        '/result': (BuildContext context) => new BookingResult()
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final GlobalKey<ScaffoldState> _scafoldState = new GlobalKey<ScaffoldState>();

  Customer _customer = Customer.fromJson({});

  bool isLoading = false;
  var _deviceToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseCloudMessaging_Listeners();



    try {
      _googleSignIn.signOut();
    } catch (e) {}
    _getUser(context);

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      print(account);

      // if (_currentUser != null) {
      //   _handleGetContact();
      // }
    });
    // _googleSignIn.signInSilently();
  }
  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      print(token);
      CUSTOMER.deviceToken=token;

    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }


  Future loginMobile(BuildContext context, phone) async {
    if(phone.toString().startsWith("9665") && phone.toString().length==12) {
      _customer.phone = phone;
      setState(() {
        isLoading = true;
      });
      httpPost(SERVERURL + "customer/login", json.encode(_customer.toJson()))
          .then((res) async {
        setState(() {
          isLoading = false;
        });
        var resJson = json.decode(res);
        print(resJson);
        if (resJson['result'] == 1) {
//login success
          _customer = Customer.fromJson(resJson['customer']);
          CUSTOMER = _customer;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user', json.encode(resJson['customer']));
          Route route = MaterialPageRoute(builder: (context) => Home());
          Navigator.pushReplacement(context, route);
        } else {
//      new user go to register
          Route route = MaterialPageRoute(
              builder: (context) => RegisterMobilePage(_customer));
          Navigator.push(context, route);
        }
      }).catchError((error) {
//    connection error
        print("loginMobile error " + error.toString());
        setState(() {
          isLoading = false;
        });
        _scafoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content:
            Text(AppTranslations.of(context).text("connection_error"))));
      });

    }


    else{
      _scafoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
          Text(AppTranslations.of(context).text("valid_num"))));
    }
  }

  @override
  Widget build(BuildContext context) {
    var textController = new TextEditingController();

    return Scaffold(
        key: _scafoldState,
        body: Stack(
          children: <Widget>[
            Container(
              color: primaryColor,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                        width: 380.0,
                        color: primaryColor,
                        child: Image.asset(
                          "resources/images/kafy_logo_white.png",
                        )),
                    flex: 6,
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextField(
                            controller: textController,
                            keyboardType: TextInputType.phone,
                            inputFormatters:[
                              LengthLimitingTextInputFormatter(12),
                            ],
                            decoration: new InputDecoration(
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.teal)),
                                hintText: '966500000000',
                                labelText: AppTranslations.of(context).text("mobile_number"),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                ),
                                suffix: IconButton(
                                    icon: Icon(Icons.arrow_right),
                                    color: Colors.green,
                                    onPressed: () {
                                      loginMobile(context, replaceArabicNumber(textController.text));
                                    }),
                                suffixStyle:
                                    const TextStyle(color: Colors.green)),
                          ),
                          Padding(padding: EdgeInsets.all(10.0)),
                          Row(
                            children: <Widget>[
                              FlatButton(
                                padding: EdgeInsets.all(15.0),
                                color: color_google,
                                onPressed: _gmailLogin,
                                splashColor: Colors.white,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.google,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                    Text(
                                      AppTranslations.of(context).text("g_login"),
                                      style: TextStyle(color: Colors.white ,fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(10.0)),
                              FlatButton(
                                padding: EdgeInsets.all(15.0),
                                color: color_fb,
                                onPressed: () {
                                 // _fbLogin();
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.facebook,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                    Text(
                                      AppTranslations.of(context).text("fb_login",),
                                      style: TextStyle(color: Colors.white,fontSize: 10),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            isLoading == true
                ? Container(
                    color: Colors.black45,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container()
          ],
        ));
  }

  _gmailLogin() async {
    // _googleSignIn.signOut();
    try {
      GoogleSignInAccount user = await _googleSignIn.signIn();
      print(user);
      _customer.email = user.email;

      _customer.name = user.displayName;
      _customer.photoUrl = user.photoUrl;
      checkEmail();
    } catch (error) {
      print("err " + error);
    }
  }

//  _fbLogin() async {
//    var facebookLogin = new FacebookLogin();
//    var result = await facebookLogin.logInWithReadPermissions(['email']);
//
//    switch (result.status) {
//      case FacebookLoginStatus.loggedIn:
//        print(result.accessToken.token);
//        httpGet('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${result.accessToken.token}')
//            .then((graphRes) {
//          var profile = json.decode(graphRes);
//          _customer.email = profile['email'];
//          _customer.name = profile['name'];
//          checkEmail();
//        });
//
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        // _showCancelledMessage();
//        break;
//      case FacebookLoginStatus.error:
//        print(result.errorMessage);
//        // _showErrorOnUI(result.errorMessage);
//        break;
//    }
//  }

  void checkEmail() {
    setState(() {
      isLoading = true;
    });
    httpPost(SERVERURL + "customer/check", json.encode(_customer))
        .then((res) async {
      setState(() {
        isLoading = false;
      });
      var resJson = json.decode(res);

      if (resJson['result'] == 1) {
//existing user
        prefs = await SharedPreferences.getInstance();
//        resJson['customer']['photoUrl'] = user.photoUrl;
        prefs.setString('user', json.encode(resJson['customer']));
        _customer = Customer.fromJson(resJson['customer']);
        CUSTOMER = _customer;
        Route route = MaterialPageRoute(builder: (context) => Home());
        Navigator.pushReplacement(context, route);
      } else {
//      user not found navigate to registration
        Route route =
            MaterialPageRoute(builder: (context) => RegisterPage(_customer));
        Navigator.push(context, route);
      }
    }).catchError((error) {
//    connection error
      print("loginMobile error " + error.toString());
      setState(() {
        isLoading = false;
      });
      _scafoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(AppTranslations.of(context).text("connection_error"))));
    });
  }
}

// _auth.signOut();
// _googleSignIn.signOut();
// try {
//   GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//   GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//   _auth
//       .signInWithGoogle(
//     accessToken: googleAuth.accessToken,
//     idToken: googleAuth.idToken,
//   )
//       .then((result) {
//     if (result.providerData.length > 1)
//       _saveUser(result, result.providerData[1].email);
//     else
//       _saveUser(result, result.providerData[0].email);
//   }).catchError((err) {
//     print(err);
//   });
// } catch (e) {
//   print(e);
// }
//  }

// void _fbLogin() {
//     // _auth.signOut();
//     // facebookLogin.logOut();
//     var facebookLogin = new FacebookLogin();

//     facebookLogin.logInWithReadPermissions(['email']).then((result) {
//       switch (result.status) {
//         case FacebookLoginStatus.loggedIn:
//           print(result);
//           _auth
//               .signInWithFacebook(accessToken: result.accessToken.token)
//               .then((user) {
//             if (user.providerData.length > 1)
//               checkEmail(user, user.providerData[1].email);
//             else
//               checkEmail(user, user.providerData[0].email);
//           }).catchError((e) {
//             _scafoldState.currentState.showSnackBar(SnackBar(
//               backgroundColor: Colors.red,
//               content: new Text(e.toString()),
//             ));
//           });

//           break;
//         case FacebookLoginStatus.cancelledByUser:
//           print(result.status);
//           break;
//         case FacebookLoginStatus.error:
//           print("error ${result.errorMessage}");
//           _scafoldState.currentState.showSnackBar(SnackBar(
//               backgroundColor: Colors.red,
//               content: Text("" + result.errorMessage)));

//           break;
//       }
//     });
//   }
String replaceArabicNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  for (int i = 0; i < farsi.length; i++) {
    input = input.replaceAll(farsi[i], english[i]);
  }

  return input;
}

_getUser(context) async {
  prefs = await SharedPreferences.getInstance();
  String user = prefs.getString("user");
  if (user != null) {
  CUSTOMER = Customer.fromJson(json.decode(user));
    Route route = MaterialPageRoute(builder: (context) => Home());
    Navigator.pushReplacement(context, route);
  }
}
