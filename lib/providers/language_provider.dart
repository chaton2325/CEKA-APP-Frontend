import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { fr, en }

class LanguageProvider with ChangeNotifier {
  static const _storageKey = 'app_language';

  AppLanguage _language = AppLanguage.fr;

  LanguageProvider() {
    _loadLanguage();
  }

  AppLanguage get language => _language;
  bool get isFrench => _language == AppLanguage.fr;
  String get languageCode => isFrench ? 'fr' : 'en';

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;

    _language = language;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, languageCode);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_storageKey);

    if (savedLanguage == 'en') {
      _language = AppLanguage.en;
    } else {
      _language = AppLanguage.fr;
    }

    notifyListeners();
  }
}
