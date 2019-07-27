import 'package:flutter/material.dart';
import 'localization.dart';
import 'localization/app_translations.dart';
import 'localization/application.dart';

class languageSetting extends StatefulWidget {
  // This widget is the root of your application.
  @override
  languageState createState() {
    return new languageState();
  }
}

class languageState extends State<languageSetting> {
  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList =
      application.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text("language")),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(AppTranslations.of(context).text("select_lang"),style: TextStyle(fontSize: 18),),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text(AppTranslations.of(context).text("Arabic"),style: TextStyle(fontSize: 16),),
                  onPressed: () {
                    onLocaleChange(Locale(languagesMap["Arabic"]));
                  },
                ),
                FlatButton(
                  child: Text(AppTranslations.of(context).text("English"),style: TextStyle(fontSize: 16),),
                  onPressed: () {
                    onLocaleChange(Locale(languagesMap["English"]));
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onLocaleChange(Locale locale) async {
    setState(() {
      AppTranslations.load(locale);
    });
  }
}
