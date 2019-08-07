import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kafy/doctor_filter.dart';

//import 'package:kafy/doctor_filter.dart';
import 'package:kafy/doctor_profile.dart';
import 'package:kafy/dto/customer.dart';
import 'package:kafy/dto/doctor.dart';
import 'package:kafy/dto/filterdata.dart';
import 'package:kafy/dto/filterparam.dart';
import 'package:kafy/localization.dart';
import 'package:kafy/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'localization/app_translations.dart';

class DoctorList extends StatefulWidget {
  var selectedCategory;


  DoctorList({this.selectedCategory});

  @override
  DoctorListState createState() {
    return new DoctorListState();
  }
}

class DoctorListState extends State<DoctorList> {
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  FilterData _filterData = FilterData.fromJson({});

  FilterParam _filterParam = FilterParam.fromJson({});

//  List<Doctor> doctors;
  var _doctors = [];
  var _filteredDoctors = [];
  bool _isLoading = false;

  var status = "Loading";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _filterData.male = false;
    _filterData.female = false;
    _getDoctors();
  }

  _getDoctors() {
    _isLoading = true;
    httpGet(SERVERURL + "doctors/category/${widget.selectedCategory['id']}")
        .then((res) async {
      _isLoading = false;

      print("_getDoctors " + res.toString());

      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success

        print(resJson['doctors']);
        _filterParam.minExperience = 0;
        _filterParam.maxExperience = 0;
        for (var doctorJSON in resJson['doctors']) {
          Doctor doctor = Doctor.fromJson(doctorJSON);
          _doctors.add(doctor);
          _filteredDoctors = _doctors;

          print(doctor.name);
          if (_filterParam.minCost == null)
            _filterParam.minCost = int.parse(doctor.fee);
          if (_filterParam.maxCost == null)
            _filterParam.maxCost = int.parse(doctor.fee);
          if (_filterParam.minCost > int.parse(doctor.fee)) {
            _filterParam.minCost = int.parse(doctor.fee);
          }
          if (_filterParam.maxCost < int.parse(doctor.fee)) {
            _filterParam.maxCost = int.parse(doctor.fee);
          }
          if (doctor.experience <= _filterParam.minExperience) {
            _filterParam.minExperience = doctor.experience;
          }
          if (doctor.experience >= _filterParam.maxExperience) {
            _filterParam.maxExperience = doctor.experience;
          }
        }
        setState(() {
          _filteredDoctors = _doctors;
          if (_filteredDoctors.isEmpty) status = "No Data";
        });
        _filterData.minCost = _filterParam.minCost;
        _filterData.maxCost = _filterParam.maxCost;
        _filterData.experience = _filterParam.minExperience;
      } else {
        //       failed
        _scaffoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red, content: Text(resJson['message'])));
      }
    }).catchError((error) {
      setState(() {
        status = "No Connection";
        _isLoading = false;
      });

//    connection error
      print("_getDoctors error " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.filter),
              onPressed: () async {
                if (_filterParam.minCost == null) return;

                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => AddEntryDialog(
                            filterData: _filterData,
                            filterParam: _filterParam,
                          )),
                );
                print(result);

                if (result == null) return;

                _filterData = result;

                _filteredDoctors = [];
                for (var doctor in _doctors) {
                  if ((!_filterData.male && !_filterData.female) ||
                      (_filterData.male && _filterData.female) ||
                      (_filterData.male == true && doctor.gender == "Male") ||
                      (_filterData.female == true &&
                          doctor.gender == "Female")) {
                    if (_filterData.minCost <= int.parse(doctor.fee) &&
                        int.parse(doctor.fee) <= _filterData.maxCost) {
                      if (_filterData.experience <= doctor.experience) {
                        setState(() {
                          _filteredDoctors.add(doctor);
                        });
                      }
                    }
                  }
                }
                if (_filteredDoctors.isEmpty) status = "No Data";
              })
        ],
        title: Text(LANG == "en"
            ? widget.selectedCategory['name_en']
            : widget.selectedCategory['name_ar']),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: false,
            itemBuilder: (BuildContext context, int index) => Container(
                  margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                  child: _doctorCard(index),
                ),
            itemCount: _filteredDoctors.length,
          ),
          _isLoading ? loader() : Container(),
          _filteredDoctors.isEmpty && !_isLoading
              ? Center(
                  child: Text(status),
                )
              : Container()
        ],
      ),
    );
  }

  Widget rightProfile(Doctor doctor) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            doctor.name,
            style: mainFont,
          ),
          Text("${doctor.qualification}"),
          LANG == "ar"
              ? Text("${doctor.gender} | ${doctor.experience}yrs experience")
              : Text("${doctor.gender} | ${doctor.experience}yrs experience"),
//          Text("SAR " + doctor.fee),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                LANG == "ar"
                    ? Text(
                        "${AppTranslations.of(context).text("last_seen")}: ${doctor.lastSeenStrAr}")
                    : Text(
                        "${AppTranslations.of(context).text("last_seen")}: ${doctor.lastSeenStr}")
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget leftProfile(Doctor doctor) {
    return Expanded(
      flex: 1,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            new Container(
                width:  60.0,
                height:  60.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                          doctor.photoUrl != null ? doctor.photoUrl :FILESURL + "placeholder-profile.png" ,
                        )
                    )
                )),

            Container(
              width: 60.0,
              padding: EdgeInsets.all(3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    doctor.avgRating,
                    style: TextStyle(fontSize: 13.0, color: disabledColor),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.green,
                    size: 13.0,
                  )
                ],
              ),
            ),
            Container(
              width: 60.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "${doctor.votesCount} votes",
                    style: sDisabledFont,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _doctorCard(index) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DoctorProfilePage(doctor: _filteredDoctors[index])),
          );
        },
        child: Container(
          height: 130.0,
          padding: EdgeInsets.only(top: 10.0),
          child: Row(
            children: <Widget>[
              leftProfile(_filteredDoctors[index]),
              rightProfile(_filteredDoctors[index])
            ],
          ),
        ),
      ),
    );
  }
}
