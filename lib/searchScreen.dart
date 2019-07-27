import 'package:flutter/material.dart';
import 'package:kafy/dto/category.dart';
import 'package:kafy/dto/customer.dart';
import 'utility.dart';
import 'dart:convert';
import 'package:kafy/categorieslist.dart';
import 'package:kafy/doctorlist.dart';

import 'localization/app_translations.dart';

class SearchPage extends StatefulWidget{
  @override
  SearchState createState() {
    // TODO: implement createState
    return new SearchState();
  }

}

class SearchState extends State<SearchPage>
{

  final GlobalKey<ScaffoldState> _scaffoldState =
  new GlobalKey<ScaffoldState>();
  Customer _customer = Customer.fromJson({});

  // var user;
  var _categories = [];
  var categories = <Category>[];
  var _selectedCategory;

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    _getCategories();

//    _getLocation();
  }

  _getCategories() {
    httpGet(SERVERURL + "categories").then((res) async {
      print("_getCategories " + res.toString());

      var resJson = json.decode(res);
      if (resJson['result'] == 1) {
        // success
        _categories = resJson['categories'];

        _categories.forEach((category) {
          categories.add(Category.fromJson(category));
        });
        print(categories[0].name_en);
      } else {
        //       failed
        _scaffoldState.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red, content: Text(resJson['message'])));
      }
    }).catchError((error) {
//    connection error
      print("_getCategories error " + error.toString());
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Padding(
        padding: EdgeInsets.all(20.0),
        child: Container(
          height: double.infinity,
          child: Column(
            children: [
              Image.asset(
                "resources/images/kafy_logo.png",
                height: 200.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        padding: EdgeInsets.all(0.0),
                        color: Colors.teal,
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => CategoryList()
                            ),
                          );
                          print(result);

                          print("onTap called. $result");

                          setState(() {
                            if (result != null) _selectedCategory = result;
                          });
                        },
                        child: Container(
                          height: 50.0,
                          width: 200.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            verticalDirection: VerticalDirection.down,
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(10.0)),
                              Text(
                                _selectedCategory != null
                                    ? LANG == "en"
                                    ? _selectedCategory['name_en']
                                    : _selectedCategory['name_ar']
                                    : AppTranslations.of(context).text("select_category"),
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 50.0,
                        width: 50.0,
                        padding: EdgeInsets.all(0.0),
                        color: primaryGrey,
                        child: IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.search),
                            onPressed: () {
                              if (_selectedCategory != null) {
                                Route route = MaterialPageRoute(
                                    builder: (context) => DoctorList(
                                        selectedCategory: _selectedCategory));
                                Navigator.push(context, route);
                              } else {
                                print("select category");
                                _scaffoldState.currentState.showSnackBar(
                                    SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            AppTranslations.of(context).text("select_category"))));
                              }
                            }),
                      )
                    ],
                  ),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  FlatButton(
//                      onPressed: () {},
//                      child: Text(
//                        'Riyadh',
//                        style: TextStyle(color: primaryColor),
//                      )),
//                  IconButton(
//                      icon: Icon(
//                        Icons.my_location,
//                        color: primaryColor,
//                      ),
//                      onPressed: _getLocation)
//                ],
//              )
                ],
              )
            ],
          ),
        )
    );
  }



}