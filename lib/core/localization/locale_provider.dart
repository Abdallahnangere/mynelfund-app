import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'app_locale.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'app_language_preference';
  AppLanguage _currentLanguage = AppLanguage.english;

  LocaleProvider() {
    _loadLanguageFromPrefs();
  }

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isHausa => _currentLanguage == AppLanguage.hausa;
  bool get isEnglish => _currentLanguage == AppLanguage.english;

  Locale get locale => Locale(_currentLanguage.code);

  Future<void> _loadLanguageFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null) {
        if (savedCode == 'ha') {
          _currentLanguage = AppLanguage.hausa;
        } else {
          _currentLanguage = AppLanguage.english;
        }
        notifyListeners();
      }
      unawaited(NotificationService.instance.syncLanguagePreference(_currentLanguage));
    } catch (e) {
      debugPrint('[LocaleProvider] Error loading language preference: $e');
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (e) {
      debugPrint('[LocaleProvider] Error saving language preference: $e');
    }

    // Immediately sync to Cloud Firestore and re-align FCM language topics
    unawaited(NotificationService.instance.syncLanguagePreference(language));
  }

  Future<void> toggleLanguage() async {
    if (_currentLanguage == AppLanguage.english) {
      await setLanguage(AppLanguage.hausa);
    } else {
      await setLanguage(AppLanguage.english);
    }
  }
}
