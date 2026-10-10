import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prescripto/app/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/local_provider.dart';
import 'app_routes.dart';

class Prescripto extends ConsumerWidget {
  const Prescripto({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    debugPrint("🌍 Current locale in app: ${locale.languageCode}");

    return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
      builder: (_,context)  {
        return MaterialApp(
          navigatorKey: AppRoutes.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Prescripto',
          theme: AppTheme.lightTheme,
          onGenerateRoute: RouteGenerator.getRoute,
          initialRoute: AppRoutes.splashRoute,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('bn'),
          ],
        );
      }
    );
  }
}
