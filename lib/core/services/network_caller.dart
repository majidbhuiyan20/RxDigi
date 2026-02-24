import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
part '../models/network_response.dart';

class NetworkCaller {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      lineLength: 100,
      colors: false,
      printEmojis: true,
      printTime: true,
    ),
  );

  final VoidCallback onUnauthorised;
   final Map<String, String>? headers;

   NetworkCaller({ required this.onUnauthorised, this.headers});

   Future<NetworkResponse> getRequest({required String url}) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url);
      Response response = await get(uri, headers: headers);

      _logResponse(url, response);

      final int statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        final decodedData = json.decode(response.body);
        return NetworkResponse(
          isSuccess: true,
          responseCode: statusCode,
          responseData: decodedData,
        );
      }
      else if(statusCode == 401){
        onUnauthorised();
        return NetworkResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: null,
          errorMessage: "Unauthorized",);
      }
      else {
        final decodedData = json.decode(response.body);
        return NetworkResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: decodedData,
        );
      }
    } on Exception catch (e) {
      return NetworkResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: e.toString(),
      );
    }
  }

   Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url, body: body);
      Response response = await post(
          uri,
          headers: headers ?? {
            'content-type': 'application/json',
          },


          body: jsonEncode(body));

      _logResponse(url, response);

      final int statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201){
        final decodedData = json.decode(response.body);
        return NetworkResponse(
          isSuccess: true,
          responseCode: statusCode,
          responseData: decodedData,
        );
      }
      else if(statusCode == 401){
        onUnauthorised();
        return NetworkResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: null,
          errorMessage: "Unauthorized",);
      }//
      else {
        final decodedData = json.decode(response.body);
        return NetworkResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: decodedData,
        );
      }
    } on Exception catch (e) {
      return NetworkResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: e.toString(),
      );
    }
  }

   void _logRequest(String url, {Map<String, dynamic>? body}) {
    _logger.i(
      'URL => $url\n'
          'Request Body => $body',
    );
  }

   void _logResponse(String url, Response response) {
    _logger.i(
      'URL => $url\n'
          'Status Code => ${response.statusCode}\n'
          'Body => ${response.body}',
    );
  }
}
