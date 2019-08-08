import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:async/async.dart';
//import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dto/customer.dart';
import 'package:kafy/review.dart';
import 'dto/doctor.dart';
import 'currentLocation.dart';
import 'utility.dart';
import 'utility/hero_route.dart';
import 'utility/platform_widget.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:audio_recorder2/audio_recorder2.dart';

//import 'package:map_view/map_view.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Im;
import 'localization/app_translations.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ChatScreenDrawer extends StatefulWidget {
  Customer customer;
  var booking;
  Doctor _doctor;

  ChatScreenDrawer({this.customer, this.booking});

  @override
  _ChatScreenDrawerState createState() => _ChatScreenDrawerState();
}

class _ChatScreenDrawerState extends State<ChatScreenDrawer> {
  static const platform = const MethodChannel('zadip.flutter.io/map');
  bool _isLoading;
//   Doctor _doctor = Doctor.fromJson({});
// Get battery level.
  String _userLoc = 'Unknown Location.';

  Future<Null> _getLocation(_context) async {
    String location;
    try {
//      final String result = await platform.invokeMethod('getLocation');
//      print(result);
//      CUSTOMER.latLng = result;
//      location = '$result';
    print(widget._doctor);
//      Route route = MaterialPageRoute(
//          builder: (_context) => Review(widget._doctor, widget.booking));
//      Navigator.push(_context, route);

      Route route=MaterialPageRoute(builder: (_context)=> currentLocation(doctor: widget._doctor,booking: widget.booking,));
      Navigator.push(_context, route);


    } on PlatformException catch (e) {
      location = "Failed to get location: '${e.message}'.";
    }
  }

  final TextEditingController _textController = new TextEditingController();
  final TextEditingController reasonController = new TextEditingController();

  bool _isComposing = false;
  bool _isShowcase = false;
  bool isRecording = false;
  String _recordTime = "00:00";
  Stopwatch _stopwatch;
  ScrollController _scrollController = new ScrollController();

  // Demonstrates configuring the database directly
  final FirebaseDatabase database = new FirebaseDatabase();

  var reference;
  var _uploadingMedia = [];

//  MapView _mapView;

  var compositeSubscription = new CompositeSubscription();
  var markers = [];


  Future getImage() async {

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    File compressedFile = await FlutterNativeImage.compressImage(image.path,
        quality: 50, percentage: 20);

    if (image == null) return;

    int random = new Random().nextInt(100000);

    var msg = {
      'message': random,
      'imageUrl': "uploading",
      'audioUrl': "",
      'receiver': widget.booking['doctor_id'], //change to doctor UID
      'sender': true,
      'senderPhotoUrl': widget.customer.photoUrl
    };
    database.reference().child('chats/${widget.booking['id']}/messages').push().set(msg);

    var fileName = basename(compressedFile.path);

    var downloadUrl =
    await _upload(compressedFile, random.toString() + "." + fileName.split(".")[1]);
    _updateImage(imageUrl: downloadUrl, messageId: random);
  }
//
//  static Future<void> _resizeImage(String filePath) async {
//    final file = File(filePath);
//
//    final bytes = await file.readAsBytes();
//    print("Picture original size: ${bytes.length}");
//
//    final image = Im.decodeImage(bytes);
//    final resized = Im.copyResize(image,width:60 ,height: 60);
//    final resizedBytes = Im.encodeJpg(resized, quality: 62);
//    print("Picture resized size: ${resizedBytes.length}");
//
//    await file.writeAsBytes(resizedBytes);
//  }


//  Future getImage() async {
//    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
//    final tempDir = await getTemporaryDirectory();
//    final path = tempDir.path;
//
//    if (imageFile == null) return;
//
//    int random = new Random().nextInt(100000);
//    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
//
//    var compressedImage = new File('$path/img_$random.jpg')..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
//    var msg = {
//      'message': random,
//      'imageUrl': "uploading",
//      'audioUrl': "",
//      'receiver': widget.booking['doctor_id'], //change to doctor UID
//      'sender': true,
//      'senderPhotoUrl': widget.customer.photoUrl
//    };
//    database
//        .reference()
//        .child('chats/${widget.booking["id"]}/messages')
//        .push()
//        .set(msg);
//
//    var fileName = basename(compressedImage.path);
//
//    var downloadUrl =
//    await _upload(compressedImage, random.toString() + "." + fileName.split(".")[1]);
//    _updateImage(imageUrl: downloadUrl, messageId: random);
//  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    _mapView = new MapView();
    print(widget.customer);
    getDoctor();

