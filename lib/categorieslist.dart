import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kafy/localization.dart';
import 'package:kafy/utility.dart';
import 'package:kafy/doctorlist.dart';
import 'package:kafy/dto/customer.dart';
import 'localization/app_translations.dart';

class CategoryList extends StatefulWidget {
  Customer customer;
  CategoryList({this.customer});
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  TextEditingController controller = new TextEditingController();
  String filter;

  var _categories = [];

  _getCategories() {
    setState(() {
      _isLoading = true;
    });
    //categories/category
    httpGet(SERVERURL + "categories/category").then((res) async {
      setState(() {
        _isLoading = false;
      });
      print("_getCategories " + res.toString());

      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success
        setState(() {
          _categories = resJson['categories'];
        });
      } else {
        //       failed
        _scaffoldState.currentState.showSnackBar(SnackBar(
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

    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });

    if (_categories.isEmpty) {
      _getCategories();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text("categories")),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      key: _scaffoldState,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: new TextField(
                  enableInteractiveSelection: false,
                  decoration: new InputDecoration(
                      labelText: AppTranslations.of(context).text("search")),
                  controller: controller,
                ) ,
              )
              ,
              Expanded(
                  child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return filter == null || filter == ""
                      ? ListTile(
                          title: Text(LANG == "en"
                              ? _categories[index]['name_en']
                              : _categories[index]['name_ar']),
                          onTap: () {
                            print("tapped");
                            print("tapped ${_categories[index]['name_ar']}");

                            Route route = MaterialPageRoute(
                                builder: (context) => DoctorList(
                                    selectedCategory: _categories[index]));
                            Navigator.push(context, route);

                           // Navigator.pop(context, _categories[index]);
                          },
                        )
                      : _categories[index]['name_en']
                              .toLowerCase()
                              .contains(filter.toLowerCase())
                          ? ListTile(
                              title: Text(LANG == "en"
                                  ? _categories[index]['name_en']
                                  : _categories[index]['name_ar']),
                              onTap: () async {
                                print(
                                    "tapped ${_categories[index]['name_ar']}");
                                Navigator.pop(context, _categories[index]);
                              },
                            )
                          : new Container();
                },
              ))
            ],
          ),
          _isLoading ? loader() : Container(),
        ],
      ),
    );
  }
}
