import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/local_provider.dart';
import 'app_routes.dart';

class RxDigi extends ConsumerWidget {
  const RxDigi({super.key});

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
          debugShowCheckedModeBanner: false,
          title: 'RxDigi',
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