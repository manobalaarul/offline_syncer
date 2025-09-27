import 'dart:async';

import 'package:dio/dio.dart';

import 'connectivity_helper.dart';
import 'database_helper.dart';
import 'encryption_helper.dart';
import 'models/sync_config.dart';
import 'models/sync_data.dart';

// Callback types for sync events
typedef SyncProgressCallback =
    void Function(String message, String formName, bool isSuccess);
typedef SyncCompletedCallback = void Function(int totalSynced, int totalFailed);

class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final EncryptionHelper _encryptionHelper = EncryptionHelper();
  final ConnectivityHelper _connectivityHelper = ConnectivityHelper();
  late final Dio _dio;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isInitialized = false;
  SyncConfig? _config;

  // Callbacks for UI updates
  SyncProgressCallback? _onSyncProgress;
  SyncCompletedCallback? _onSyncCompleted;

  /// Initialize the offline sync manager with configuration
  Future<void> initialize(
    SyncConfig config, {
    SyncProgressCallback? onSyncProgress,
    SyncCompletedCallback? onSyncCompleted,
  }) async {
    if (_isInitialized) return;

    _config = config;
    _onSyncProgress = onSyncProgress;
    _onSyncCompleted = onSyncCompleted;

    // Initialize Dio with interceptors
    _dio = Dio();
    _dio.interceptors.add(LogInterceptor());

    // Set default options
    _dio.options = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
        ...config.defaultHeaders ?? {},
      },
    );

    _encryptionHelper.initialize(config.encryptionKey);
    _connectivityHelper.initialize();

    // Listen for connectivity changes and sync when connected
    _connectivitySubscription = _connectivityHelper.connectionStream.listen((
      isConnected,
    ) async {
      print(
        '📶 Connection status changed: ${isConnected ? "ONLINE" : "OFFLINE"}',
      );

      if (isConnected) {
        print('🚀 Device came online! Starting automatic sync...');

        // Get pending count before sync
        final pendingCount = await getPendingCount();
        if (pendingCount > 0) {
          print('📤 Found $pendingCount pending items to sync');
          await _syncPendingDataWithProgress();
        } else {
          print('✨ No pending data to sync');
        }
      }
    });

    _isInitialized = true;
  }

  /// Submit form data - checks internet first, then stores offline if needed
  Future<Map<String, dynamic>> submitForm({
    required String formId,
    required String path,
    required Map<String, dynamic> formData,
  }) async {
    print("Form  Data : $formData");
    if (!_isInitialized) {
      throw StateError(
        'OfflineSyncManager not initialized. Call initialize() first.',
      );
    }

    try {
      // Check internet connection first
      if (_connectivityHelper.isConnected) {
        // Try to send directly
        print('📡 Internet available - sending directly to $path');
        final response = await _sendDirectly(formId, path, formData);

        if (response['success'] == true) {
          print('✅ Form sent successfully');
          return response;
        } else {
          print('❌ Direct send failed, storing offline');
          return response;
        }
      } else {
        // No internet - store offline
        print('📱 No internet - storing offline');
        await _storeOffline(formId, path, formData);
        return {
          'success': false,
          'message': 'No internet connection - stored offline for later sync',
          'stored_offline': true,
        };
      }
    } catch (e) {
      print('Error submitting form: $e');
      // Try to store offline as fallback
      try {
        await _storeOffline(formId, path, formData);
        return {
          'success': false,
          'message': 'Error occurred - stored offline for later sync',
          'stored_offline': true,
          'error': e.toString(),
        };
      } catch (storageError) {
        return {
          'success': false,
          'message': 'Failed to submit and store offline',
          'error': storageError.toString(),
        };
      }
    }
  }

  /// Send form data directly to API
  Future<Map<String, dynamic>> _sendDirectly(
    String formId,
    String path,
    Map<String, dynamic> formData,
  ) async {
    try {
      print('📡 Sending POST request to $path');
      final response = await _dio.post(path, data: formData);

      // Check if API returns error inside response
      if (response.data is Map && response.data['status'] == 'error') {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.data['message'], // <-- direct message
          'data': response.data,
        };
      }

      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
        'message': 'Form submitted successfully',
      };
    } on DioException catch (dioError) {
      return {
        'success': false,
        'statusCode': dioError.response?.statusCode,
        'data': dioError.response?.data,
        'error': dioError.response?.data?['message'] ?? dioError.message,
        'type': dioError.type.toString(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Store form data offline
  Future<void> _storeOffline(
    String formId,
    String path,
    Map<String, dynamic> formData,
  ) async {
    final encryptedData = _encryptionHelper.encrypt(formData);

    final syncData = SyncData(
      formId: formId,
      encryptedData: encryptedData,
      createdAt: DateTime.now(),
      targetRoute: path,
    );

    await _dbHelper.insertSyncData(syncData);
  }

  /// Sync pending data with progress notifications
  Future<bool> _syncPendingDataWithProgress() async {
    if (_config == null) {
      print('❌ Sync config not initialized');
      return false;
    }

    try {
      print('🔍 Checking for unsynced data...');
      final unsyncedData = await _dbHelper.getUnsyncedData();

      if (unsyncedData.isEmpty) {
        print('✨ No pending data to sync');
        _onSyncCompleted?.call(0, 0);
        return true;
      }

      print('📤 Found ${unsyncedData.length} items to sync');
      int successCount = 0;
      int failedCount = 0;

      for (final data in unsyncedData) {
        // if (data.retryCount >= 3) {
        //   print('⏭️ Skipping item ${data.id} (max retries reached)');
        //   failedCount++;
        //   continue;
        // }

        final formName = data.formId;
        print('🔄 Syncing $formName (attempt ${data.retryCount + 1})...');

        _onSyncProgress?.call('Syncing $formName...', formName, true);

        final result = await _syncSingleItem(data);

        if (result['success'] == true) {
          await _dbHelper.markAsSynced(data.id!);
          successCount++;
          print('✅ $formName synced successfully');
          _onSyncProgress?.call(
            '✅ $formName sent successfully!',
            formName,
            true,
          );
        } else {
          await _dbHelper.updateRetryCount(data.id!, data.retryCount + 1);
          failedCount++;
          print('❌ $formName sync failed: ${result['error']}');
          _onSyncProgress?.call('❌ Failed to send $formName', formName, false);
        }

        await Future.delayed(Duration(milliseconds: 500));
      }

      // Clean up old synced data
      await _dbHelper.deleteOldSyncedData();

      print('🎯 Sync completed: $successCount success, $failedCount failed');
      _onSyncCompleted?.call(successCount, failedCount);

      return failedCount == 0;
    } catch (e) {
      print('💥 Error during sync: $e');
      _onSyncProgress?.call('Sync error: $e', 'System', false);
      _onSyncCompleted?.call(0, 1);
      return false;
    }
  }

  /// Sync a single item and return detailed response
  Future<Map<String, dynamic>> _syncSingleItem(SyncData data) async {
    if (_config == null) {
      return {'success': false, 'error': 'Sync config not initialized'};
    }

    try {
      final decryptedData = _encryptionHelper.decrypt(data.encryptedData);

      // Merge custom headers with default headers
      final customHeaders = data.customHeaders ?? {};

      // final requestData = {
      //   'formId': data.formId,
      //   'data': decryptedData,
      //   'submittedAt': data.createdAt.toIso8601String(),
      // };

      print('📡 Sending sync request to ${data.targetRoute}');
      final response = await _dio.post(
        data.targetRoute,
        data: decryptedData,
        options: Options(
          headers: customHeaders.isNotEmpty ? customHeaders : null,
        ),
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
        'message': response.data['message'],
        'headers': response.headers.map,
      };
    } on DioException catch (dioError) {
      print('💥 DioException syncing item ${data.id}: ${dioError.message}');
      return {
        'success': false,
        'statusCode': dioError.response?.statusCode,
        'data': dioError.response?.data,
        'error': dioError.message,
        'type': dioError.type.toString(),
      };
    } catch (e) {
      print('💥 Unexpected error syncing item ${data.id}: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get count of pending (unsynced) items
  Future<int> getPendingCount() async {
    final unsyncedData = await _dbHelper.getUnsyncedData();
    return unsyncedData.length;
  }

  /// Get detailed information about pending items
  Future<List<Map<String, dynamic>>> getPendingItemsInfo() async {
    final unsyncedData = await _dbHelper.getUnsyncedData();
    return unsyncedData.map((data) {
      return {
        'id': data.id,
        'formId': data.formId,
        'formData': EncryptionHelper().decrypt(data.encryptedData),
        'createdAt': data.createdAt,
        'retryCount': data.retryCount,
        'formName': data.formId,
        'targetRoute': data.targetRoute,
        'httpMethod': data.httpMethod,
      };
    }).toList();
  }

  /// Manual retry sync with progress notifications
  Future<bool> manualRetrySync() async {
    if (!_isInitialized) return false;

    if (!_connectivityHelper.isConnected) {
      _onSyncProgress?.call('No internet connection', 'System', false);
      return false;
    }

    print('🔄 Manual retry sync triggered...');
    return await _syncPendingDataWithProgress();
  }

  Future<bool> deleteUnSyncedData() async {
    try {
      await _dbHelper.deleteUnSyncedData();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if device is currently online
  bool get isOnline => _connectivityHelper.isConnected;

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityHelper.dispose();
    _dbHelper.close();
    _dio.close();
  }
}