    // _initMap();


    reference = FirebaseDatabase.instance
        .reference()
        .child('chats/${widget.booking['id']}/messages'); //change to doctorUID

    reference.onChildAdded.listen(_onEntryAdded);

    database
        .reference()
        .child('chats/${widget.booking['id']}/messages')
        .once()
        .then((DataSnapshot snapshot) {
      print('Connected to chats database and read ${snapshot.value}');
    });

    Duration _timerDuration = new Duration(milliseconds: 500);

// Creating a new timer element.
    RestartableTimer _timer = new RestartableTimer(_timerDuration, () {
      setState(() {
        _isShowcase = true;
      });
    });
    _timer.reset();
  }


  _onEntryAdded(Event event) {
    print("${event.snapshot.key} ${event.snapshot.value}");

    if (event.snapshot.value['imageUrl'] == 'uploading') {
      String data = '{"id":"' +
          event.snapshot.value['message'].toString() +
          '","messageId":"' +
          event.snapshot.key +
          '"}';
      var jsonData = json.decode(data);
      _uploadingMedia.add(jsonData);
    } else if (event.snapshot.value['audioUrl'] == 'uploading') {
      String data = '{"id":"' +
          event.snapshot.value['message'].toString() +
          '","messageId":"' +
          event.snapshot.key +
          '"}';
      var jsonData = json.decode(data);
      _uploadingMedia.add(jsonData);
    }

    Duration _timerDuration = new Duration(seconds: 1);

// Creating a new timer element.
    RestartableTimer _timer = new RestartableTimer(_timerDuration, () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    _timer.reset();
  }

// audio recorder
  var _startTime;

  _onTapDown(TapDownDetails details) async {
    _startTime = new DateTime.now().millisecondsSinceEpoch;
    try {
//      bool hasPermissions = await AudioRecorder2.hasPermissions;

// Get the state of the recorder
      setState(() {
        isRecording = true;
      });

      _stopwatch = new Stopwatch();
      _stopwatch.start();

      new Timer.periodic(new Duration(milliseconds: 1000), _updateTime);

// Start recording
      io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
      int random = new Random().nextInt(100000);

      var path = appDocDirectory.path + '/' + random.toString() + ".aac";
//      await AudioRecorder2.start(
//          path: path, audioOutputFormat: AudioOutputFormat.AAC);
    } catch (e) {
      print(e.toString());
    }
  }

  _transformMilliSeconds(int milliseconds) {
    //Thanks to Andrew
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      var milliseconds = _stopwatch.elapsedMilliseconds;
      int hundreds = (milliseconds / 10).truncate();
      int seconds = (hundreds / 100).truncate();
      int minutes = (seconds / 60).truncate();
      setState(() {
        _recordTime = _transformMilliSeconds(_stopwatch.elapsedMilliseconds);
        if (seconds > 59) {
          seconds = seconds - (59 * minutes);
          seconds = seconds - minutes;
        }
      });
    }
  }


