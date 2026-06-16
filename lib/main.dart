import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prescripto/app/app.dart';
import 'firebase_options.dart';
import 'l10n/local_provider.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final savedCode = await loadSavedLocaleCode();
      debugPrint("🌍 Starting with locale: $savedCode");

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      runApp(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(
              () => LocaleNotifier(savedCode),
            ),
          ],
          child: const Prescripto(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}
