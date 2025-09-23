import 'package:equatable/equatable.dart';

enum RequestMethod { GET, POST, PUT, DELETE, PATCH }

class SyncRequest extends Equatable {
  final String id;
  final String endpoint;
  final RequestMethod method;
  final Map<String, dynamic>? payload;
  final Map<String, String>? headers;
  final DateTime createdAt;
  final int retryCount;
  final bool failed;
  final String? errorMessage;

  const SyncRequest({
    required this.id,
    required this.endpoint,
    required this.method,
    this.payload,
    this.headers,
    required this.createdAt,
    this.retryCount = 0,
    this.failed = false,
    this.errorMessage,
  });

  SyncRequest copyWith({
    String? id,
    String? endpoint,
    RequestMethod? method,
    Map<String, dynamic>? payload,
    Map<String, String>? headers,
    DateTime? createdAt,
    int? retryCount,
    bool? failed,
    String? errorMessage,
  }) {
    return SyncRequest(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      payload: payload ?? this.payload,
      headers: headers ?? this.headers,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      failed: failed ?? this.failed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endpoint': endpoint,
      'method': method.name,
      'payload': payload,
      'headers': headers,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'failed': failed,
      'errorMessage': errorMessage,
    };
  }

  factory SyncRequest.fromJson(Map<String, dynamic> json) {
    return SyncRequest(
      id: json['id'],
      endpoint: json['endpoint'],
      method: RequestMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => RequestMethod.POST,
      ),
      payload: json['payload'],
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
      failed: json['failed'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    endpoint,
    method,
    payload,
    headers,
    createdAt,
    retryCount,
    failed,
    errorMessage,
  ];
}
