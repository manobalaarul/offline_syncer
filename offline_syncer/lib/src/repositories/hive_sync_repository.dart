import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../interfaces/sync_repository.dart';
import '../models/sync_request.dart';

class HiveSyncRepository implements SyncRepository {
  static const String _boxName = 'offline_sync_requests';
  late Box<Map> _box;
  final _uuid = const Uuid();

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  @override
  Future<void> addRequest(SyncRequest request) async {
    final requestWithId = request.id.isEmpty
        ? request.copyWith(id: _uuid.v4())
        : request;

    await _box.put(requestWithId.id, requestWithId.toJson());
  }

  @override
  Future<List<SyncRequest>> getPendingRequests() async {
    return _box.values
        .map((e) => SyncRequest.fromJson(Map<String, dynamic>.from(e)))
        .where((request) => !request.failed)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> updateRequest(SyncRequest request) async {
    await _box.put(request.id, request.toJson());
  }

  @override
  Future<void> removeRequest(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearFailedRequests() async {
    final failedIds = _box.values
        .map((e) => SyncRequest.fromJson(Map<String, dynamic>.from(e)))
        .where((request) => request.failed)
        .map((request) => request.id)
        .toList();

    for (final id in failedIds) {
      await _box.delete(id);
    }
  }

  @override
  Future<int> getPendingCount() async {
    return _box.values
        .map((e) => SyncRequest.fromJson(Map<String, dynamic>.from(e)))
        .where((request) => !request.failed)
        .length;
  }

  void dispose() {
    _box.close();
  }
}
