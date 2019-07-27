import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kafy/utility.dart';

class LocalizationHelper {
  LocalizationHelper(this.locale);

  final Locale locale;

  static LocalizationHelper of(BuildContext context) {
    return Localizations.of<LocalizationHelper>(context, LocalizationHelper);
  }

  Map<String, String> _sentences;

  Future<bool> load() async {
    String data = await rootBundle
        .loadString('resources/lang/${this.locale.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }

  String trans(String key) {
    return this._sentences[key];
  }
}

class LocalizationDel extends LocalizationsDelegate<LocalizationHelper> {
  const LocalizationDel();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<LocalizationHelper> load(Locale locale) async {
    LocalizationHelper localizations = new LocalizationHelper(locale);
    await localizations.load();

    print("Load ${locale.languageCode}");

    LANG = locale.languageCode;

    return localizations;
  }

  @override
  bool shouldReload(LocalizationDel old) => false;
}
