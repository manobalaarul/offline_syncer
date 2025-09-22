class CacheException implements Exception {
  final String? message;
  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String? message;
  NetworkException({required this.message});
}

class ApiException implements Exception {
  final String message;
  final String? code;
  ApiException({required this.message, this.code});

  @override
  String toString() => message;
}

class ServerException extends ApiException {
  ServerException({required super.message, super.code});
}

class AuthException extends ApiException {
  AuthException({required super.message, super.code});
}

class ValidationException implements Exception {
  final String message;
  ValidationException({required this.message});
}
