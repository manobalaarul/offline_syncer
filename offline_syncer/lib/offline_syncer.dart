import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'src/network_service.dart';
import 'src/storage_service.dart';

class OfflineSyncer {
  final StorageService storage;
  final NetworkService network;
  final Connectivity connectivity;
  final int maxRetries;
  StreamSubscription? _connSub;
  bool _syncing = false;

  OfflineSyncer({
    required this.storage,
    required this.network,
    required this.connectivity,
    this.maxRetries = 5,
  });

  void start() {
    _connSub = connectivity.onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _triggerSync();
      }
    });
    // Optionally trigger at start
    _triggerSync();
  }

  void dispose() {
    _connSub?.cancel();
  }

  void addRequest(String endpoint, Map<String, dynamic> payload) async {
    // encrypt & attempt immediate send or enqueue
    final payloadB64 = await network.encryptionService.encryptJson(payload);
    final conn = await connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      try {
        await network.sendEncrypted(endpoint: endpoint, payloadB64: payloadB64);
        return;
      } catch (e) {
        // fallback to enqueue
      }
    }
    // enqueue
    await storage.addQueuedRequest({
      'endpoint': endpoint,
      'method': 'POST',
      'payload': payloadB64,
      'createdAt': DateTime.now().toIso8601String(),
      'retryCount': 0,
    });
  }

  Future<void> _triggerSync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final pending = storage
          .getAllPending(); // list of maps with id, endpoint, payload
      for (final item in pending) {
        final id = item['id'] as String;
        final endpoint = item['endpoint'] as String;
        final payloadB64 = item['payload'] as String;
        var retries = item['retryCount'] as int? ?? 0;

        try {
          final res = await network.sendEncrypted(
            endpoint: endpoint,
            payloadB64: payloadB64,
          );
          if (res.statusCode != null &&
              res.statusCode! >= 200 &&
              res.statusCode! < 300) {
            await storage.remove(id);
          } else {
            // server error -> increase retry
            retries++;
            await storage.update(id, {...item, 'retryCount': retries});
          }
        } catch (e) {
          retries++;
          await storage.update(id, {...item, 'retryCount': retries});
        }

        if (retries >= maxRetries) {
          // move to failed list; or keep but stop retrying for now
          await storage.update(id, {
            ...item,
            'retryCount': retries,
            'failed': true,
          });
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
