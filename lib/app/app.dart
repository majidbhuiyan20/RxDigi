import 'package:flutter/material.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute: AppRoutes.splashRoute,
    );
  }
}
