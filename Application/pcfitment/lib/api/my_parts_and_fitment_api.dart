import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class MyPartsAndFitmentAPI {
  static Future getMyPartsAndFitmentAPICall(
      BuildContext context,
      String currentPage,
      String ddlItemId,
      String searchValue,
      String userId) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    try {
      Map<String, dynamic> param = {
        'pageNumber': currentPage,
        'ddlItemId': ddlItemId,
        'tenantID': userId,
      };

      if (searchValue.isNotEmpty) {
        param['searchValue'] = searchValue;
      }

      final response = await dio.get(
        getMyPartsAndFitmentUrl,
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
    } on FetchDataException catch (e) {
      if (context.mounted) snackBarErrorMsg(context, e.message!);
    } on ApiNotRespondingException catch (e) {
      if (context.mounted) snackBarErrorMsg(context, e.message!);
    } on DioError catch (error) {
      throw handleError(error);
    }
    return null;
  }

  static Future getSavedMyPartsAndFitmentAPICall(
    BuildContext context,
    String userId,
    String partId,
    String currentPage,
    String yearValue,
    String makeValue,
    String modelValue,
  ) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    try {
      Map<String, dynamic> param = {
        'tenantID': userId,
        'partID': partId,
        'pageNumber': currentPage,
      };

      if (yearValue.isNotEmpty) {
        param['YearSearch'] = yearValue;
      }
      if (makeValue.isNotEmpty) {
        param['MakeSearch'] = makeValue;
      }
      if (modelValue.isNotEmpty) {
        param['MakeSearch'] = modelValue;
      }

      final response = await dio.get(
        getSavedMyPartsAndFitmentUrl,
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

  static Future getErrorMyPartsAndFitmentAPICall(
    BuildContext context,
    String userId,
    String partId,
    String currentPage,
    String yearValue,
    String makeValue,
    String modelValue,
  ) async {
    final dio = Dio(BaseOptions(connectTimeout: 20000, receiveTimeout: 20000));
    try {
      Map<String, dynamic> param = {
        'tenantID': userId,
        'partID': partId,
        'pageNumber': currentPage,
      };

      if (yearValue.isNotEmpty) {
        param['YearSearch'] = yearValue;
      }
      if (makeValue.isNotEmpty) {
        param['MakeSearch'] = makeValue;
      }
      if (modelValue.isNotEmpty) {
        param['MakeSearch'] = modelValue;
      }

      final response = await dio.get(
        getErrorMyPartsAndFitmentUrl,
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
