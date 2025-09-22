import 'package:dio/dio.dart';

import 'encryption_service.dart';

class NetworkService {
  final Dio dio;
  final String appId;
  final EncryptionService encryptionService;

  NetworkService({
    required this.dio,
    required this.appId,
    required this.encryptionService,
  });

  Future<Response> sendEncrypted({
    required String endpoint,
    required String payloadB64,
  }) async {
    final ts = DateTime.now().toUtc().millisecondsSinceEpoch;
    final signature = await encryptionService.sign(
      appId,
      endpoint,
      payloadB64,
      ts,
    );

    final headers = {
      'X-App-Id': appId,
      'X-Signature': signature,
      'X-Timestamp': ts.toString(),
      'Content-Type': 'application/json',
    };

    final body = {
      'data': payloadB64,
    }; // server expects base64 ciphertext in data
    return dio.post(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );
  }
}
