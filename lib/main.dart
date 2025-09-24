import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
