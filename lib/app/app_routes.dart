import 'package:flutter/material.dart';
import 'package:rxdigi/features/home/view/home_screen.dart';
import 'package:rxdigi/features/settings/view/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import 'app_string.dart';

class AppRoutes{
  static const String splashRoute="/";
  static const String homeScreenRoute ="/homeScreen";
  static const String settingsScreenRoute ="/settingsScreen";
  static const String bottomNavBarRoute="/bottomNavbarRoute";
  static const String loginRoute="/loginScreen";

}
class RouteGenerator{
  static Route<dynamic>getRoute(RouteSettings routeSettings){
    switch (routeSettings.name) {
      case AppRoutes.splashRoute:
         return MaterialPageRoute(builder: (_)=> SplashScreen());
      case AppRoutes.homeScreenRoute:
        return MaterialPageRoute(builder: (_)=> HomeScreen());
      case AppRoutes.settingsScreenRoute:
        return MaterialPageRoute(builder: (_)=> SettingsScreen());

      default:
        return unDefineRoute();
    }

  }
  static Route<dynamic>unDefineRoute(){
    return MaterialPageRoute(builder: (_)=>Scaffold(
      appBar: AppBar(title: Text(AppString.noRoute),),
      body: Center(child: Text(AppString.noRoute),),
    ));
  }
}