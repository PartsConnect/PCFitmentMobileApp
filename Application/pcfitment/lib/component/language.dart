import 'package:flutter/cupertino.dart';
import 'package:pcfitment/database/database_helper.dart';
import 'package:pcfitment/utils/preference_utils.dart';

class LanguageChange with ChangeNotifier {
  Locale? _appLocale;

  Locale? get appLocale => _appLocale;

  Future<void> initLanguage() async {
    _appLocale = Locale(PreferenceUtils.getSystemLangCode());
    notifyListeners();
  }

  void changeLanguage(Locale type) async {
    _appLocale = type;

    /*if (type == const Locale('en')) {
      await PreferenceUtils.setLanguageCode('en');
    } else {
      await PreferenceUtils.setLanguageCode('zh');
    }*/

    if (type == const Locale('zh')) {
      await PreferenceUtils.setSystemLangCode('zh');
    } else {
      await PreferenceUtils.setSystemLangCode('en');
    }
    notifyListeners();
  }


  Future<String> strTranslatedValue1(String value) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    // ignore: prefer_for_elements_to_map_fromiterable
    Map<String, String> translationsMap = Map.fromIterable(
      await dbHelper.getLang(),
      key: (langModel) => langModel.textContent,
      value: (langModel) => langModel.translated,
    );

    var translatedValue = translationsMap[value] ?? 'Translation not found';
    return translatedValue;
  }

  Future<String> strTranslatedValue(String value) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    // ignore: prefer_for_elements_to_map_fromiterable
    Map<String, String> translationsMap = Map.fromIterable(
      await dbHelper.getLang(),
      key: (langModel) => langModel.textContent,
      value: (langModel) => langModel.translated,
    );
    var translatedValue = translationsMap[value];
    translatedValue ??= value;
    return translatedValue;
  }
}
