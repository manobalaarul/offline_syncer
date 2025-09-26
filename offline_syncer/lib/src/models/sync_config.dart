class SyncConfig {
  final String
  baseUrl; // 🔥 Base URL like "http://192.168.137.1/profile_app_api/"
  final String apiKey;
  final Map<String, String>? defaultHeaders;
  final Duration syncInterval;
  final String encryptionKey;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const SyncConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.encryptionKey,
    this.defaultHeaders,
    this.syncInterval = const Duration(minutes: 5),
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  });

  /// Get full URL by combining baseUrl with path
  String getFullUrl(String apiPath) {
    // Ensure proper URL construction
    final cleanBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanPath = apiPath.startsWith('/') ? apiPath.substring(1) : apiPath;
    return '$cleanBase$cleanPath';
  }
}
