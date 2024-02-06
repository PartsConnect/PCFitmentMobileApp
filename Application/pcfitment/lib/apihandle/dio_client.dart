import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/utils/preference_utils.dart';

class DioClient {
  static const int timeOutDuration = 20;

  //GET
  Future<dynamic> get(String baseUrl) async {
    var uri = Uri.parse(baseUrl);
    try {
      var response = await Dio()
          .get(baseUrl)
          .timeout(const Duration(seconds: timeOutDuration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }on DioError catch (error) {
      throw handleError(error);
    }
  }

  //GET QUERY
  Future<dynamic> getQueryParam(String baseUrl,
      {Map<String, dynamic>? queryParams}) async {
    var uri = Uri.parse(baseUrl);

    // Append query parameters if they are not null or empty
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    }

    try {
      var response = await Dio()
          .get(uri.toString(),
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': PreferenceUtils.getAuthToken()
                },
              ))
          .timeout(const Duration(seconds: timeOutDuration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    } on DioError catch (error) {
      throw handleError(error);
    }
  }

  //POST
  Future<dynamic> post(String baseUrl, dynamic payloadObj) async {
    var uri = Uri.parse(baseUrl);
    var payload = json.encode(payloadObj);
    try {
      var response = await Dio()
          .post(baseUrl,
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': PreferenceUtils.getAuthToken()
                },
              ),
              data: payload)
          .timeout(const Duration(seconds: timeOutDuration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }on DioError catch (error) {
      throw handleError(error);
    }
  }

  //OTHER
  dynamic _processResponse(response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
        throw BadRequestException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 401:
      case 403:
      case 404:
        throw UnAuthorizedException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured with code : ${response.statusCode}',
            response.request!.url.toString());
    }
  }

  dynamic handleError(DioError error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 400:
          throw BadRequestException(error.response!.data.toString(),
              error.requestOptions.uri.toString());
        case 401:
        case 403:
        case 404:
          throw UnAuthorizedException(error.response!.data.toString(),
              error.requestOptions.uri.toString());
        case 500:
        default:
          throw FetchDataException(
              'Error occurred with code : ${error.response!.statusCode}',
              error.requestOptions.uri.toString());
      }
    } else {
      throw FetchDataException('Error occurred with message : ${error.message}',
          error.requestOptions.uri.toString());
    }
  }
}
