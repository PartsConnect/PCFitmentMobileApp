import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pcfitment/utils/url.dart';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class LoginAPI {
  static Future loginAPICall(BuildContext context, String email,
      String password, String fcmToken, String deviceID,String termsCondition,String privacyPolicy) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    final authenticationData = {
      'Email': email,
      'Password': password,
      'FCMToken': fcmToken,
      'DeviceID': deviceID,
      'IsTermsAndConditionAccept': termsCondition,
      'IsPrivacyPolicyAccept': privacyPolicy,
    };

    try {
      final response = await dio.post(
        loginURL,
        data: authenticationData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        //DialogHelper.hideLoading();

        //final responseData = response.data;
        //final token = responseData['data']['token'];
        //final userId = responseData['data']['UserID'];
        //final email = responseData['data']['Email'];

        //print(responseData);
        return responseData;
      } else {
        return responseData;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        // The server responded with an error status code (e.g., 500)
        // ignore: avoid_print
        print('Error response status code: ${e.response!.statusCode}');
        // ignore: avoid_print
        print('Error response data: ${e.response!.data}');
        // Handle the error based on the status code or response data
      } else {
        // Something went wrong before the response was received (e.g., no internet connection)
        if (kDebugMode) {
          print('Error message: ${e.message}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<Map<String, dynamic>> validUserAPI({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(Uri.parse(loginURL), body: {
        "Email": email,
        "Password": password,
      });

      if (response.statusCode == 200) {
        // Check if the response body is not empty
        if (response.body.isNotEmpty) {
          var data = jsonDecode(response.body);
          // Add your logic to handle the parsed data
          // ...
          if (kDebugMode) {
            print(data);
          }
          return data;
        } else {
          throw Exception('Empty response received');
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception('Failed to perform login: $e');
    }
  }
}
