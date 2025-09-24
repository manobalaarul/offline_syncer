import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class DioClient {
  late Dio dio;

  DioClient() {
    final baseOptions = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(minutes: ApiConstants.connectionTimeout),
      receiveTimeout: const Duration(minutes: ApiConstants.receiveTimeout),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio = Dio(baseOptions);

    dio.interceptors.add(LogInterceptor());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token from SharedPreferences
          // String? token = Prefs.getString(AppConstants.accessToken);
          // print("Token : $token");
          // if (token != "") {
          // options.headers["Authorization"] = "Bearer $token";
          // }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.data == null) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: 'Empty response',
              ),
            );
          }
          if (response.statusCode != 200) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: 'Error: ${response.statusCode}',
              ),
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print("API Error: ${e.response?.data}");
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response<T>> get<T>({
    String path = "",
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>({
    String path = "",
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>({
    String path = "",
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>({
    String path = "",
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          message: 'Connection timeout. Please try again.',
          code: '',
        );
      case DioExceptionType.badResponse:
        return ServerException(
          message: _getErrorMessage(error.response),
          code: '',
        );
      case DioExceptionType.cancel:
        return ServerException(message: 'Request cancelled', code: '');
      default:
        return ServerException(
          message: 'Something went wrong. Please try again.',
          code: '',
        );
    }
  }

  String _getErrorMessage(Response? response) {
    int? statusCode = response?.statusCode;
    try {
      if (response!.data['message'] != null && response.data['message'] != "") {
        return response.data['message'];
      }
      switch (statusCode) {
        case 400:
          return 'Bad request';
        case 401:
          return 'Unauthorized';
        case 403:
          return 'Forbidden';
        case 404:
          return 'Not found';
        case 500:
          return 'Internal server error';
        default:
          return 'Something went wrong';
      }
    } catch (e) {
      return 'Something went wrong : ${e.toString()}';
    }
  }
}
