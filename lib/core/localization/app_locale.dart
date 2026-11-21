enum AppLanguage { english, hausa }

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.hausa:
        return 'ha';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.english:
        return '🇬🇧';
      case AppLanguage.hausa:
        return '🇳🇬';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hausa:
        return 'Hausa';
    }
  }

  String get shortName {
    switch (this) {
      case AppLanguage.english:
        return 'EN';
      case AppLanguage.hausa:
        return 'HA';
    }
  }
}
