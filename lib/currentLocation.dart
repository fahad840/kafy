import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'page.dart';
import 'dto/doctor.dart';
import 'utility.dart';
import 'review.dart';
import 'localization/app_translations.dart';
import 'package:location/location.dart';


class currentLocation extends StatefulWidget {
  var booking;
  Doctor doctor;

  currentLocation({Key key, @required this.doctor, this.booking}) : super(key: key);

  @override
  currentLoctaionState createState() {

    return new currentLoctaionState();

  }
}

class currentLoctaionState extends State<currentLocation> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _mapController;
  String result;
  var currentlocation = LocationData;

  var location = new Location();
  static final CameraPosition mylocation = CameraPosition(
    target: LatLng(24.713552, 46.675297),
    zoom: 14.4746,
  );
  Map<MarkerId, Marker> markers =
      <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS

  @override
  void initState() {
    // TODO: implement initState
    print("Hello");
    print(widget.doctor.name);
    DOCTOR=widget.doctor;
    BOOKING=widget.booking;
    _currentLocation();
    super.initState();
  }

  void _add(LatLng value) {
    var markerIdVal = "2345";
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: value,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;


    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text( AppTranslations.of(context).text("select_location")),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              print(result);
              CUSTOMER.latLng = result;
              Route route = MaterialPageRoute(
                  builder: (context) => Review());
              Navigator.push(context, route);
            },
            child: Text( AppTranslations.of(context).text("Save")),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body:Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: mylocation,
            markers: Set<Marker>.of(markers.values),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (LatLng pos) {
              setState(() {
                result = pos.latitude.toString() + "," + pos.longitude.toString();
                _add(pos);
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,

          ),
          Align(
            alignment: FractionalOffset.bottomRight,
            child: IconButton(
              iconSize: 35,
              padding: EdgeInsets.only(right: 20,bottom: 35),
                        icon: Icon(Icons.my_location),
                        onPressed: () async {
                          _currentLocation();
                        }
                    )

            ,
          )

        ],

      )



    );
  }


//  Future<void> _goToTheLake() async {
//    final GoogleMapController controller = await _controller.future;
//    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//  }

  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 17.0,
      ),
    ));
  }

  void _onMapLongTapped(LatLng location) {
    print('tapped');
    // add place marker code here
  }
}
