import 'package:equatable/equatable.dart';

class SyncResult extends Equatable {
  final bool success;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  const SyncResult({
    required this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  const SyncResult.success({this.message, this.statusCode, this.data})
    : success = true;

  const SyncResult.failure({required this.message, this.statusCode, this.data})
    : success = false;

  @override
  List<Object?> get props => [success, message, statusCode, data];
}
