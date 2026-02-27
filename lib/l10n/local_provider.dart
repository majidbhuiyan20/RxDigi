import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'selected_locale';

// ✅ read saved locale — called before runApp
Future<String> loadSavedLocaleCode() async {
  final prefs = await SharedPreferences.getInstance();
  final code  = prefs.getString(_localeKey) ?? 'en';
  debugPrint("🌍 Loaded locale from prefs: $code");
  return code;
}

class LocaleNotifier extends Notifier<Locale> {
  final String initialCode;

  LocaleNotifier(this.initialCode);

  @override
  Locale build() => Locale(initialCode); // ✅ start with saved locale

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    debugPrint("✅ Locale saved: ${locale.languageCode}");
  }
}

// ✅ family provider — accepts initial locale code
final localeProvider =
NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier('en'); // fallback
});