import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_syncer/offline_syncer.dart';
import 'package:profile_app/core/constants/app_constants.dart';

import 'app_bloc_provider.dart';
import 'di/di_module.dart';
import 'features/utils/app_observer.dart';
import 'screens/profile_form_screen.dart';
import 'screens/profile_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DiModule().init();

  Bloc.observer = AppObserver();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProvider.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Profile Manager',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _offlineSync = OfflineSyncManager();

  int _pendingCount = 0;
  bool _isOnline = false;
  bool _isSyncing = false;
  List<Map<String, dynamic>> _pendingItems = [];

  @override
  void initState() {
    super.initState();
    _initializeOfflineSync();
    _updateStatus();
  }

  Future<void> _initializeOfflineSync() async {
    final config = SyncConfig(
      baseUrl: ApiConstants.baseUrl, // 🔥 Just your base URL
      apiKey: 'qazwsxedcrfvtgbyhnujmikolp',
      encryptionKey: 'mjgty6789ijhgfdcvbxder4532wesdacg',
      syncInterval: Duration(minutes: 2),
      defaultHeaders: {'App-Version': '1.0.0', 'Device-Type': 'mobile'},
      // Dio timeout configurations
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
    );

    await _offlineSync.initialize(
      config,
      onSyncProgress: (message, formName, isSuccess) {
        // Show toast notification for each sync
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      },
      onSyncCompleted: (totalSynced, totalFailed) {
        setState(() {
          _isSyncing = false;
        });
        _updateStatus();

        // Show completion summary
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync completed: $totalSynced success, $totalFailed failed',
            ),
            backgroundColor: totalFailed == 0 ? Colors.green : Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
    _updateStatus();
  }

  Future<void> _updateStatus() async {
    final count = await _offlineSync.getPendingCount();
    final items = await _offlineSync.getPendingItemsInfo();
    setState(() {
      _pendingCount = count;
      _pendingItems = items;
      _isOnline = _offlineSync.isOnline;
    });
  }

  int _currentIndex = 0;

  final List<Widget> _screens = [ProfileListScreen(), ProfileFormScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Profiles'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Profile'),
        ],
      ),
    );
  }
}
