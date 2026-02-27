import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app.dart';
import 'firebase_options.dart';
import 'l10n/local_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ load saved locale code BEFORE runApp
  final savedCode = await loadSavedLocaleCode();
  debugPrint("🌍 Starting with locale: $savedCode");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  runZonedGuarded(
        () {
      runApp(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(
                  () => LocaleNotifier(savedCode),
            ),
          ],
          child: const RxDigi(),
        ),
      );
    },
        (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}