import 'package:dio/dio.dart';

import '../config/sync_config.dart';
import '../models/sync_request.dart';
import '../models/sync_result.dart';
import 'encryption_service.dart';

class NetworkService {
  final Dio _dio;
  final SyncConfig _config;
  final EncryptionService? _encryptionService;

  NetworkService({
    required Dio dio,
    required SyncConfig config,
    EncryptionService? encryptionService,
  }) : _dio = dio,
       _config = config,
       _encryptionService = encryptionService {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = _config.baseUrl;
    _dio.options.connectTimeout = _config.requestTimeout;
    _dio.options.receiveTimeout = _config.requestTimeout;
    _dio.options.headers.addAll(_config.defaultHeaders);
  }

  Future<SyncResult> sendRequest(SyncRequest request) async {
    try {
      final url = request.endpoint;
      final headers = <String, String>{
        'Content-Type': 'application/json',
        ...request.headers ?? {},
      };

      Map<String, dynamic> data = {};

      if (request.payload != null) {
        if (_config.encryptionEnabled && _encryptionService != null) {
          final encryptedPayload = await _encryptionService.encryptData(
            request.payload!,
          );
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final signature = await _encryptionService.generateSignature(
            appId: _config.appId,
            endpoint: request.endpoint,
            payload: encryptedPayload,
            timestamp: timestamp,
          );

          headers.addAll({
            'X-App-Id': _config.appId,
            'X-Signature': signature,
            'X-Timestamp': timestamp.toString(),
          });

          data = {'data': encryptedPayload};
        } else {
          data = request.payload!;
        }
      }

      final response = await _dio.request(
        url,
        data: data.isNotEmpty ? data : null,
        options: Options(method: request.method.name, headers: headers),
      );

      return SyncResult.success(
        statusCode: response.statusCode,
        data: response.data,
        message: 'Request successful',
      );
    } on DioException catch (e) {
      return SyncResult.failure(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      return SyncResult.failure(message: 'Unexpected error: $e');
    }
  }
}
