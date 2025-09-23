import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import './src/config/sync_config.dart';
import './src/interfaces/sync_repository.dart';
import './src/models/sync_request.dart';
import './src/models/sync_result.dart';
import './src/services/network_service.dart';

class OfflineSyncer {
  final SyncRepository _repository;
  final NetworkService _networkService;
  final SyncConfig _config;
  final Connectivity _connectivity;

  StreamSubscription? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  // Stream controllers for status updates
  final _syncStatusController = StreamController<bool>.broadcast();
  final _pendingCountController = StreamController<int>.broadcast();

  OfflineSyncer({
    required SyncRepository repository,
    required NetworkService networkService,
    required SyncConfig config,
    Connectivity? connectivity,
  }) : _repository = repository,
       _networkService = networkService,
       _config = config,
       _connectivity = connectivity ?? Connectivity();

  // Public streams
  Stream<bool> get syncStatus => _syncStatusController.stream;
  Stream<int> get pendingCount => _pendingCountController.stream;

  /// Initialize and start the syncer
  Future<void> start() async {
    await _updatePendingCount();
    _startConnectivityListener();
    _startPeriodicSync();

    // Try initial sync
    unawaited(_syncPendingRequests());
  }

  /// Stop the syncer
  void stop() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _syncStatusController.close();
    _pendingCountController.close();
  }

  /// Add a request to be synced
  Future<SyncResult> addRequest({
    required String endpoint,
    RequestMethod method = RequestMethod.POST,
    Map<String, dynamic>? payload,
    Map<String, String>? headers,
    bool forceOnline = false,
  }) async {
    final request = SyncRequest(
      id: '',
      endpoint: endpoint,
      method: method,
      payload: payload,
      headers: headers,
      createdAt: DateTime.now(),
    );

    // Try immediate send if online and not forcing offline
    if (!forceOnline) {
      final isConnected = await _isConnected();
      if (isConnected) {
        final result = await _networkService.sendRequest(request);
        if (result.success) {
          return result;
        }
        // If immediate send fails, continue to queue
      }
    }

    // Queue for later sync
    await _repository.addRequest(request);
    await _updatePendingCount();

    return const SyncResult.success(message: 'Request queued for sync');
  }

  /// Force sync all pending requests
  Future<void> forcSync() async {
    unawaited(_syncPendingRequests());
  }

  /// Get pending requests count
  Future<int> getPendingCount() async {
    return await _repository.getPendingCount();
  }

  /// Clear all failed requests
  Future<void> clearFailedRequests() async {
    await _repository.clearFailedRequests();
    await _updatePendingCount();
  }

  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Pick the first result (usually what you want)
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;

      if (result != ConnectivityResult.none) {
        debugPrint('OfflineSyncer: Connection restored, starting sync');
        unawaited(_syncPendingRequests());
      }
    });
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_config.syncInterval, (_) {
      unawaited(_syncPendingRequests());
    });
  }

  Future<bool> _isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _syncPendingRequests() async {
    if (_isSyncing) return;

    final isConnected = await _isConnected();
    if (!isConnected) return;

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      final pendingRequests = await _repository.getPendingRequests();
      debugPrint('OfflineSyncer: Syncing ${pendingRequests.length} requests');

      for (final request in pendingRequests) {
        await _processSingleRequest(request);
      }

      await _updatePendingCount();
    } catch (e) {
      debugPrint('OfflineSyncer: Sync error - $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  Future<void> _processSingleRequest(SyncRequest request) async {
    try {
      final result = await _networkService.sendRequest(request);

      if (result.success) {
        await _repository.removeRequest(request.id);
        debugPrint('OfflineSyncer: Successfully synced request ${request.id}');
      } else {
        await _handleFailedRequest(request, result.message);
      }
    } catch (e) {
      await _handleFailedRequest(request, e.toString());
    }
  }

  Future<void> _handleFailedRequest(SyncRequest request, String? error) async {
    final updatedRequest = request.copyWith(
      retryCount: request.retryCount + 1,
      errorMessage: error,
      failed: request.retryCount + 1 >= _config.maxRetries,
    );

    await _repository.updateRequest(updatedRequest);

    if (updatedRequest.failed) {
      debugPrint(
        'OfflineSyncer: Request ${request.id} marked as failed after ${_config.maxRetries} retries',
      );
    }
  }

  Future<void> _updatePendingCount() async {
    final count = await _repository.getPendingCount();
    _pendingCountController.add(count);
  }
}
