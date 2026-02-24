import '../core/services/network_caller.dart';

NetworkCaller getNetworkCaller(){
  NetworkCaller networkCaller = NetworkCaller(
      headers: {
        'content-type': 'application/json',
        'token': 'token',
      },
      onUnauthorised: (){
        //Move to login screen
      },
  );
  return networkCaller;
}