import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', '');
  
  Locale get currentLocale => _currentLocale;
  
  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('hi', ''), // Hindi
    Locale('es', ''), // Spanish
    Locale('fr', ''), // French
    Locale('ar', ''), // Arabic
  ];
  
  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'es': 'Español',
    'fr': 'Français',
    'ar': 'العربية',
  };
  
  LanguageService() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }
  
  Future<void> changeLanguage(Locale locale) async {
    if (supportedLocales.contains(locale)) {
      _currentLocale = locale;
      notifyListeners();
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    }
  }
  
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
  
  String get currentLanguageName => getLanguageName(_currentLocale.languageCode);
}