//  _onTapUp(TapUpDetails details) async {
//    Recording recording = await AudioRecorder2.stop();
//    print(
//        "Path : ${recording.path},  Format : ${recording.audioOutputFormat},  Duration : ${recording.duration},  Extension : ${recording.extension},");
//    var time = new DateTime.now().millisecondsSinceEpoch;
//
//    var holdTime = time - _startTime;
//    setState(() {
//      isRecording = false;
//    });
//    _stopwatch.stop();
//
//    print("$holdTime seconds");
//    if (holdTime < 5000) {
////      cancel
//    } else {
////      saveAudio
//      LocalFileSystem localFileSystem = LocalFileSystem();
////      var recording = await AudioRecorder2.stop();
//      print("Stop recording: ${recording.path}");
//      File file = localFileSystem.file(recording.path);
//      int random = new Random().nextInt(100000);
//      var msg = {
//        'message': random,
//        'imageUrl': "",
//        'audioUrl': "uploading",
//        'receiver': widget.doctor.id, //change to doctor UID
//        'sender': true,
//        'senderPhotoUrl': widget.doctor.photoUrl
//      };
//      database
//          .reference()
//          .child('chats/${widget.booking["id"]}')
//          .push()
//          .set(msg);
//
//      var fileName = basename(file.path);
//
//      var downloadUrl =
//          await _upload(file, random.toString() + "." + fileName.split(".")[1]);
//      _updateAudio(audioUrl: downloadUrl.toString(), messageId: random);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      new Scaffold(
        appBar: AppBar(
          title: Text(AppTranslations.of(context).text("chat")),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 10.0),
          child: Column(children: <Widget>[
//          _FrontLayer(),
            new Flexible(
              child: FirebaseAnimatedList(
                  query: reference,
                  controller: _scrollController,
                  itemBuilder: (context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return new ChatMessage(
                        snapshot: snapshot, animation: animation);
                  }),
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(context),
            ),
          ]),
        ),
      ),
      Stack(
        children: <Widget>[
          Container(
            height: 100.0,
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 100.0,
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: ClipOval(
                          child: FloatingActionButton(
                              child: Icon(Icons.arrow_forward),
                              onPressed: () {
                                print("working");
                                Navigator.push(
                                    context,
                                    HeroDialogRoute(
                                        builder: (BuildContext context) => Center(
                                          child: AlertDialog(
                                            contentPadding: EdgeInsets.all(10.0),
                                            content: Container(
                                              child: Hero(
                                                  tag: 'hero1',
                                                  child: Container(
                                                    height: 120.0,
                                                    width: 120.0,
                                                    color: Colors.white,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        PlatformButton(
                                                            context: context,
                                                            onPressed: () {

//                                                               Navigator.of(
//                                                                       context)
//                                                                   .pop();
                                                              _getLocation(
                                                                  context);
//                                                            _mapView.show(
//                                                                new MapOptions(
//                                                                    mapViewType:
//                                                                        MapViewType
//                                                                            .normal,
//                                                                    showUserLocation: true,
//                                                                    showMyLocationButton: true,
//                                                                    showCompassButton: true,
//                                                                    initialCameraPosition: new CameraPosition(new Location(24.526607443935724, 46.66731660813093), 15.0),
//                                                                    hideToolbar: false,
//                                                                    title: "Recently Visited"),
//                                                                toolbarActions: [
//                                                                  new ToolbarAction(
//                                                                      "OK", 1)
//                                                                ]);
                                                            },
                                                            child:
                                                            Text( AppTranslations.of(context).text("book_now"))),
                                                        PlatformButton(
                                                            context: context,
                                                            onPressed: () {
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (_) => new AlertDialog(
                                                                    title: new Text( AppTranslations.of(context).text("Confirmation")),
                                                                    content: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: <Widget>[
                                                                        Text(
                                                                    AppTranslations.of(context).text("enter_reason")),
                                                                        Padding(
                                                                          padding: EdgeInsets.all(10),
                                                                        ),
                                                                        new TextField(
                                                                          controller: reasonController,
                                                                          maxLines: 3,
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
                                                                                  rejectBooking(
                                                                                      widget.booking['id']
                                                                                          .toString(),
                                                                                      reasonController
                                                                                          .text,context);
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
                                                                  ));


                                                            },
                                                            child: Text(
                                                              AppTranslations.of(context).text("Cancel"),
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.red),
                                                            ))
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        )));
                              }),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
      _isShowcase
          ? GestureDetector(
        onTap: () {
          setState(() {
            _isShowcase = false;
          });
        },
        child: Container(
            color: Colors.black54,
            child: Column(
              children: <Widget>[
                Container(
                    color: Colors.transparent,
                    height: 100.0,
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            onPressed: null,
                            child: Icon(Icons.arrow_forward),
                          ),
                        ])),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    "click this to book an appointment after confirmation",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )),
      )
          : Container(),
      isRecording
          ? Material(
          color: Colors.transparent,
          child: Center(child: Container(child: Text(_recordTime))))
          : Container()
    ]);



}
  void rejectBooking(String bookingId, String reason,BuildContext context) {
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
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();

//        scaffoldState.currentState.showSnackBar(
//            SnackBar(backgroundColor: Colors.green, content: Text("Rejected")));

//        getBookings();
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

  void sendMessagedoc(String bookingId, String name,String message) {


    httpPost(SERVERURL + "customer/sendMessageDoc",
        json.encode({"bookingId": bookingId, "name": name,"message":message})).then((res) async {

      var resJson = json.decode(res);
      print("message sending");
      print(res);
      if (resJson['result'] == 1) {

//        scaffoldState.currentState.showSnackBar(
//            SnackBar(backgroundColor: Colors.green, content: Text("Rejected")));

//        getBookings();
      } else {
        //verification failed
//        SnackBar(backgroundColor: Colors.red, content: Text("Error"));
      }
    }).catchError((error) {
//    connection error
      setState(() {
      });
      print("message error");
      print(error);
//      SnackBar(
//          backgroundColor: Colors.red,
//          content:
//          Text(AppTranslations.of(context).text("connection_error")));
    });
  }




  _initMap() {
//    _mapView.onToolbarAction.listen((id) {
//      if (id == 1) {
////closed
//        _mapView.dismiss();
//        print("user location ${markers[0].latitude} ${markers[0].longitude}");
//      }
//    });
//
//    _mapView.onMapTapped.listen((location) {
//      markers.forEach((marker) {
//        _mapView.removeMarker(marker);
//      });
//      markers.clear();
//      Marker marker = new Marker(
//          "3", "10 Barrel", location.latitude, location.longitude,
//          color: primaryColor);
//
//      markers.add(marker);
//      _mapView.addMarker(marker);
//    });
  }

  Widget _buildTextComposer(context) {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.photo_camera),
                  onPressed: () async {
                    getImage();
                  }),
            ),
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintText:
                    AppTranslations.of(context).text("send_a_message")),
              ),
            ),
            // GestureDetector(
            //   onTap: () => print('tapped!'),
            //   onTapDown: (TapDownDetails details) => _onTapDown(details),
            //   onTapUp: (TapUpDetails details) => _onTapUp(details),
            //   child: IconButton(icon: Icon(Icons.mic), onPressed: null),
            // ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                  child: new Text("Send"),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )
                    : new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
              border:
              new Border(top: new BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  Future<Null> _handleSubmitted(String text) async {

    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    _sendMessage(text: text);
    sendMessagedoc(widget.booking['id'].toString(), CUSTOMER.name, text);

  }

  void _sendMessage({String text, String imageUrl, String audioUrl}) {
    var msg = {
      'message': text != null ? text : "",
      'imageUrl': imageUrl != null ? imageUrl : "",
      'audioUrl': audioUrl != null ? audioUrl : "",
      'receiver': widget.booking['doctor_id'], //change to doctor UID
      'sender': true,
      'senderPhotoUrl': widget.customer.photoUrl
    };
    database.reference().child('chats/${widget.booking['id']}/messages').push().set(msg);
  }

  void _updateImage({int messageId, String imageUrl}) {
    var msg = {
      'message': "",
      'imageUrl': imageUrl != null ? imageUrl : "",
      'audioUrl': "",
      'receiver': widget.booking['doctor_id'], //change to doctor UID
      'sender': true,
      'senderPhotoUrl': widget.customer.photoUrl
    };

    for (var value in _uploadingMedia) {
      print("${value["id"]} $messageId");
      if (value["id"] == messageId.toString()) {
        print("${value["messageId"]}");
        database
            .reference()
            .child('chats/${widget.booking['id']}/messages/${value["messageId"]}')
            .set(msg);
        break;
      }
    }
  }

  void _updateAudio({int messageId, String audioUrl}) {
    var msg = {
      'message': "",
      'imageUrl': "",
      'audioUrl': audioUrl != null ? audioUrl : "",
      'receiver': widget.booking['doctor_id'], //change to doctor UID
      'sender': true,
      'senderPhotoUrl': widget.customer.photoUrl
    };

    for (var value in _uploadingMedia) {
      print("${value["id"]} $messageId");
      if (value["id"] == messageId.toString()) {
        print("${value["messageId"]}");
        database
            .reference()
            .child('chats/${widget.booking['id']}/${value["messageId"]}')
            .set(msg);
        break;
      }
    }
  }

  Future<String> _upload(File imageFile, String fileName) async {
    String responseStr = "";
    var stream =
    new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(SERVERURL + "bookings/upload");

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile =
    new http.MultipartFile('file', stream, length, filename: fileName);
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    await response.stream.transform(utf8.decoder).listen((value) {
      print(value);
      var resJson = json.decode(value);
      if (resJson["result"] == 1) {
//        success
        responseStr = resJson["message"].toString();
      } else {
//        failed
      }
    }).asFuture();
    return responseStr;
  }
  void getDoctor() {
    setState(() {
      _isLoading = true;
    });

    httpGet(SERVERURL + "doctors/data/${widget.booking['doctor_id']}").then((res) async {
      setState(() {
        _isLoading = false;
      });
      var resJson = json.decode(res);
      print("doctor data ");
      print(resJson['doctor']);
      if (resJson['result'] == 1) {
        // otp verified
        widget._doctor = Doctor.fromJson(resJson['doctor']);
        print(widget._doctor.name);
      } else {
        //verification failed
//        SnackBar(
//            backgroundColor: Colors.red,
//            content: Text(AppTranslations.of(context).text("invalid_otp")));
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

class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});

  final DataSnapshot snapshot;
  final Animation animation;

  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: Row(
          mainAxisAlignment: snapshot.value['receiver'] != CUSTOMER.id
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 250.0,
              alignment: LANG == "ar"
                  ? (snapshot.value['receiver'] != CUSTOMER.id
                  ? Alignment.topLeft
                  : Alignment.topRight)
                  : (snapshot.value['receiver'] != CUSTOMER.id
                  ? Alignment.topRight
                  : Alignment.topLeft),
              padding: EdgeInsets.all(10.0),
              margin: const EdgeInsets.only(top: 5.0),
              child: snapshot.value["audioUrl"] != ""
                  ? Container(
                  padding: EdgeInsets.all(10.0),
                  child: snapshot.value["audioUrl"] == "uploading"
                      ? CircularProgressIndicator()
                      : IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        AudioPlayer advancedPlayer = new AudioPlayer();
                        advancedPlayer.play(
                            FILESURL + snapshot.value["audioUrl"]);
                      }),
                  color: Colors.green[200])
                  : (snapshot.value['imageUrl'] != ""
                  ? Container(
                height: 250.0,
                width: 250.0,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    snapshot.value['imageUrl'] != "uploading"
                        ? CachedNetworkImage(
                        height: 250.0,
                        width: 250.0,
                        imageUrl:
                        FILESURL + snapshot.value['imageUrl'])
                        : Container()
                  ],
                ),
              )
                  : Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(snapshot.value['message']),
                  color:snapshot.value['receiver'] != CUSTOMER.id
                      ? Colors.green[200]
                      : Colors.amber[200])),
            )
          ]),
    );
  }
}


class CompositeSubscription {
  Set<StreamSubscription> _subscriptions = new Set();

  void cancel() {
    for (var n in this._subscriptions) {
      n.cancel();
    }
    this._subscriptions = new Set();
  }

  void add(StreamSubscription subscription) {
    this._subscriptions.add(subscription);
  }

  void addAll(Iterable<StreamSubscription> subs) {
    _subscriptions.addAll(subs);
  }

  bool remove(StreamSubscription subscription) {
    return this._subscriptions.remove(subscription);
  }

  bool contains(StreamSubscription subscription) {
    return this._subscriptions.contains(subscription);
  }

  List<StreamSubscription> toList() {
    return this._subscriptions.toList();
  }
}
