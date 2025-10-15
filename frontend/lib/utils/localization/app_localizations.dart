import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  late Map<String, dynamic> _localizedStrings;

  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/lang/${locale.languageCode}.json',
    );
    _localizedStrings = json.decode(jsonString);
    return true;
  }

  String translate(String key, {Map<String, dynamic>? params}) {
    var raw = _getValue(key);
    if (raw == null) {
      return key;
    }

    if (params != null) {
      params.forEach((placeholder, value) {
        raw = raw!.replaceAll('{$placeholder}', value.toString());
      });
    }

    return raw!;
  }

  String plural(String baseKey, int count, {Map<String, dynamic>? params}) {
    String key;
    if (count == 0 && _hasKey('$baseKey.zero')) {
      key = '$baseKey.zero';
    } else if (count == 1 && _hasKey('$baseKey.one')) {
      key = '$baseKey.one';
    } else {
      key = '$baseKey.other';
    }

    return translate(key, params: {...?params, 'count': count});
  }

  bool _hasKey(String key) => _getValue(key) != null;

  String? _getValue(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;
    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }
    return value is String ? value : null;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
