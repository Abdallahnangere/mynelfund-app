import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Fallback [CupertinoLocalizations] delegate ensuring unsupported locales such
/// as Hausa (`ha`) cleanly inherit English Cupertino strings, date formats, and
/// modal button labels instead of throwing missing-delegate assertions.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  /// Creates a [FallbackCupertinoLocalizationsDelegate].
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      const DefaultCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<CupertinoLocalizations> old,
  ) => false;
}

/// Fallback [MaterialLocalizations] delegate ensuring any internal Material
/// widgets (e.g., rich text selection toolbars or URL helpers) operate cleanly
/// under non-standard locales such as Hausa (`ha`).
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  /// Creates a [FallbackMaterialLocalizationsDelegate].
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const DefaultMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MaterialLocalizations> old,
  ) => false;
}
