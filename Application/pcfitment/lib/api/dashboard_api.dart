import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class DashboardAPI {
  static Future getLanguageAPICall(BuildContext context) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    try {
      final response = await dio.get(
        getLanguagesUrl,
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

  static Future getLanguageDetailsAPICall(
      BuildContext context, String langCode, String deviceId) async {
    final dio = Dio(BaseOptions(connectTimeout: 50000, receiveTimeout: 50000));
    try {
      final param = {
        'LanguageCode': langCode,
        'DeviceID': deviceId
      };

      final response = await dio.get(
        getLanguagesWiseDetailsUrl,
        queryParameters: param,
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

  static Future<List<Map<String, dynamic>>?> multipleAPIFetchData(
      BuildContext context, String userID, String auth) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    try {
      List<Response<dynamic>> responses = await Future.wait([
        dio.get(
          getPlanDetailsUrl,
          queryParameters: {'tenantID': userID},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': auth
            },
          ),
        ),
        dio.get(
          getFitmentSummaryUrl,
          queryParameters: {'tenantID': userID},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': auth
            },
          ),
        ),
        dio.get(
          getMostRecentExportUrl,
          queryParameters: {'tenantID': userID},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': auth
            },
          ),
        ),
      ]);

      List<Map<String, dynamic>> responseDataList = [];
      for (var response in responses) {
        if (response.statusCode == 200) {
          responseDataList.add(response.data['data']);
        } else {
          if (context.mounted) {
            snackBarErrorMsg(context, response.data['Message']);
          }
          //throw Exception('Failed to fetch data');
        }
      }
      return responseDataList;
    } on FetchDataException catch (e) {
      if (context.mounted) snackBarErrorMsg(context, e.message!);
    } on ApiNotRespondingException catch (e) {
      if (context.mounted) snackBarErrorMsg(context, e.message!);
    } on DioError catch (error) {
      throw handleError(error);
    }
    return null;
  }

  static dynamic handleError(DioError error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 400:
        case 401:
        case 404:
          throw Exception(error.response!.data.toString());
        case 500:
        default:
          throw Exception(
              'Error occurred with code : ${error.response!.statusCode}');
      }
    } else {
      throw Exception('Error occurred: ${error.message}');
    }
  }
}
