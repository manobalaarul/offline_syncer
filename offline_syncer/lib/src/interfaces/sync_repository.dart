import '../models/sync_request.dart';

abstract class SyncRepository {
  Future<void> addRequest(SyncRequest request);
  Future<List<SyncRequest>> getPendingRequests();
  Future<void> updateRequest(SyncRequest request);
  Future<void> removeRequest(String id);
  Future<void> clearFailedRequests();
  Future<int> getPendingCount();
}
