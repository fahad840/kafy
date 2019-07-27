import 'package:flutter/material.dart';
import 'package:kafy/dto/filterdata.dart';
import 'package:kafy/dto/filterparam.dart';
import 'package:kafy/localization.dart';
import 'package:kafy/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';
import 'localization/app_translations.dart';

// import 'package:kafy/utility/customslider.dart';

class AddEntryDialog extends StatefulWidget {
  FilterData filterData;
  FilterParam filterParam;

  AddEntryDialog({this.filterData, this.filterParam});

  @override
  AddEntryDialogState createState() => new AddEntryDialogState();
}

class AddEntryDialogState extends State<AddEntryDialog> {
  bool checkBoxValue = false;

  // var gender = [
  //   {'gender_en': 'Male', 'gender_ar': 'MaleAr', 'checked': false},
  //   {'gender_en': 'Female', 'gender_ar': 'FemaleAr', 'checked': false}
  // ];

  double _distance = 40.0;
  // var cost = {'min': 100.0, 'max': 500.0};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (widget.filterData != null) gender = widget.filterData;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        title: Text(AppTranslations.of(context).text("filter")),
        actions: [
          new FlatButton(
              onPressed: () {
                //TODO: Handle save

//                Navigator.pop(context, gender);
                Navigator.of(context).pop(widget.filterData);
              },
              child: new Text('SAVE',
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: Column(
        children: <Widget>[
          header(AppTranslations.of(context).text("gender")),
          CheckboxListTile(
              activeColor: primaryColor,
              title: Text(AppTranslations.of(context).text("male")),
              value: widget.filterData.male,
              onChanged: (val) {
                setState(() {
                  widget.filterData.male = val;
                });
              }),
          CheckboxListTile(
              activeColor: primaryColor,
              title: Text(AppTranslations.of(context).text("female")),
              value: widget.filterData.female,
              onChanged: (val) {
                setState(() {
                  widget.filterData.female = val;
                });
              }),
          header(
              "${AppTranslations.of(context).text("max_distance")} ${_distance.floor()} KM"),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Slider(
                min: 0.0,
                max: 100.0,
                value: _distance,
                divisions: 100,
                onChanged: (newValue) {
                  setState(() {
                    _distance = newValue;
                  });
                }),
          ),
          header(
              "${AppTranslations.of(context).text("min_experience")} ${widget.filterData.experience} years"),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Slider(
                min: widget.filterParam.minExperience.toDouble(),
                max: widget.filterParam.maxExperience.toDouble(),
                value: widget.filterData.experience.toDouble(),
                divisions: 40,
                onChanged: (newValue) {
                  setState(() {
                    widget.filterData.experience = newValue.toInt();
                  });
                }),
          ),
          header(
              "${AppTranslations.of(context).text("cost")} ${widget.filterData.minCost} - ${widget.filterData.maxCost} SAR"),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: new RangeSlider(
              min: widget.filterParam.minCost.toDouble(),
              max: widget.filterParam.maxCost.toDouble(),
              lowerValue: widget.filterData.minCost.toDouble(),
              upperValue: widget.filterData.maxCost.toDouble(),
              divisions: 400,
              showValueIndicator: true,
              valueIndicatorMaxDecimals: 0,
              onChanged: (double newLowerValue, double newUpperValue) {
                setState(() {
                  widget.filterData.minCost = newLowerValue.toInt();
                  widget.filterData.maxCost = newUpperValue.toInt();
                });
              },
              onChangeStart: (double startLowerValue, double startUpperValue) {
                print(
                    'Started with values: $startLowerValue and $startUpperValue');
              },
              onChangeEnd: (double newLowerValue, double newUpperValue) {
                print('Ended with values: $newLowerValue and $newUpperValue');
              },
            ),
          )
        ],
      ),
    );
  }
}

Widget header(String headerText) {
  return Container(
    color: Colors.grey[300],
    width: double.infinity,
    padding: EdgeInsets.all(10.0),
    child: Text(headerText),
  );
}
