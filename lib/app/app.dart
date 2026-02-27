import 'package:flutter/material.dart';
import 'package:rxdigi/app/app_theme.dart';

import 'app_routes.dart';
class RxDigi extends StatefulWidget {
  const RxDigi({super.key});

  @override
  State<RxDigi> createState() => _RxDigiState();
}

class _RxDigiState extends State<RxDigi> {
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RxDigi',
      theme: AppTheme.lightTheme,
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute: AppRoutes.splashRoute,

    );
  }
}
