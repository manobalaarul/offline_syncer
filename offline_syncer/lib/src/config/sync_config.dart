class SyncConfig {
  final String appId;
  final String baseUrl;
  final int maxRetries;
  final Duration syncInterval;
  final bool encryptionEnabled;
  final Duration requestTimeout;
  final Map<String, String> defaultHeaders;

  const SyncConfig({
    required this.appId,
    required this.baseUrl,
    this.maxRetries = 3,
    this.syncInterval = const Duration(minutes: 5),
    this.encryptionEnabled = true,
    this.requestTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
  });
}
