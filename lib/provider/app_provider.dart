import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  String _selectedLanguage = 'English';
  String _selectedUser = 'farmer';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get selectedLanguage => _selectedLanguage;
  String get selectedUser => _selectedUser;

  void setLanguage(String language) {
    _selectedLanguage = language;

    if (language == 'English') {
      _locale = const Locale('en');
    } else if (language == 'Kannada') {
      _locale = const Locale('kn');
    } else if (language == 'Hindi' || language == 'हिंदी') {
      _locale = const Locale('hi');
    }
    notifyListeners();
  }

  void setUser(String user) {
    _selectedUser = user;
    notifyListeners();
  }
}
