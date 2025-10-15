import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider() {
    supportedLocales = const [Locale('en'), Locale('hi')];
  }

  List<Locale> supportedLocales = [];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
