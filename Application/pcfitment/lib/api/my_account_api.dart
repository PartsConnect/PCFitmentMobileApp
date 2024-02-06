import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';

import 'package:dio/dio.dart';

class MyAccountAPI {
  static Future personTabDetailsAPICall(BuildContext context) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    try {
      final response = await dio.get(
        getUserDetailsUrl,
        queryParameters: {
          'tenantID': PreferenceUtils.getLoginUserId(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': PreferenceUtils.getAuthToken()
          },
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return responseData;
      } else {
        return responseData;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  static Future updatePersonTabDetailsAPICall(
      BuildContext context,
      String userID,
      String firstName,
      String lastName,
      String phone,
      String weChatID) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    final authenticationData = {
      'tenantID': userID,
      'FirstName': firstName,
      'LastName': lastName,
      'Phone': phone,
      'WeChatID': weChatID,
    };

    try {
      final response = await dio.post(
        editUserDetailsUrl,
        data: authenticationData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': PreferenceUtils.getAuthToken()
          },
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return responseData;
      } else {
        return responseData;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  static Future resetPasswordAPICall(BuildContext context, String userID,
      String oldPassword, String newPassword, String confirmPassword) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    final authenticationData = {
      'tenantID': userID,
      'OldPassword': oldPassword,
      'NewPassword': newPassword,
      'ConfirmPassword': confirmPassword,
    };

    try {
      final response = await dio.post(
        resetPasswordUrl,
        data: authenticationData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': PreferenceUtils.getAuthToken()
          },
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return responseData;
      } else {
        return responseData;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  static Future getBillingHistoryAPICall(
      BuildContext context, String currentPage, String userId) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    try {
      Map<String, dynamic> param = {
        'pageNumber': currentPage,
        'tenantID': userId,
      };

      final response = await dio.get(
        getBillingHistoryDetailsUrl,
        queryParameters: param,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': PreferenceUtils.getAuthToken()
          },
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return responseData;
      } else {
        return responseData;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }
}
