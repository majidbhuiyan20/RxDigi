import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import 'app_string.dart';

class AppRoutes{
  static const String splashRoute="/";
  static const String bottomNavBarRoute="/bottomNavbarRoute";
  static const String loginRoute="/loginScreen";

}
class RouteGenerator{
  static Route<dynamic>getRoute(RouteSettings routeSettings){
    switch (routeSettings.name) {
      case AppRoutes.splashRoute:
         return MaterialPageRoute(builder: (_)=> SplashScreen());
      // case AppRoutes.bottomNavBarRoute:
      //   return MaterialPageRoute(builder: (_)=> BottomNavBarScreen());

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