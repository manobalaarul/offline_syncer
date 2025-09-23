import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './src/config/sync_config.dart';
import 'offline_syncer.dart';
import './src/repositories/hive_sync_repository.dart';
import './src/services/encryption_service.dart';
import './src/services/network_service.dart';

class OfflineSyncerBuilder {
  static Future<OfflineSyncer> create({
    required SyncConfig config,
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  }) async {
    // Initialize Hive
    await Hive.initFlutter();

    // Create repository
    final repository = HiveSyncRepository();
    await repository.init();

    // Create services
    final encryptionService = config.encryptionEnabled
        ? EncryptionService(secureStorage ?? const FlutterSecureStorage())
        : null;

    final networkService = NetworkService(
      dio: dio ?? Dio(),
      config: config,
      encryptionService: encryptionService,
    );

    return OfflineSyncer(
      repository: repository,
      networkService: networkService,
      config: config,
    );
  }
}
