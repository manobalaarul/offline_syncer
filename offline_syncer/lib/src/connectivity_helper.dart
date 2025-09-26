import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();
  factory ConnectivityHelper() => _instance;
  ConnectivityHelper._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void initialize() {
    print('🔌 Initializing connectivity monitoring...');
    _checkInitialConnectivity();

    // 🔥 AUTO-SYNC TRIGGER: Listen to real-time connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    print('📱 Initial connectivity status: $results');
    _updateConnectionStatus(results); // already a list
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    print(
      '📶 Connectivity changed: ${result.toString()} (Connected: $_isConnected)',
    );

    if (!wasConnected && _isConnected) {
      print('🎉 Device just came ONLINE! Broadcasting sync trigger...');
      _connectionController.add(true);
    } else if (wasConnected && !_isConnected) {
      print('📵 Device went OFFLINE');
      _connectionController.add(false);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}
