import 'dart:convert';

class SyncData {
  final int? id;
  final String formId;
  final String encryptedData;
  final String targetRoute; // 🔥 Store API route like "profiles.php"
  final Map<String, String>? customHeaders;
  final String? httpMethod; // 🔥 Store HTTP method (GET, POST, PUT, etc.)
  final DateTime createdAt;
  final bool isSynced;
  final int retryCount;

  const SyncData({
    this.id,
    required this.formId,
    required this.encryptedData,
    required this.targetRoute,
    this.customHeaders,
    this.httpMethod = 'POST',
    required this.createdAt,
    this.isSynced = false,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'formId': formId,
      'encryptedData': encryptedData,
      'targetRoute': targetRoute,
      'customHeaders': customHeaders != null ? jsonEncode(customHeaders) : null,
      'httpMethod': httpMethod ?? 'POST',
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
      'retryCount': retryCount,
    };
  }

  factory SyncData.fromMap(Map<String, dynamic> map) {
    return SyncData(
      id: map['id'],
      formId: map['formId'],
      encryptedData: map['encryptedData'],
      targetRoute: map['targetRoute'] ?? 'submit.php',
      customHeaders: map['customHeaders'] != null
          ? Map<String, String>.from(jsonDecode(map['customHeaders']))
          : null,
      httpMethod: map['httpMethod'] ?? 'POST',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isSynced: map['isSynced'] == 1,
      retryCount: map['retryCount'] ?? 0,
    );
  }

  SyncData copyWith({
    int? id,
    String? formId,
    String? encryptedData,
    String? targetRoute,
    Map<String, String>? customHeaders,
    String? httpMethod,
    DateTime? createdAt,
    bool? isSynced,
    int? retryCount,
  }) {
    return SyncData(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      encryptedData: encryptedData ?? this.encryptedData,
      targetRoute: targetRoute ?? this.targetRoute,
      customHeaders: customHeaders ?? this.customHeaders,
      httpMethod: httpMethod ?? this.httpMethod,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
